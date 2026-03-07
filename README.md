<div align="center">

# 🚕 RidePin

**A full-stack ride-booking platform built for the real world.**

Connect riders and drivers through secure APIs, real-time ride lifecycle management,<br/>and an intuitive cross-platform mobile experience.

[![Laravel](https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white)](https://laravel.com)
[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Filament](https://img.shields.io/badge/Filament-FDAE4B?style=for-the-badge&logo=data:image/svg+xml;base64,&logoColor=white)](https://filamentphp.com)
[![PHP](https://img.shields.io/badge/PHP-777BB4?style=for-the-badge&logo=php&logoColor=white)](https://php.net)
[![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)](https://mysql.com)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)

<br/>

<img src="./docs/ridepin-preview.png" width="720" alt="RidePin Platform Preview"/>

<br/>

[Getting Started](#-getting-started) · [Features](#-features) · [Architecture](#-architecture) · [API Reference](#-api-reference) · [Roadmap](#-roadmap)

</div>

---

## 🎯 Overview

RidePin is a production-style ride-hailing platform demonstrating end-to-end software engineering — from database design and RESTful APIs to mobile UI and admin dashboards.

Built with a **three-tier architecture**:

| Layer | Technology | Purpose |
|:------|:-----------|:--------|
| **Backend** | Laravel + Sanctum | RESTful API, authentication, business logic |
| **Mobile** | Flutter + Provider | Cross-platform rider & driver experience |
| **Admin** | Filament | Dashboard for platform management & analytics |

---

## ✨ Features

<table>
<tr>
<td width="33%" valign="top">

### 🚗 Rider Experience
- Create & cancel ride requests
- Browse full ride history
- Rate drivers after completion
- Real-time ride status updates

</td>
<td width="33%" valign="top">

### 🧑‍✈️ Driver Experience
- Toggle availability on/off
- View nearby pending requests
- Accept → Start → Complete flow
- Track completed ride earnings

</td>
<td width="33%" valign="top">

### 🛡 Admin Panel
- Full user & ride management
- Transaction monitoring
- Ratings & reviews oversight
- Platform-wide statistics

</td>
</tr>
</table>

### 🔐 Security & Auth
- **Token-based authentication** via Laravel Sanctum
- **Role-based access control** — Rider, Driver, Admin
- Bcrypt password hashing · Form Request validation · Protected route middleware · Centralized error handling

---

## 🏗 Architecture

```
RidePin/
│
├── 🔧 Backend (Laravel API)
│   ├── app/             # Models, Controllers, Middleware, Policies
│   ├── routes/          # API route definitions
│   ├── database/        # Migrations, seeders, factories
│   └── config/          # App & service configuration
│
├── 📱 Mobile (Flutter)
│   └── mobile/ridepin/  # Dart source, screens, providers, services
│
└── 📊 Admin (Filament)
    └── Integrated within Laravel backend
```

---

## 📐 Database Schema

<div align="center">

```
┌──────────┐    ┌──────────────────┐    ┌───────────────┐
│  Roles   │◄───│      Users       │───►│Driver Profiles│
└──────────┘    └────────┬─────────┘    └───────────────┘
                         │
              ┌──────────┴──────────┐
              ▼                     ▼
        ┌──────────┐         ┌──────────┐
        │  Rides   │────────►│  Ratings  │
        └────┬─────┘         └──────────┘
             │
             ▼
      ┌──────────────┐    ┌──────────────────┐
      │ Transactions │    │ Ride Status Logs  │
      └──────────────┘    └──────────────────┘
```

</div>

**Key Relationships:**

| Entity | Relationship |
|:-------|:-------------|
| User → Role | Each user belongs to one role |
| Driver → Profile | One-to-one driver profile |
| Rider → Rides | A rider can create many rides |
| Driver → Rides | A driver can complete many rides |
| Ride → Transaction | One transaction per completed ride |
| Ride → Rating | One rating per completed ride |

---

## 🔄 Ride Lifecycle

```
  ┌─────────┐     ┌──────────┐     ┌─────────────┐     ┌───────────┐
  │ PENDING  │────►│ ACCEPTED │────►│ IN PROGRESS │────►│ COMPLETED │
  └────┬─────┘     └──────────┘     └─────────────┘     └─────┬─────┘
       │                                                       │
       ▼                                                       ▼
  ┌───────────┐                                        ┌──────────────┐
  │ CANCELLED │                                        │  TRANSACTION │
  └───────────┘                                        │  + RATING    │
                                                       └──────────────┘
```

| Step | Actor | Action | Status |
|:----:|:------|:-------|:-------|
| 1 | Rider | Creates ride request | `pending` |
| 2 | Driver | Accepts the ride | `accepted` |
| 3 | Driver | Starts the ride | `in_progress` |
| 4 | Driver | Completes the ride | `completed` |
| 5 | System | Generates transaction | — |
| 6 | Rider | Rates the driver | — |

---

## 🔌 API Reference

### Authentication

| Method | Endpoint | Description | Auth |
|:------:|:---------|:------------|:----:|
| `POST` | `/api/register` | Register a new user | ✗ |
| `POST` | `/api/login` | Authenticate & receive token | ✗ |
| `POST` | `/api/logout` | Revoke current token | ✓ |
| `GET` | `/api/profile` | Retrieve authenticated user | ✓ |

### Rider Endpoints

| Method | Endpoint | Description | Auth |
|:------:|:---------|:------------|:----:|
| `GET` | `/api/rides` | List rider's rides | ✓ |
| `POST` | `/api/rides` | Create a new ride request | ✓ |
| `POST` | `/api/rides/{id}/cancel` | Cancel a pending ride | ✓ |

### Driver Endpoints

| Method | Endpoint | Description | Auth |
|:------:|:---------|:------------|:----:|
| `GET` | `/api/driver/rides/available` | List available ride requests | ✓ |
| `POST` | `/api/driver/rides/{id}/accept` | Accept a ride | ✓ |
| `POST` | `/api/driver/rides/{id}/start` | Start an accepted ride | ✓ |
| `POST` | `/api/driver/rides/{id}/complete` | Complete an active ride | ✓ |
| `POST` | `/api/driver/toggle-availability` | Toggle driver availability | ✓ |

---

## 🚀 Getting Started

### Prerequisites

- **PHP** ≥ 8.1 · **Composer** · **MySQL** · **Node.js**
- **Flutter SDK** ≥ 3.x · **Dart**

### Backend Setup

```bash
# Clone the repository
git clone https://github.com/mazen-naji/ridepin-platform.git
cd ridepin-platform

# Install dependencies
composer install

# Configure environment
cp .env.example .env
php artisan key:generate

# Set up database
php artisan migrate --seed

# Start the server
php artisan serve
```

### Mobile Setup

```bash
cd mobile/ridepin

# Install dependencies
flutter pub get

# Launch the app
flutter run
```

### Demo Credentials

| Role | Email | Password |
|:-----|:------|:---------|
| Admin | `admin@ridepin.com` | `password123` |

---

## 🛠 Built With

<table>
<tr>
<td align="center" width="96">
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/laravel/laravel-original.svg" width="40" height="40" alt="Laravel"/>
<br/><sub><b>Laravel</b></sub>
</td>
<td align="center" width="96">
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/php/php-original.svg" width="40" height="40" alt="PHP"/>
<br/><sub><b>PHP</b></sub>
</td>
<td align="center" width="96">
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/mysql/mysql-original.svg" width="40" height="40" alt="MySQL"/>
<br/><sub><b>MySQL</b></sub>
</td>
<td align="center" width="96">
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/flutter/flutter-original.svg" width="40" height="40" alt="Flutter"/>
<br/><sub><b>Flutter</b></sub>
</td>
<td align="center" width="96">
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/dart/dart-original.svg" width="40" height="40" alt="Dart"/>
<br/><sub><b>Dart</b></sub>
</td>
<td align="center" width="96">
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/git/git-original.svg" width="40" height="40" alt="Git"/>
<br/><sub><b>Git</b></sub>
</td>
<td align="center" width="96">
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/vscode/vscode-original.svg" width="40" height="40" alt="VS Code"/>
<br/><sub><b>VS Code</b></sub>
</td>
</tr>
</table>

---

## 📈 Roadmap

- [ ] Google Maps integration with live route display
- [ ] Real-time driver location tracking via WebSockets
- [ ] Push notifications (Firebase Cloud Messaging)
- [ ] Online payment gateway (Stripe / PayPal)
- [ ] Dynamic ride fare estimation
- [ ] Advanced analytics dashboard
- [ ] Multi-language support (i18n)
- [ ] Ride scheduling (book in advance)

---

## 👨‍💻 Author

<table>
<tr>
<td align="center">
<b>Mazen Naji</b>
<br/>
Software Engineer · Full Stack & Mobile Developer
<br/><br/>
<a href="https://github.com/Mazennaji">
<img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white" alt="GitHub"/>
</a>
<a href="https://www.linkedin.com/in/mazen-naji/">
<img src="https://img.shields.io/badge/LinkedIn-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white" alt="LinkedIn"/>
</a>
</td>
</tr>
</table>

---

<div align="center">

**If you found this project useful, consider giving it a ⭐**

<br/>

Made with ❤️ by [Mazen Naji](https://github.com/mazen-naji)

</div>
