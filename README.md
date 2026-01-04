# 🌍 Smart Trip Planner

A production-ready, full-stack travel planning platform built with **Flutter** and **Django**. This application allows users to plan adventures, collaborate with friends, manage budgets, and chat in real-time.

## 🚀 Key Features

- **Auth**: Secure JWT-based authentication (Email/Password).
- **Trips**: Create, manage, and explore destinations.
- **Collaboration**: Invite friends via email to plan together.
- **Itinerary**: Drag-and-reorder items to build your perfect journey.
- **Polls**: Vote on activities and destinations with your group.
- **Real-time Chat**: In-trip messaging powered by WebSockets.
- **Budget Tracking**: Monitor expenses and stay within your trip budget.
- **Offline-First**: Secure local caching with Hive for a seamless experience even without internet.
- **Responsive UI**: Beautiful glassmorphic design that works on mobile and desktop.

## 🛠️ Technology Stack

- **Frontend**: Flutter (BLoC architecture, Hive, Dio, cached_network_image)
- **Backend**: Django & Django REST Framework (PostgreSQL, Channels, Redis, simple-jwt)
- **DevOps**: Docker, GitHub Actions (CI/CD)

## 📦 Getting Started

### Backend
1. Navigate to `/backend`.
2. Install dependencies: `pip install -r requirements.txt`.
3. Run migrations: `python manage.py migrate`.
4. Start server: `python manage.py runserver`.

### Frontend
1. Navigate to `/frontend`.
2. Get packages: `flutter pub get`.
3. Run app: `flutter run`.

## 🛡️ CI/CD
Automated pipelines are set up in `.github/workflows` to handle:
- **Backend**: Linting (flake8) and Unit Testing.
- **Frontend**: Static Analysis and Logic Testing.

---
*Developed with ❤️ for adventurous travelers.*
