# Ship App

A modern logistics & shipping Flutter application backed by a Node.js + Express + MongoDB authentication server.

## Features

- **Branded Design & Theme**: The application theme matches the `interviewme-logo-v8.png` color scheme (Midnight Dark, Electric Cyan `#38BDF8`, Royal Blue `#3B82F6`, and Violet `#A855F7`).
- **Animated Full-Screen Background**: Login screen features custom animated glowing ambient orbs and floating particle dots built with Flutter's `CustomPainter` and `AnimationController`.
- **MongoDB Authentication**: Production-ready password hashing (`bcryptjs`), Mongoose User model, RESTful login API, and safe seed user management.
- **Responsive Layout**: Responsive login and home dashboard layouts for both Web/Desktop and Mobile.

---

## Development Credentials

- **Email**: `alex@example.com`
- **Password**: `password123`

---

## Getting Started

### 1. Prerequisites

- **Node.js** (v18+)
- **MongoDB** (running locally on port 27017 or remote instance)
- **Flutter SDK** (v3.12+)

---

## Backend Setup & Services

### Step A: Configure Environment Variables

The backend uses environment variables. A default `.env` file is configured in `backend/.env`:

```env
PORT=5000
MONGODB_URI=mongodb://127.0.0.1:27017/ship_app
NODE_ENV=development
```

### Step B: Install Backend Dependencies

```bash
cd backend
npm install
```

### Step C: Seed Development Database User

Run the idempotent seed script to create/update the development test user securely (passwords hashed with `bcrypt`):

```bash
npm run seed
```

### Step D: Run Backend Tests

```bash
npm test
```

### Step E: Start Backend Server

```bash
npm start
```

The Express server will start listening at `http://localhost:5000`.

---

## Flutter Application Setup

### Step A: Run Flutter Widget Tests

From the project root:

```bash
flutter test
```

### Step B: Run Flutter App in Browser (Chrome)

```bash
flutter run -d chrome
```

---

## Backend Architecture Summary

- **Framework**: Express.js with CORS enabled for Web requests.
- **Database**: MongoDB using Mongoose schema (`User`).
- **Authentication**: `POST /api/auth/login` endpoint verifying hashed password credentials via `bcrypt.compare`.
- **Security**: No plaintext passwords in database, environment variable configuration, separate backend directory outside Flutter `lib/`.
