# 🪵 WOOD CARVERS — Full-Stack E-Commerce Platform

Production-ready, full-stack e-commerce application for **WOOD CARVERS**, a brand specializing in small-to-medium handcrafted wooden decorative products (Wall hangings, wooden toys, picture frames, decorative stands, statues, sculptures, small decor, and gifts).

---

## 📑 Table of Contents

1. [Project Architecture](#1-project-architecture)
2. [Flutter Setup](#2-flutter-setup)
3. [Backend Setup](#3-backend-setup)
4. [MongoDB Setup](#4-mongodb-setup)
5. [Cloudinary Setup](#5-cloudinary-setup)
6. [Firebase / FCM Setup](#6-firebase--fcm-setup)
7. [Razorpay Setup](#7-razorpay-setup)
8. [Environment Variables](#8-environment-variables)
9. [Local Development](#9-local-development)
10. [Web Development](#10-web-development)
11. [Android Build](#11-android-build)
12. [Production Build](#12-production-build)
13. [Deployment](#13-deployment)
14. [API Structure](#14-api-structure)
15. [Admin Login Setup](#15-admin-login-setup)
16. [Database Setup & Seed Data](#16-database-setup--seed-data)
17. [Security Considerations](#17-security-considerations)

---

## 1. Project Architecture

The application is structured into two main components:
- **`backend/`**: Node.js & Express REST API using an MVC/Service-oriented architecture with MongoDB/Mongoose.
- **`frontend/`**: Multi-platform Flutter application powering the Customer Storefront (Web & Mobile) and the Admin Management Panel with reactive state management via **Riverpod**.

```
woodcarvers/
├── backend/
│   ├── src/
│   │   ├── config/             # DB, Cloudinary, Razorpay, FCM, ENV loaders
│   │   ├── controllers/        # REST route controllers
│   │   ├── middleware/         # JWT Auth, RBAC, Rate Limiting, Error handling
│   │   ├── models/             # Mongoose schemas (User, Product, Order, etc.)
│   │   ├── routes/             # Express route modules
│   │   ├── scripts/            # DB seed script & verification tests
│   │   ├── services/           # Business logic, payments, push notifications
│   │   ├── utils/              # Response envelopes, logger, seed data
│   │   ├── app.js              # Express app definition with Helmet & CORS
│   │   └── server.js           # Server listen & graceful shutdown
│   ├── .env.example
│   └── package.json
│
├── frontend/
│   ├── lib/
│   │   ├── core/
│   │   │   ├── animations/     # Signature wood-grain transitions & micro-interactions
│   │   │   ├── config/         # API Base URL & Razorpay Key ID
│   │   │   ├── constants/      # App constants & material listings
│   │   │   ├── network/        # Centralized ApiClient & Error handling
│   │   │   ├── theme/          # Wood Carvers palette & typography
│   │   │   ├── utils/          # Responsive breakpoints & formatters
│   │   │   └── widgets/        # Buttons, text fields, product cards, navbar, footer
│   │   ├── features/
│   │   │   ├── admin/          # Admin Dashboard, Products, Orders, Customers
│   │   │   ├── auth/           # Login & Register
│   │   │   ├── cart/           # Cart with live server revalidation
│   │   │   ├── checkout/       # Multi-step checkout with Razorpay
│   │   │   ├── home/           # Hero, Brand story, Featured, Categories
│   │   │   ├── orders/         # Orders list & Visual tracking timeline
│   │   │   ├── product_details/# Image gallery, specs, and verified reviews
│   │   │   ├── profile/        # Customer address book & profile
│   │   │   ├── shop/           # Catalog with search, filters & sort
│   │   │   └── wishlist/       # Saved items
│   │   ├── models/             # Strongly-typed Dart models
│   │   ├── providers/          # Riverpod StateNotifier providers
│   │   ├── routing/            # GoRouter with route guards
│   │   └── main.dart           # App entry point
│   ├── web/
│   │   └── index.html          # Web entry with preconnected Google Fonts & meta
│   └── pubspec.yaml
│
└── README.md
```

---

## 2. Flutter Setup

### Prerequisites
- Install Flutter SDK (3.19+ recommended): [https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)
- Verify installation:
  ```bash
  flutter doctor
  ```

### Install Dependencies
Navigate to `frontend/` and fetch the packages:
```bash
cd frontend
flutter pub get
```

---

## 3. Backend Setup

### Prerequisites
- Node.js (v18 or v20+ LTS recommended, v24 supported)
- npm (v9+ or v11+)

### Install Dependencies
Navigate to `backend/` and run:
```bash
cd backend
npm install
```

---

## 4. MongoDB Setup

1. **Local MongoDB**:
   - Ensure MongoDB daemon is running:
     ```bash
     mongod --dbpath /path/to/data/db
     ```
   - Set in `backend/.env`:
     ```env
     MONGODB_URI=mongodb://127.0.0.1:27017/woodcarvers
     ```

2. **MongoDB Atlas (Cloud)**:
   - Create a free M0 cluster at [https://cloud.mongodb.com](https://cloud.mongodb.com).
   - In "Network Access", allow your IP address or `0.0.0.0/0`.
   - Copy the connection string and update `MONGODB_URI` in `backend/.env`:
     ```env
     MONGODB_URI=mongodb+srv://<username>:<password>@cluster0.mongodb.net/woodcarvers?retryWrites=true&w=majority
     ```

---

## 5. Cloudinary Setup

1. Sign up for a free Cloudinary account at [https://cloudinary.com](https://cloudinary.com).
2. Go to the **Dashboard** to find your **Cloud Name**, **API Key**, and **API Secret**.
3. Add to `backend/.env`:
   ```env
   CLOUDINARY_CLOUD_NAME=your_cloud_name
   CLOUDINARY_API_KEY=your_api_key
   CLOUDINARY_API_SECRET=your_api_secret
   ```
4. *Note: If Cloudinary credentials are not configured, the backend runs in mock simulation mode automatically.*

---

## 6. Firebase / FCM Setup

1. Go to the [Firebase Console](https://console.firebase.google.com/) and create a project: **Wood Carvers**.
2. Navigate to **Project Settings > Service Accounts**.
3. Click **Generate New Private Key** to download the JSON credentials.
4. Extract the following fields into `backend/.env`:
   ```env
   FIREBASE_PROJECT_ID=your_project_id
   FIREBASE_CLIENT_EMAIL=firebase-adminsdk@your_project_id.iam.gserviceaccount.com
   FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
   ```
5. Devices register their FCM tokens via `POST /api/auth/device-token`. Push notifications are dispatched whenever an order status is updated by the admin (`Confirmed`, `Packed`, `Shipped`, `Delivered`).

---

## 7. Razorpay Setup

1. Sign up at [https://razorpay.com](https://razorpay.com) and navigate to **Settings > API Keys**.
2. Generate test keys (`Key ID` and `Key Secret`).
3. Add to `backend/.env`:
   ```env
   RAZORPAY_KEY_ID=rzp_test_xxxxxx
   RAZORPAY_KEY_SECRET=your_razorpay_secret
   ```
4. Update the frontend `AppConfig` or pass via `--dart-define=RAZORPAY_KEY_ID=rzp_test_xxxxxx`.
5. **Security**: The backend validates product prices and inventory, computes the final payable amount, creates the Razorpay order, and verifies the HMAC-SHA256 signature upon completion. Frontend amounts are never trusted.

---

## 8. Environment Variables

Create a `backend/.env` file based on `backend/.env.example`:

```env
NODE_ENV=development
PORT=5000
MONGODB_URI=mongodb://127.0.0.1:27017/woodcarvers
JWT_SECRET=woodcarvers_super_secure_jwt_secret_change_in_production_982347923
JWT_EXPIRE=7d

CLOUDINARY_CLOUD_NAME=your_cloudinary_cloud_name
CLOUDINARY_API_KEY=your_cloudinary_api_key
CLOUDINARY_API_SECRET=your_cloudinary_api_secret

RAZORPAY_KEY_ID=rzp_test_your_razorpay_key_id
RAZORPAY_KEY_SECRET=your_razorpay_key_secret

FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_CLIENT_EMAIL=your_firebase_client_email
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nyour_private_key_here\n-----END PRIVATE KEY-----\n"

FRONTEND_URL=*
```

---

## 9. Local Development

### 1. Start Backend
```bash
cd backend
npm run dev
# Server runs on http://localhost:5000
# API Health: http://localhost:5000/api/health
```

### 2. Seed Initial Database
```bash
cd backend
npm run seed
```

### 3. Run Flutter Application
```bash
cd frontend
flutter run -d chrome
```

---

## 10. Web Development

To run the Flutter Web application locally:
```bash
cd frontend
flutter run -d chrome --web-port=3000 --dart-define=API_BASE_URL=http://localhost:5000/api
```
The application features responsive breakpoints:
- **Desktop** (> 1100px): Full horizontal navigation, 4-column product grid, sticky sidebar filters, side-by-side checkout and admin tables.
- **Tablet** (768px – 1100px): 3-column grid, compact headers.
- **Mobile** (< 768px): Hamburger drawer, 2-column card grid, bottom action sheets.

---

## 11. Android Build

```bash
cd frontend
flutter build apk --release --dart-define=API_BASE_URL=https://api.woodcarvers.com/api
```
Output APK location: `frontend/build/app/outputs/flutter-apk/app-release.apk`

---

## 12. Production Build

### Backend Production
```bash
cd backend
NODE_ENV=production npm start
```

### Flutter Web Production Bundle
```bash
cd frontend
flutter build web --release --dart-define=API_BASE_URL=https://api.woodcarvers.com/api
```
Output files will be located in `frontend/build/web/`.

---

## 13. Deployment

1. **Backend Deployment (Render / Railway / DigitalOcean)**:
   - Build Command: `npm install`
   - Start Command: `npm start`
   - Set all variables from `.env.example` in your dashboard.

2. **Frontend Deployment (Vercel / Netlify / Firebase Hosting)**:
   - Deploy the `frontend/build/web` directory.
   - For single-page app routing on Netlify, add a `_redirects` file:
     ```
     /*    /index.html   200
     ```

---

## 14. API Structure

| Method | Endpoint | Description | Auth |
|---|---|---|---|
| `GET` | `/api/health` | Service health status | Public |
| `POST` | `/api/auth/register` | Register customer account | Public |
| `POST` | `/api/auth/login` | Authenticate customer/admin | Public |
| `GET` | `/api/auth/me` | Fetch authenticated profile | Bearer |
| `POST` | `/api/auth/address` | Add shipping address | Bearer |
| `GET` | `/api/products` | Paginated product search & filters | Public |
| `GET` | `/api/products/:id` | Detailed product specifications | Public |
| `GET` | `/api/categories` | List active categories | Public |
| `GET` | `/api/cart` | Get recalculated cart | Bearer |
| `POST` | `/api/cart/add` | Add product to bag with stock check | Bearer |
| `POST` | `/api/orders/checkout` | Create order with price validation | Bearer |
| `POST` | `/api/payments/create-order` | Initiate Razorpay transaction | Bearer |
| `POST` | `/api/payments/verify` | Verify cryptographic HMAC signature | Bearer |
| `GET` | `/api/admin/dashboard` | KPI metrics, sales, stock alerts | Admin |
| `POST` | `/api/admin/products` | Create handcrafted product | Admin |
| `PUT` | `/api/admin/orders/:id/status` | Update order state + FCM trigger | Admin |

---

## 15. Admin Login Setup

The database seeder automatically initializes the master administrator account:

- **Admin Portal Route**: `/admin` (or click *Admin Portal* in the website footer)
- **Admin Email**: `admin@woodcarvers.com`
- **Admin Password**: `Admin@123456`

*(For customer testing, use `customer@woodcarvers.com` / `Customer@123456`)*

---

## 16. Database Setup & Seed Data

The database includes small and medium handcrafted wooden decorative products:
- Wall Hangings (Tree of Life Medallions, Geometric Mandalas, Jharokha Frames)
- Wooden Toys (Rocking Horse figurines, Channapatna stacking rings)
- Frames (Carved Rosewood & Teakwood double picture frames)
- Decorative Stands (Pillar candle stands, Rehal book & tablet stands)
- Statues (Prosperity Elephant, Meditating Buddha)
- Sculptures (Interlocking Ribbon Möbius wood sculptures)
- Home Décor (Coaster sets with caddies, Incense burner boxes)
- Gifts (Handcrafted memory boxes with brass inlay)

To re-seed the database at any time:
```bash
cd backend
npm run seed
```

---

## 17. Security Considerations

1. **Zero-Trust Pricing**: The backend recalculates product prices and checks current stock directly from MongoDB. Frontend-provided price tags are ignored during checkout.
2. **Cryptographic Payment Verification**: Payment capture requires valid HMAC-SHA256 verification using the secret `RAZORPAY_KEY_SECRET`. Orders are never marked as paid based solely on frontend status.
3. **Role-Based Access Control (RBAC)**: All administrative endpoints (`/api/admin/*`) require a signed JWT token with `role: 'ADMIN'`. Non-admin users receive a `403 Forbidden` response.
4. **Credential Isolation**: Razorpay secret keys, Cloudinary API secrets, MongoDB credentials, and Firebase private keys reside strictly in backend environment variables and are never sent to Flutter clients.
5. **Rate Limiting & Protection**: Helmet security headers, CORS origin restriction, and `express-rate-limit` protect the authentication and catalog endpoints against brute-force attacks.
#   W o o d C a r v e r s 2 . 0  
 