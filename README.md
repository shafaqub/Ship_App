# InterviewMe

**InterviewMe** is an AI-powered mock interview application built with **Flutter, Node.js, Firebase, and xAI Grok**.

It provides a voice-based technical interview experience where the AI interviewer asks questions, listens to the candidate's answers, and generates an AI-powered performance evaluation.

---

## Tech Stack

### Frontend

* Flutter
* Dart
* WebSocket
* Audio recording and playback
* Firebase
* RevenueCat

### Backend

* Node.js
* Express.js
* WebSocket (`ws`)
* Firebase Admin SDK
* xAI Grok
* CORS
* dotenv
* bcryptjs
* Nodemailer

---

## Project Structure

```text
Ship_App/
│
├── android/
├── ios/
├── assets/
│
├── lib/
│   ├── config/
│   ├── screens/
│   ├── services/
│   ├── widgets/
│   ├── main.dart
│   └── splash_screen.dart
│
├── backend/
│   ├── src/
│   ├── package.json
│   ├── package-lock.json
│   └── server.js
│
├── pubspec.yaml
├── pubspec.lock
├── .gitignore
└── README.md
```

---

# Requirements

Install these before setting up the project:

* **Git**
* **Flutter SDK**
* **Dart** — included with Flutter
* **Node.js LTS**
* **npm** — included with Node.js
* **Android Studio**
* **Android SDK**
* **Android Emulator** or a physical Android device

Verify the installations:

```bash
git --version
node --version
npm --version
flutter --version
dart --version
flutter doctor
```

Resolve any required issues reported by:

```bash
flutter doctor
```

---

# Installation

## 1. Clone the repository

```bash
git clone https://github.com/shafaqub/Ship_App.git
cd Ship_App
```

---

## 2. Install Flutter dependencies

From the project root:

```bash
flutter pub get
```

---

## 3. Install backend dependencies

Enter the backend directory:

```bash
cd backend
```

Install all required Node.js packages:

```bash
npm install
```

Do not install the backend packages individually. They are already defined in `backend/package.json`.

---

## 4. Add private configuration

Private configuration files are provided separately and are **not included in the GitHub repository**.

Place the provided backend environment file here:

```text
backend/.env
```

If Firebase Admin credentials are required for your setup, place the provided service-account file here:

```text
backend/firebase-service-account.json
```

Do not modify the file names or locations unless the backend configuration is changed accordingly.

---

# Run the Project

The application requires both the **Node.js backend** and **Flutter frontend**.

## Terminal 1 — Backend

From the project root:

```bash
cd backend
npm start
```

The backend runs on:

```text
http://localhost:5000
```

The voice WebSocket endpoint is:

```text
ws://localhost:5000/voice
```

Keep this terminal running.

---

## Terminal 2 — Flutter

Open a second terminal and return to the project root:

```bash
cd Ship_App
```

Check available devices:

```bash
flutter devices
```

Run the application:

```bash
flutter run
```

---

# Android Emulator

When running the Flutter application on an Android Emulator, use:

```text
10.0.2.2
```

to access the backend running on the development computer.

The Flutter WebSocket connection should therefore use:

```text
ws://10.0.2.2:5000/voice
```

Do not use `localhost` for the Android Emulator connection.

```text
Android Emulator
       │
       │ 10.0.2.2:5000
       ▼
Development Computer
       │
       ▼
Node.js Backend
       │
       ▼
xAI Grok
```

For a physical Android device, the computer and phone must be connected to the same network, and the backend address should use the computer's local network IP.

---

# Backend Health Check

With the backend running, open another terminal and run:

```bash
curl http://localhost:5000/health
```

You can also open:

```text
http://localhost:5000/health
```

in a browser.

A successful response confirms that the backend is running.

---

# Application Flow

```text
Login
  ↓
Home
  ↓
Start Interview
  ↓
AI Question
  ↓
User Voice Answer
  ↓
Next Question
  ↓
Five Questions Completed
  ↓
AI Evaluation
  ↓
Overall Results
  ↓
Question Analysis
```

The current interview contains five Front-End Web Development questions covering:

1. Semantic HTML, accessibility, and SEO
2. Responsive web design and CSS
3. JavaScript fundamentals and asynchronous JavaScript
4. Frontend debugging, REST APIs, and HTTP
5. React and frontend performance

---

# Voice Interview

InterviewMe uses a push-to-talk interaction.

```text
Tap Microphone
      ↓
Record Answer
      ↓
Stop Recording
      ↓
Send Audio
      ↓
AI Processes Response
      ↓
Next Question
```

The Flutter application communicates with the Node.js backend through WebSockets. The backend handles the communication with the AI voice service.

---

# AI Evaluation

After all five questions are completed, the backend evaluates the candidate's actual answers.

The results can include:

* Overall score
* Technical knowledge
* Communication
* Clarity
* Confidence
* Summary
* Recommendations
* Individual question scores
* Question-specific feedback
* Strengths
* Areas for improvement

The evaluation is displayed in the Flutter results screens.

---

# Firebase

Firebase is used by the application for backend services.

Flutter platform configuration is provided separately when required.

For Android, the Firebase configuration file is normally located at:

```text
android/app/google-services.json
```

For iOS:

```text
ios/Runner/GoogleService-Info.plist
```

The Node.js backend uses Firebase Admin through its separately provided service-account configuration.

---

# RevenueCat

RevenueCat is used for premium subscription functionality.

The Flutter project uses:

```text
purchases_flutter
purchases_ui_flutter
```

RevenueCat configuration and subscription products are managed separately from the public repository.

---

# Troubleshooting

## Flutter dependencies fail

Run:

```bash
flutter clean
flutter pub get
```

Then:

```bash
flutter run
```

---

## Android build fails

First run:

```bash
flutter doctor
```

Then:

```bash
flutter clean
flutter pub get
flutter run
```

Make sure Android Studio, the Android SDK, and the required SDK platform/build tools are installed.

---

## Backend dependencies fail

From the `backend` directory:

### Git Bash

```bash
rm -rf node_modules
npm install
npm start
```

### PowerShell

```powershell
Remove-Item -Recurse -Force node_modules
npm install
npm start
```

---

## Backend does not start

Make sure you are inside the backend directory:

```bash
cd backend
```

Then:

```bash
npm install
npm start
```

Check:

```text
http://localhost:5000/health
```

---

## Flutter cannot connect to backend

For Android Emulator, verify that the application uses:

```text
ws://10.0.2.2:5000/voice
```

and that the backend is running.

---

## Microphone does not work

Check that microphone permission has been granted to the emulator or physical device, then restart:

```bash
flutter run
```

---

# Development Commands

### Flutter

```bash
flutter pub get
flutter doctor
flutter devices
flutter run
flutter clean
flutter build apk
```

### Backend

```bash
cd backend
npm install
npm start
npm run dev
```

### Git

```bash
git status
git pull origin main
```

---

# Security

Private credentials are intentionally excluded from this repository.

Do not commit:

```text
backend/.env
backend/firebase-service-account.json
backend/node_modules/
```

Private configuration is provided separately to authorized developers.

---

# Quick Start

For a new development machine:

```bash
git clone https://github.com/shafaqub/Ship_App.git
cd Ship_App

flutter pub get

cd backend
npm install
```

Add the privately provided configuration files to `backend/`, then start the backend:

```bash
npm start
```

Open a second terminal:

```bash
cd Ship_App
flutter run
```

For Android Emulator, use:

```text
ws://10.0.2.2:5000/voice
```

The project is now ready for development and testing.

---

## Shipaton 2026

**InterviewMe — AI Mock Interview Application**
