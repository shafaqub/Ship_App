require('dotenv').config();

const express = require('express');
const cors = require('cors');
const http = require('http');
const WebSocket = require('ws');

const { db } = require('./src/firebase');
const authRoutes = require('./src/routes/auth');

const app = express();

const PORT = process.env.PORT || 5000;

const GROK_MODEL =
  process.env.GROK_MODEL || 'grok-voice-latest';

const GROK_VOICE =
  process.env.GROK_VOICE || 'eve';

const EVALUATION_MODEL =
  process.env.EVALUATION_MODEL || 'grok-4.7';

const XAI_API_KEY =
  process.env.XAI_API_KEY;

const MAX_QUESTIONS = 5;

if (!XAI_API_KEY) {
  console.error(
    'ERROR: XAI_API_KEY is missing from backend/.env'
  );

  process.exit(1);
}

app.use(cors());
app.use(express.json());

app.use('/', authRoutes);

app.get('/health', async (req, res) => {
  try {
    await db.collection('_health').doc('test').set({
      status: 'ok',
      timestamp: new Date().toISOString(),
    });

    res.json({
      status: 'ok',
      firebase: true,
      grok: true,
      evaluator: true,
    });
  } catch (error) {
    console.error(
      'Health check error:',
      error
    );

    res.status(500).json({
      status: 'error',
      firebase: false,
      grok: true,
      evaluator: true,
      error: error.message,
    });
  }
});

const server = http.createServer(app);

const wss = new WebSocket.Server({
  server,
  path: '/voice',
});

function sendToFlutter(socket, message) {
  if (
    !socket ||
    socket.readyState !== WebSocket.OPEN
  ) {
    return;
  }

  try {
    socket.send(
      JSON.stringify(message)
    );
  } catch (error) {
    console.error(
      'Failed to send message to Flutter:',
      error
    );
  }
}

function sendToGrok(grokSocket, message) {
  if (
    !grokSocket ||
    grokSocket.readyState !== WebSocket.OPEN
  ) {
    console.error(
      'Cannot send to Grok: socket is not open.'
    );

    return false;
  }

  try {
    grokSocket.send(
      JSON.stringify(message)
    );

    return true;
  } catch (error) {
    console.error(
      'Failed to send message to Grok:',
      error
    );

    return false;
  }
}

/*
 * ================================================================
 * AI EVALUATOR
 * ================================================================
 *
 * Uses xAI's text Responses API.
 *
 * The voice interview continues through Grok Realtime.
 * Evaluation is a separate text-generation request.
 */
async function generateInterviewEvaluation(
  questions,
  answers
) {
  const evaluationInput = questions
    .map((question, index) => {
      const answer =
        answers[index] ||
        '(No answer recorded)';

      return `
QUESTION ${index + 1}:
${question}

CANDIDATE ANSWER ${index + 1}:
${answer}
      `.trim();
    })
    .join('\n\n------------------------------\n\n');

  const schema = {
    type: 'object',
    additionalProperties: false,
    properties: {
      overallScore: {
        type: 'integer',
      },

      technicalKnowledge: {
        type: 'integer',
      },

      communication: {
        type: 'integer',
      },

      clarity: {
        type: 'integer',
      },

      confidence: {
        type: 'integer',
      },

      summary: {
        type: 'string',
      },

      recommendations: {
        type: 'array',
        items: {
          type: 'string',
        },
      },

      questions: {
        type: 'array',
        items: {
          type: 'object',
          additionalProperties: false,
          properties: {
            questionNumber: {
              type: 'integer',
            },

            question: {
              type: 'string',
            },

            answer: {
              type: 'string',
            },

            score: {
              type: 'integer',
            },

            feedback: {
              type: 'string',
            },

            strength: {
              type: 'string',
            },

            improvement: {
              type: 'string',
            },
          },

          required: [
            'questionNumber',
            'question',
            'answer',
            'score',
            'feedback',
            'strength',
            'improvement',
          ],
        },
      },
    },

    required: [
      'overallScore',
      'technicalKnowledge',
      'communication',
      'clarity',
      'confidence',
      'summary',
      'recommendations',
      'questions',
    ],
  };

  const response = await fetch(
    'https://api.x.ai/v1/responses',
    {
      method: 'POST',

      headers: {
        'Content-Type': 'application/json',
        Authorization:
          `Bearer ${XAI_API_KEY}`,
      },

      body: JSON.stringify({
        model: EVALUATION_MODEL,

        store: false,

        input: [
          {
            role: 'system',

            content: `
You are an expert technical interviewer evaluating a Front-End Web Developer interview.

Evaluate the candidate ONLY from the five questions and five answers provided.

IMPORTANT RULES:

1. Evaluate every answer against its actual question.
2. Do not invent information that the candidate did not say.
3. Do not give credit for knowledge that is not demonstrated in the answer.
4. A short but correct answer can receive partial or good credit.
5. "I don't know" should receive a low score for that question, but do not penalize the candidate beyond that question.
6. Evaluate technical correctness, completeness, depth, communication, and clarity.
7. The overall score must reflect the actual five answers.
8. Scores must be integers from 0 to 100.
9. Return exactly five question evaluations.
10. Keep feedback useful and concise.
11. Do not compare the candidate to another person.
12. Do not fabricate an answer.
13. If the answer is partially correct, explicitly explain what was correct and what was missing.
14. The question and answer fields in the result must match the supplied data.

For each question provide:
- score
- feedback
- strength
- improvement

Also provide:
- overallScore
- technicalKnowledge
- communication
- clarity
- confidence
- summary
- recommendations

The overall score should be based primarily on the five individual question scores.
            `.trim(),
          },

          {
            role: 'user',

            content: `
Evaluate this completed five-question interview.

${evaluationInput}
            `.trim(),
          },
        ],

        text: {
          format: {
            type: 'json_schema',
            name: 'interview_evaluation',
            schema,
            strict: true,
          },
        },
      }),
    }
  );

  if (!response.ok) {
    const errorText =
      await response.text();

    throw new Error(
      `xAI evaluation request failed (${response.status}): ${errorText}`
    );
  }

  const data =
    await response.json();

  /*
   * Responses API returns generated content
   * inside output -> message -> output_text.
   */
  let outputText = '';

  if (Array.isArray(data.output)) {
    for (const item of data.output) {
      if (
        item &&
        item.type === 'message' &&
        Array.isArray(item.content)
      ) {
        for (const content of item.content) {
          if (
            content &&
            content.type === 'output_text' &&
            typeof content.text === 'string'
          ) {
            outputText += content.text;
          }
        }
      }
    }
  }

  if (!outputText) {
    /*
     * Some compatible responses expose output_text
     * directly.
     */
    if (
      typeof data.output_text === 'string'
    ) {
      outputText =
        data.output_text;
    }
  }

  if (!outputText) {
    console.error(
      'xAI evaluation response:',
      JSON.stringify(data, null, 2)
    );

    throw new Error(
      'xAI returned an empty evaluation.'
    );
  }

  let evaluation;

  try {
    evaluation =
      JSON.parse(outputText);
  } catch (error) {
    console.error(
      'Could not parse evaluator JSON:',
      outputText
    );

    throw new Error(
      'AI evaluation returned invalid JSON.'
    );
  }

  /*
   * Safety checks.
   */
  if (
    !Array.isArray(
      evaluation.questions
    )
  ) {
    throw new Error(
      'AI evaluation did not contain question results.'
    );
  }

  /*
   * The app requires exactly five results.
   */
  evaluation.questions =
    evaluation.questions.slice(
      0,
      MAX_QUESTIONS
    );

  if (
    evaluation.questions.length !==
    MAX_QUESTIONS
  ) {
    throw new Error(
      `AI evaluation returned ${evaluation.questions.length} questions instead of 5.`
    );
  }

  return evaluation;
}

wss.on(
  'connection',
  (flutterSocket) => {
    console.log('');
    console.log(
      '=========================================='
    );
    console.log(
      'Flutter voice client connected.'
    );
    console.log(
      '=========================================='
    );

    sendToFlutter(
      flutterSocket,
      {
        type: 'connected',
      }
    );

    const grokUrl =
      `wss://api.x.ai/v1/realtime?model=${encodeURIComponent(
        GROK_MODEL
      )}`;

    const grokSocket =
      new WebSocket(
        grokUrl,
        {
          headers: {
            Authorization:
              `Bearer ${XAI_API_KEY}`,
          },
        }
      );

    let grokReady = false;
    let sessionConfigured = false;

    let waitingForCommit = false;
    let responseInProgress = false;

    let interviewFinished = false;

    let evaluationStarted = false;

    let currentQuestionNumber = 0;

    const interviewQuestions = [
      'What is semantic HTML, and why is it important for web accessibility and SEO?',

      'What are the key principles of responsive web design, and how would you implement them using CSS?',

      'What is the difference between let, const, and var in JavaScript, and how does asynchronous programming work in JavaScript?',

      'How would you debug a frontend issue where a button is not working, and how do REST APIs and HTTP requests fit into a frontend application?',

      'What is React, and why is it useful for building frontend applications? Also, mention one way you would improve the performance of a React application.',
    ];

    const interviewAnswers = [];

    let currentUserTranscript = '';

    let currentAssistantTranscript = '';

    let responseRequestedForTurn = false;

    let commitReceivedForTurn = false;

    let transcriptionReceivedForTurn = false;

    let assistantAudioBytes = 0;

    function cleanText(text) {
      return String(text || '')
        .replace(/\s+/g, ' ')
        .trim();
    }

    function sendFinalInterviewResponse() {
      if (!grokReady) {
        console.log(
          'Cannot send final response: Grok is not ready.'
        );

        return;
      }

      if (responseInProgress) {
        console.log(
          'Final response skipped because Grok is already responding.'
        );

        return;
      }

      console.log('');
      console.log(
        '>>> REQUESTING FINAL INTERVIEW MESSAGE'
      );

      const sent =
        sendToGrok(
          grokSocket,
          {
            type:
              'conversation.item.create',

            item: {
              type: 'message',
              role: 'user',

              content: [
                {
                  type: 'input_text',

                  text:
                    'The five-question interview is now complete. Briefly thank the candidate and say exactly: "Thank you. That completes the interview." Do not ask another question and do not provide feedback.',
                },
              ],
            },
          }
        );

      if (!sent) {
        return;
      }

      const responseSent =
        sendToGrok(
          grokSocket,
          {
            type: 'response.create',
          }
        );

      if (responseSent) {
        responseInProgress = true;

        console.log(
          '>>> FINAL INTERVIEW RESPONSE REQUESTED'
        );
      }
    }

    async function startEvaluation() {
      if (evaluationStarted) {
        return;
      }

      evaluationStarted = true;

      const questions =
        interviewQuestions.slice(
          0,
          MAX_QUESTIONS
        );

      const answers =
        interviewAnswers.slice(
          0,
          MAX_QUESTIONS
        );

      console.log('');
      console.log(
        '=========================================='
      );
      console.log(
        ' STARTING AI INTERVIEW EVALUATION'
      );
      console.log(
        '=========================================='
      );

      try {
        const evaluation =
          await generateInterviewEvaluation(
            questions,
            answers
          );

        console.log(
          '>>> AI EVALUATION COMPLETE'
        );

        console.log(
          `>>> Overall score: ${evaluation.overallScore}`
        );

        sendToFlutter(
          flutterSocket,
          {
            type: 'evaluation_ready',

            evaluation,
          }
        );
      } catch (error) {
        console.error('');
        console.error(
          '========== AI EVALUATION ERROR =========='
        );

        console.error(
          error
        );

        console.error(
          '=========================================='
        );

        sendToFlutter(
          flutterSocket,
          {
            type: 'evaluation_error',

            message:
              error.message ||
              'Could not generate AI evaluation.',
          }
        );
      }
    }

    function resetTurnFlags() {
      commitReceivedForTurn = false;
      transcriptionReceivedForTurn = false;
      responseRequestedForTurn = false;

      currentUserTranscript = '';
      currentAssistantTranscript = '';
    }

    function sendNextQuestion() {
      if (!grokReady) {
        console.log(
          'Cannot send next question: Grok is not ready.'
        );

        return;
      }

      if (interviewFinished) {
        return;
      }

      if (responseInProgress) {
        console.log(
          'Cannot send next question: response still active.'
        );

        return;
      }

      if (currentQuestionNumber === 0) {
        currentQuestionNumber = 1;
      } else {
        currentQuestionNumber++;
      }

      if (
        currentQuestionNumber >
        MAX_QUESTIONS
      ) {
        finishInterview();
        return;
      }

      const question =
        interviewQuestions[
          currentQuestionNumber - 1
        ];

      console.log('');
      console.log(
        `>>> STARTING INTERVIEW QUESTION ${currentQuestionNumber}`
      );

      console.log(
        `>>> QUESTION: ${question}`
      );

      const sent =
        sendToGrok(
          grokSocket,
          {
            type:
              'conversation.item.create',

            item: {
              type: 'message',
              role: 'user',

              content: [
                {
                  type: 'input_text',

                  text: `
Ask the candidate this interview question exactly as written.

Do not change the question.
Do not add another question.
Do not explain the question.

Question:
${question}
                  `.trim(),
                },
              ],
            },
          }
        );

      if (!sent) {
        console.error(
          'Could not send question to Grok.'
        );

        return;
      }

      const responseSent =
        sendToGrok(
          grokSocket,
          {
            type:
              'response.create',
          }
        );

      if (responseSent) {
        responseInProgress = true;
        responseRequestedForTurn = true;

        console.log(
          `>>> QUESTION ${currentQuestionNumber} RESPONSE REQUESTED`
        );
      }
    }

    function maybeRequestNextResponse() {
      if (!grokReady) {
        return;
      }

      if (interviewFinished) {
        return;
      }

      if (!commitReceivedForTurn) {
        return;
      }

      if (!transcriptionReceivedForTurn) {
        console.log(
          'Waiting for final user transcription before response.create.'
        );

        return;
      }

      if (responseRequestedForTurn) {
        return;
      }

      if (responseInProgress) {
        return;
      }

      if (
        currentQuestionNumber >=
        MAX_QUESTIONS
      ) {
        finishInterview();

        return;
      }

      console.log(
        '>>> USER TURN FULLY PROCESSED'
      );

      console.log(
        '>>> REQUESTING NEXT INTERVIEW QUESTION'
      );

      sendNextQuestion();
    }

    function finishInterview() {
      if (interviewFinished) {
        return;
      }

      /*
       * Mark the interview complete so no additional
       * candidate microphone audio can be accepted.
       */
      interviewFinished = true;

      waitingForCommit = false;

      console.log('');
      console.log(
        '=========================================='
      );
      console.log(
        ' FIVE QUESTION INTERVIEW COMPLETE'
      );
      console.log(
        '=========================================='
      );

      console.log(
        `Questions: ${interviewQuestions.length}`
      );

      console.log(
        `Answers: ${interviewAnswers.length}`
      );

      /*
       * Send the completed Q/A set to Flutter.
       */
      sendToFlutter(
        flutterSocket,
        {
          type: 'interview_complete',

          questions:
            interviewQuestions.slice(
              0,
              MAX_QUESTIONS
            ),

          answers:
            interviewAnswers.slice(
              0,
              MAX_QUESTIONS
            ),

          questionCount:
            Math.min(
              interviewQuestions.length,
              MAX_QUESTIONS
            ),

          answerCount:
            Math.min(
              interviewAnswers.length,
              MAX_QUESTIONS
            ),
        }
      );

      /*
       * Start the AI evaluation immediately.
       *
       * This runs independently of the final Grok
       * spoken goodbye.
       */
      startEvaluation();

      /*
       * IMPORTANT:
       *
       * We explicitly request Grok's final spoken line.
       */
      sendFinalInterviewResponse();
    }

    grokSocket.on(
      'open',
      () => {
        console.log(
          'Connected to xAI Grok Realtime.'
        );

        sendToGrok(
          grokSocket,
          {
            type:
              'session.update',

            session: {
              voice: GROK_VOICE,

              instructions: `
You are the voice interviewer inside the InterviewMe app.

You are conducting a technical Front-End Web Developer interview.

IMPORTANT:

- The backend controls the interview questions.
- When the backend sends a question, speak it naturally.
- Do not change the meaning of the question.
- Do not invent additional questions.
- Do not ask follow-up questions.
- Do not ask multiple questions.
- Keep your spoken response concise.
- Do not provide the answer to the question.
- After the candidate answers, briefly acknowledge the answer only.
- The backend will provide the next question.
- Never generate an additional interview question yourself.
- When the backend explicitly tells you the interview is complete, say:
  "Thank you. That completes the interview."
- Do not ask another question after the interview is complete.
              `.trim(),

              turn_detection: null,

              audio: {
                input: {
                  format: {
                    type: 'audio/pcm',
                    rate: 24000,
                  },
                },

                output: {
                  format: {
                    type: 'audio/pcm',
                    rate: 24000,
                  },
                },
              },
            },
          }
        );
      }
    );

    grokSocket.on(
      'message',
      (data) => {
        let event;

        try {
          event = JSON.parse(
            data.toString()
          );
        } catch (error) {
          console.error(
            'Could not parse Grok message:',
            error
          );

          return;
        }

        const type = event.type;

        if (type === 'ping') {
          return;
        }

        console.log(
          `Grok event: ${type}`
        );

        switch (type) {
          case 'session.created':
            console.log(
              'Grok session created.'
            );
            break;

          case 'conversation.created':
            console.log(
              'Grok conversation created.'
            );
            break;

          case 'session.updated':
            sessionConfigured = true;
            grokReady = true;

            console.log(
              'Grok session configured successfully.'
            );

            sendToFlutter(
              flutterSocket,
              {
                type: 'ready',
              }
            );

            sendNextQuestion();

            break;

          case 'response.created':
            responseInProgress = true;

            currentAssistantTranscript = '';
            assistantAudioBytes = 0;

            sendToFlutter(
              flutterSocket,
              {
                type:
                  'speaking_started',
              }
            );

            break;

          case 'response.output_audio.delta': {
            const audio =
              event.delta;

            if (
              typeof audio !==
                'string' ||
              audio.length === 0
            ) {
              break;
            }

            assistantAudioBytes +=
              audio.length;

            sendToFlutter(
              flutterSocket,
              {
                type: 'audio',
                audio,
              }
            );

            break;
          }

          case 'response.output_audio_transcript.delta': {
            const text =
              event.delta;

            if (
              typeof text ===
                'string' &&
              text.length > 0
            ) {
              currentAssistantTranscript +=
                text;

              sendToFlutter(
                flutterSocket,
                {
                  type:
                    'assistant_text',
                  text,
                }
              );
            }

            break;
          }

          case 'response.output_audio.done':
            console.log(
              `>>> GROK AUDIO OUTPUT FINISHED (${assistantAudioBytes} base64 chars)`
            );

            sendToFlutter(
              flutterSocket,
              {
                type:
                  'speaking_stopped',
              }
            );

            break;

          case 'response.output_audio_transcript.done':
            console.log(
              'Grok audio transcript finished.'
            );

            break;

          case 'response.done':
            console.log(
              '>>> GROK RESPONSE FINISHED'
            );

            responseInProgress = false;

            sendToFlutter(
              flutterSocket,
              {
                type:
                  'response_finished',
              }
            );

            break;

          case 'input_audio_buffer.committed':
            console.log(
              '>>> USER AUDIO COMMITTED'
            );

            waitingForCommit = false;
            commitReceivedForTurn = true;

            sendToFlutter(
              flutterSocket,
              {
                type:
                  'audio_committed',
              }
            );

            maybeRequestNextResponse();

            break;

          case 'input_audio_buffer.speech_started':
            console.log(
              'Grok detected speech.'
            );
            break;

          case 'input_audio_buffer.speech_stopped':
            console.log(
              'Grok detected speech stopped.'
            );
            break;

          case 'conversation.item.added':
            console.log(
              'Grok conversation item added.'
            );
            break;

          case 'conversation.item.input_audio_transcription.updated': {
            const transcript =
              event.transcript ||
              '';

            if (transcript) {
              sendToFlutter(
                flutterSocket,
                {
                  type:
                    'user_text',
                  text: transcript,
                }
              );
            }

            break;
          }

          case 'conversation.item.input_audio_transcription.completed': {
            const transcript =
              event.transcript ||
              event.item?.content?.[0]?.transcript ||
              '';

            if (!transcript) {
              break;
            }

            currentUserTranscript =
              cleanText(
                transcript
              );

            console.log(
              `>>> USER TRANSCRIPT: ${currentUserTranscript}`
            );

            if (
              interviewAnswers.length <
              MAX_QUESTIONS
            ) {
              interviewAnswers.push(
                currentUserTranscript
              );

              console.log(
                `>>> INTERVIEW ANSWER ${interviewAnswers.length}: ${currentUserTranscript}`
              );
            }

            transcriptionReceivedForTurn =
              true;

            sendToFlutter(
              flutterSocket,
              {
                type: 'user_text',
                text:
                  currentUserTranscript,
              }
            );

            maybeRequestNextResponse();

            break;
          }

          case 'error':
            console.error('');
            console.error(
              '========== GROK ERROR =========='
            );

            console.error(
              JSON.stringify(
                event,
                null,
                2
              )
            );

            console.error(
              '================================'
            );

            responseInProgress =
              false;

            waitingForCommit =
              false;

            sendToFlutter(
              flutterSocket,
              {
                type: 'error',

                message:
                  event.error?.message ||
                  event.message ||
                  'Grok Realtime returned an error.',
              }
            );

            break;

          default:
            break;
        }
      }
    );

    grokSocket.on(
      'error',
      (error) => {
        console.error('');
        console.error(
          '========== GROK WEBSOCKET ERROR =========='
        );

        console.error(error);

        console.error(
          '=========================================='
        );

        console.error('');

        sendToFlutter(
          flutterSocket,
          {
            type: 'error',
            message:
              'Grok WebSocket error: ' +
              error.message,
          }
        );
      }
    );

    grokSocket.on(
      'close',
      (code, reason) => {
        const reasonText =
          reason
            ? reason.toString()
            : '';

        console.log('');
        console.log(
          '========== GROK WEBSOCKET CLOSED =========='
        );

        console.log(
          `Code: ${code}`
        );

        console.log(
          `Reason: ${
            reasonText || '(empty)'
          }`
        );

        console.log(
          `Questions so far: ${currentQuestionNumber}`
        );

        console.log(
          `Answers so far: ${interviewAnswers.length}`
        );

        console.log(
          '==========================================='
        );

        console.log('');

        grokReady = false;
        responseInProgress = false;
        waitingForCommit = false;

        if (
          !interviewFinished &&
          flutterSocket.readyState ===
            WebSocket.OPEN
        ) {
          sendToFlutter(
            flutterSocket,
            {
              type: 'error',

              message:
                `Grok connection closed (${code}). ` +
                'Please reconnect and try again.',
            }
          );
        }
      }
    );

    grokSocket.on(
      'unexpected-response',
      (request, response) => {
        console.error('');
        console.error(
          '====== GROK UNEXPECTED RESPONSE ======'
        );

        console.error(
          `HTTP status: ${response.statusCode}`
        );

        console.error(
          `HTTP status message: ${response.statusMessage}`
        );

        console.error(
          '======================================='
        );

        console.error('');
      }
    );

    flutterSocket.on(
      'message',
      (data) => {
        let message;

        try {
          message = JSON.parse(
            data.toString()
          );
        } catch (error) {
          console.error(
            'Could not parse Flutter message:',
            error
          );

          return;
        }

        if (
          !message ||
          typeof message !== 'object'
        ) {
          return;
        }

        switch (message.type) {
          case 'audio': {
            const audio =
              message.audio;

            if (
              typeof audio !==
                'string' ||
              audio.length === 0 ||
              !grokReady ||
              interviewFinished
            ) {
              return;
            }

            console.log(
              `Flutter audio received: ${audio.length} base64 chars`
            );

            sendToGrok(
              grokSocket,
              {
                type:
                  'input_audio_buffer.append',
                audio,
              }
            );

            break;
          }

          case 'commit': {
            if (!grokReady) {
              console.log(
                'Commit ignored because Grok is not ready.'
              );

              return;
            }

            if (interviewFinished) {
              console.log(
                'Commit ignored because interview is complete.'
              );

              return;
            }

            if (waitingForCommit) {
              console.log(
                'Commit ignored because another commit is pending.'
              );

              return;
            }

            if (responseInProgress) {
              console.log(
                'Commit ignored because Grok is still responding.'
              );

              return;
            }

            commitReceivedForTurn =
              false;

            transcriptionReceivedForTurn =
              false;

            responseRequestedForTurn =
              false;

            currentUserTranscript =
              '';

            console.log('');

            console.log(
              '>>> FLUTTER REQUESTED AUDIO COMMIT'
            );

            waitingForCommit = true;

            const sent =
              sendToGrok(
                grokSocket,
                {
                  type:
                    'input_audio_buffer.commit',
                }
              );

            if (sent) {
              console.log(
                '>>> COMMIT SENT TO GROK'
              );
            } else {
              waitingForCommit =
                false;
            }

            break;
          }

          case 'clear_audio':
            console.log(
              '>>> CLEARING GROK AUDIO BUFFER'
            );

            sendToGrok(
              grokSocket,
              {
                type:
                  'input_audio_buffer.clear',
              }
            );

            break;

          case 'cancel_response':
            console.log(
              '>>> CANCEL RESPONSE'
            );

            sendToGrok(
              grokSocket,
              {
                type:
                  'response.cancel',
              }
            );

            responseInProgress =
              false;

            break;

          default:
            console.log(
              `Unknown Flutter message type: ${message.type}`
            );

            break;
        }
      }
    );

    flutterSocket.on(
      'close',
      () => {
        console.log(
          'Flutter voice client disconnected.'
        );

        try {
          if (
            grokSocket.readyState ===
            WebSocket.OPEN
          ) {
            grokSocket.close();
          }
        } catch (_) {}
      }
    );

    flutterSocket.on(
      'error',
      (error) => {
        console.error(
          'Flutter WebSocket error:',
          error
        );

        try {
          if (
            grokSocket.readyState ===
            WebSocket.OPEN
          ) {
            grokSocket.close();
          }
        } catch (_) {}
      }
    );
  }
);

server.listen(
  PORT,
  () => {
    console.log('');

    console.log(
      '=========================================='
    );

    console.log(
      ' InterviewMe Backend'
    );

    console.log(
      '=========================================='
    );

    console.log(
      `HTTP:       http://localhost:${PORT}`
    );

    console.log(
      `WebSocket:  ws://localhost:${PORT}/voice`
    );

    console.log(
      `Grok:       ${GROK_MODEL}`
    );

    console.log(
      `Evaluator:  ${EVALUATION_MODEL}`
    );

    console.log(
      `Voice:      ${GROK_VOICE}`
    );

    console.log(
      'Firebase:   enabled'
    );

    console.log(
      'Mode:       PUSH-TO-TALK'
    );

    console.log(
      'Questions:  5'
    );

    console.log(
      'AI Eval:    enabled'
    );

    console.log(
      '=========================================='
    );

    console.log('');
  }
);