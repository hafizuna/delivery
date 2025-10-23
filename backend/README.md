# Foodie Delivery System - Node.js Backend API

## 🚀 Setup Complete!

The backend server is successfully running with:
- ✅ **MySQL Database** (XAMPP) - Database: `delivery`
- ✅ **Prisma ORM** - Schema migrated
- ✅ **Express.js** server on port 3000
- ✅ **Socket.IO** for real-time features
- ✅ **JWT Authentication** with phone + password
- ✅ **File upload** support (local /uploads directory)

---

## 📋 Quick Start

### 1. Start XAMPP
Make sure MySQL is running in XAMPP.

### 2. Start Development Server
```bash
npm run dev
```

### 3. Check Health Status
```bash
curl http://localhost:3000/health
```

---

## 🔐 Authentication API Endpoints

### Base URL
```
http://localhost:3000/api/v1
```

### 1. Register New User
**POST** `/auth/register`

**Request Body:**
```json
{
  "phoneNumber": "1234567890",
  "countryCode": "+1",
  "password": "password123",
  "firstName": "John",
  "lastName": "Doe",
  "role": "customer",
  "email": "john@example.com",
  "fcmToken": "optional_fcm_token"
}
```

**Response:**
```json
{
  "message": "Registration successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid",
    "phoneNumber": "+11234567890",
    "countryCode": "+1",
    "firstName": "John",
    "lastName": "Doe",
    "email": "john@example.com",
    "role": "customer",
    "walletAmount": 0,
    "active": true
  }
}
```

**Valid Roles:**
- `customer` - For customer app users
- `driver` - For delivery drivers
- `restaurant` - For restaurant owners
- `admin` - For admin panel users

---

### 2. Login
**POST** `/auth/login`

**Request Body:**
```json
{
  "phoneNumber": "1234567890",
  "countryCode": "+1",
  "password": "password123",
  "fcmToken": "optional_fcm_token"
}
```

**Response:**
```json
{
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid",
    "phoneNumber": "+11234567890",
    "firstName": "John",
    "lastName": "Doe",
    "role": "customer",
    "walletAmount": 0,
    "shippingAddresses": []
  }
}
```

---

### 3. Refresh Token
**POST** `/auth/refresh`

**Request Body:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response:**
```json
{
  "token": "new_access_token_here",
  "message": "Token refreshed successfully"
}
```

---

### 4. Logout
**POST** `/auth/logout`

**Headers:**
```
Authorization: Bearer <your_access_token>
```

**Response:**
```json
{
  "message": "Logged out successfully"
}
```

---

## 👤 User Profile Endpoints

### 1. Get User Profile
**GET** `/users/profile`

**Headers:**
```
Authorization: Bearer <your_access_token>
```

**Response:**
```json
{
  "id": "uuid",
  "phoneNumber": "+11234567890",
  "firstName": "John",
  "lastName": "Doe",
  "email": "john@example.com",
  "role": "customer",
  "walletAmount": 100.00,
  "shippingAddresses": [],
  "walletTransactions": []
}
```

---

### 2. Update User Profile
**PUT** `/users/profile`

**Headers:**
```
Authorization: Bearer <your_access_token>
```

**Request Body:**
```json
{
  "firstName": "John",
  "lastName": "Smith",
  "email": "johnsmith@example.com",
  "profilePictureURL": "http://localhost:3000/uploads/profiles/image.jpg"
}
```

---

## 🧪 Testing with cURL

### Register a Customer
```bash
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "phoneNumber": "1234567890",
    "countryCode": "+1",
    "password": "password123",
    "firstName": "Test",
    "lastName": "Customer",
    "role": "customer",
    "email": "test@example.com"
  }'
```

### Login
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "phoneNumber": "1234567890",
    "countryCode": "+1",
    "password": "password123"
  }'
```

### Get Profile (Replace TOKEN with actual token from login)
```bash
curl -X GET http://localhost:3000/api/v1/users/profile \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## 🗄️ Database Schema

The database has been migrated with the following tables:
- ✅ **users** - User accounts (customer, driver, restaurant, admin)
- ✅ **shipping_addresses** - Customer delivery addresses
- ✅ **vendors** - Restaurant/vendor information
- ✅ **vendor_categories** - Restaurant categories
- ✅ **products** - Menu items
- ✅ **orders** - Order management
- ✅ **order_items** - Order line items
- ✅ **order_status_history** - Order tracking
- ✅ **chat_messages** - In-app messaging
- ✅ **zones** - Delivery zones
- ✅ **coupons** - Discount codes
- ✅ **wallet_transactions** - Wallet history
- ✅ **favorite_restaurants** - User favorites
- ✅ **favorite_items** - Favorite menu items
- ✅ **reviews** - Restaurant/product reviews
- ✅ **gift_cards** - Gift card system
- ✅ **referrals** - Referral program
- ✅ **driver_payouts** - Driver payments
- ✅ **notifications** - Push notifications
- ✅ **app_settings** - Admin settings

---

## 🔧 Environment Variables

Current configuration in `.env`:

```env
# Database
DATABASE_URL="mysql://root@localhost:3306/delivery"

# JWT
JWT_SECRET="your-super-secret-jwt-key-change-this-in-production"
JWT_REFRESH_SECRET="your-super-secret-refresh-key-change-this-in-production"
JWT_EXPIRES_IN="30d"
JWT_REFRESH_EXPIRES_IN="90d"

# Server
PORT=3000
NODE_ENV="development"

# Commission (Default)
DEFAULT_ORDER_COMMISSION_PERCENT=10
DEFAULT_DELIVERY_COMMISSION_PERCENT=10
```

---

## 📁 Project Structure

```
backend/
├── prisma/
│   ├── schema.prisma          # Database schema
│   └── migrations/            # Migration files
├── src/
│   ├── config/               # Configuration files
│   ├── controllers/
│   │   └── authController.js # ✅ Authentication logic
│   ├── middlewares/
│   │   ├── auth.js           # ✅ JWT authentication
│   │   └── errorHandler.js   # ✅ Error handling
│   ├── routes/
│   │   ├── auth.routes.js    # ✅ Auth endpoints
│   │   ├── user.routes.js    # ✅ User endpoints
│   │   └── ...               # Other routes (coming soon)
│   ├── services/             # Business logic
│   ├── sockets/
│   │   └── index.js          # ✅ Socket.IO setup
│   ├── utils/                # Helper functions
│   └── index.js              # ✅ Main server file
├── uploads/                  # File storage
│   ├── profiles/
│   ├── products/
│   ├── vendors/
│   └── chat/
├── .env                      # ✅ Environment variables
└── package.json              # ✅ Dependencies
```

---

## 🔜 Next Steps

### For Flutter Customer App Integration:
1. ✅ Update `app_config.dart` - Set `baseUrl` to `http://localhost:3000/api/v1`
2. ✅ Use `AuthController` for login/registration
3. ✅ Test authentication flow
4. 🔄 Update UI screens (login, signup)
5. 🔄 Remove Firebase dependencies from UI

### Backend Development:
1. ✅ Authentication API - **COMPLETE**
2. 🔄 Vendor/Restaurant API
3. 🔄 Product/Menu API
4. 🔄 Order Management API
5. 🔄 File Upload API
6. 🔄 Socket.IO real-time features
7. 🔄 FCM Push Notifications

---

## 🎯 Current Status

**Backend:** ✅ **READY FOR TESTING**
- Server running on http://localhost:3000
- Authentication endpoints working
- MySQL database connected
- Socket.IO initialized

**Flutter App:** 🔄 **READY FOR UI INTEGRATION**
- Service layer complete
- Need to update auth screens
- Need to test with backend

---

## 📞 Testing Authentication Flow

1. **Start the server** (already running)
2. **Register a test customer:**
   ```bash
   POST http://localhost:3000/api/v1/auth/register
   ```
3. **Login with credentials:**
   ```bash
   POST http://localhost:3000/api/v1/auth/login
   ```
4. **Use the token** to access protected endpoints
5. **Update Flutter app** `baseUrl` to connect to this backend

---

**🎉 Backend is ready! Let's now integrate with the Flutter customer app!**
