<div align="center">

# 🚕 RidePin

**A full-stack ride-booking platform — Laravel API, Flutter app, and a Filament admin panel.**

Riders book rides, drivers accept and complete them, transactions and ratings
are generated automatically, and admins oversee everything from a dashboard.

![Laravel](https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Filament](https://img.shields.io/badge/Filament-FDAE4B?style=for-the-badge&logoColor=white)
![PHP](https://img.shields.io/badge/PHP-777BB4?style=for-the-badge&logo=php&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

</div>

---

## Overview

RidePin is a three-tier ride-hailing platform built end to end:

| Layer | Technology | Purpose |
|:------|:-----------|:--------|
| **Backend** | Laravel + Sanctum | RESTful API, token auth, ride lifecycle, transactions |
| **Mobile** | Flutter + Provider + Dio | Cross-platform rider & driver app |
| **Admin** | Filament | Dashboard for managing users, rides, transactions & ratings |

The mobile app talks to the Laravel API over token-authenticated REST. Completing
a ride automatically generates a transaction; riders can then rate their driver.

---

## Features

**Rider**
- Register / log in, session persisted on device
- Book a ride with pickup & drop-off
- View current ride and full ride history
- Cancel a pending ride
- Rate the driver after completion

**Driver**
- Toggle availability (online / offline)
- Browse nearby pending ride requests
- Accept → Start → Complete lifecycle with a live status timeline
- See the generated transaction on completion

**Admin (Filament)**
- Manage users, driver profiles, rides, transactions and ratings
- Oversee the full platform from one dashboard

**Security**
- Token authentication via Laravel Sanctum
- Role-based access (rider / driver / admin)
- Form Request validation, authorization policies, hashed passwords

---

## Ride Lifecycle

```
pending ──► accepted ──► started ──► completed ──► transaction + rating
   │
   └──► cancelled
```

| Step | Actor | Action | Status |
|:----:|:------|:-------|:-------|
| 1 | Rider | Creates ride request | `pending` |
| 2 | Driver | Accepts the ride | `accepted` |
| 3 | Driver | Starts the ride | `started` |
| 4 | Driver | Completes the ride | `completed` |
| 5 | System | Generates transaction | — |
| 6 | Rider | Rates the driver | — |

---

## API Reference

### Authentication
| Method | Endpoint | Auth |
|:------:|:---------|:----:|
| `POST` | `/api/register` | ✗ |
| `POST` | `/api/login` | ✗ |
| `POST` | `/api/logout` | ✓ |
| `GET` | `/api/profile` | ✓ |

### Rider
| Method | Endpoint | Auth |
|:------:|:---------|:----:|
| `GET` | `/api/rides` | ✓ |
| `GET` | `/api/rides/{id}` | ✓ |
| `POST` | `/api/rides` | ✓ |
| `POST` | `/api/rides/{id}/cancel` | ✓ |
| `POST` | `/api/rides/{id}/rate` | ✓ |

Rating body: `{ "score": 5, "comment": "Great driver!" }`

### Driver
| Method | Endpoint | Auth |
|:------:|:---------|:----:|
| `GET` | `/api/driver/rides/available` | ✓ |
| `POST` | `/api/driver/rides/{id}/accept` | ✓ |
| `POST` | `/api/driver/rides/{id}/start` | ✓ |
| `POST` | `/api/driver/rides/{id}/complete` | ✓ |
| `POST` | `/api/driver/toggle-availability` | ✓ |

---

## Getting Started

### Prerequisites
- PHP ≥ 8.1, Composer, MySQL, Node.js
- Flutter SDK ≥ 3.x, Dart

### Backend

```bash
git clone https://github.com/<YOUR-GITHUB-USERNAME>/ridepin-platform.git
cd ridepin-platform

composer install
cp .env.example .env
php artisan key:generate

# set your DB credentials in .env, then:
php artisan migrate:fresh --seed
php artisan serve
```

The admin panel is available at `http://127.0.0.1:8000/admin`.

### Mobile

```bash
cd mobile/ridepin
flutter pub get
flutter run
```

Set the API base URL in `lib/core/constants/api_constants.dart` to match how you run:
- **Web (Chrome):** `http://127.0.0.1:8000/api`
- **Android emulator:** `http://10.0.2.2:8000/api`
- **Physical device:** `http://<YOUR-PC-LAN-IP>:8000/api`

### Demo Credentials
| Role | Email | Password |
|:-----|:------|:---------|
| Admin | `admin@ridepin.com` | `password123` |
| Rider | `rider@ridepin.com` | `password123` |
| Driver | `driver@ridepin.com` | `password123` |

---

## Tech Stack

**Backend:** Laravel, Sanctum, MySQL, Filament
**Mobile:** Flutter, Dart, Provider (state), Dio (HTTP), SharedPreferences (storage)
**Tooling:** Postman, Laragon, VS Code

---

## Roadmap

- [ ] Google Maps integration with live routes
- [ ] Real-time driver location tracking
- [ ] Push notifications (FCM)
- [ ] Online payments (Stripe / PayPal)
- [ ] Dynamic fare estimation
- [ ] Ride scheduling

---

## Author

**Mazen Naji** — Full-Stack & Mobile Developer

[GitHub](https://github.com/Mazennaji) · [LinkedIn](https://www.linkedin.com/in/mazen-naji/)

---

<div align="center">
Made with ❤️ using Laravel & Flutter
</div>
