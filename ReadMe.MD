# E-Commerce Platform

A full-stack e-commerce platform with a production-ready REST API and a native iOS client. Used as the example project for the [Building an Industrial Production-Ready Node.js API](#) tutorial series.

---

## Projects

| Project        | Technology                          | Status      |
|----------------|-------------------------------------|-------------|
| `api-server/`  | Node.js · Express · PostgreSQL · Sequelize | Active |
| `EcommerceApp/`| Swift · SwiftUI · SwiftData · FCM   | Active      |

---

## API Server

### Tech Stack

| Layer         | Technology          |
|---------------|---------------------|
| Runtime       | Node.js v18+        |
| Framework     | Express 4           |
| Database      | PostgreSQL 14+      |
| ORM           | Sequelize 6         |
| Auth          | JWT + bcryptjs + Refresh Tokens |
| Validation    | validate.js         |
| Push Notifications | Firebase Admin SDK (FCM) |

### Prerequisites

- Node.js v18 or later
- PostgreSQL running locally (or via Docker)
- npm v9 or later

### Getting Started

#### 1. Clone and install dependencies

```bash
git clone <repo-url>
cd api-server
npm install
```

#### 2. Configure environment variables

Copy the example below into a `.env` file in the `api-server/` root:

```bash
APP_PORT=4000
TIME_ZONE=Asia/Colombo

DATABASE_URL="postgresql://<user>@localhost:5432/ecommerce_db"

JWT_SECRET="change-me-to-a-strong-secret"
JWT_EXPIRES_IN="7d"
```

Replace `<user>` with your PostgreSQL username.

#### 3. Create the database

```bash
psql -U <user> -c "CREATE DATABASE ecommerce_db;"
```

#### 4. Run migrations

```bash
npm run db:migrate
```

Creates the `users`, `refresh_tokens`, `product_categories`, `products`, `product_images`, `carts`, `orders`, `order_items`, `notifications`, and `device_tokens` tables.

#### 5. Seed the database

```bash
npm run db:seed:default-user
npm run db:seed:default-product-categories
npm run db:seed:default-products
npm run db:seed:default-product-images
```

#### 6. Start the server

```bash
npm start
```

Server runs at `http://localhost:4000`.

---

### API Reference

#### Authentication

| Method | Endpoint              | Auth | Description                        |
|--------|-----------------------|------|------------------------------------|
| `POST` | `/api/auth/sign-up`   | No   | Register a new user                |
| `POST` | `/api/auth/login`     | No   | Login and receive JWT + refresh token |
| `POST` | `/api/auth/refresh`   | No   | Exchange refresh token for new JWT |
| `POST` | `/api/auth/logout`    | Yes  | Logout and invalidate refresh token |

#### User

| Method | Endpoint             | Auth | Description                        |
|--------|----------------------|------|------------------------------------|
| `GET`  | `/api/user/profile`  | Yes  | Get authenticated user's profile   |

#### Products

| Method | Endpoint                    | Auth | Description                   |
|--------|-----------------------------|------|-------------------------------|
| `GET`  | `/api/products/all`         | No   | List all products (paginated) |
| `GET`  | `/api/products/:product_id` | No   | Get a single product by UUID  |

#### Product Categories

| Method | Endpoint                                    | Auth | Description                      |
|--------|---------------------------------------------|------|----------------------------------|
| `GET`  | `/api/product-categories/all`               | No   | List all product categories      |
| `GET`  | `/api/product-categories/:category_id`      | No   | Get a single category by ID      |

#### Cart

| Method   | Endpoint                     | Auth | Description                  |
|----------|------------------------------|------|------------------------------|
| `GET`    | `/api/cart`                  | Yes  | Get user's shopping cart     |
| `POST`   | `/api/cart/add`              | Yes  | Add product to cart          |
| `PATCH`  | `/api/cart/:productId`       | Yes  | Update cart item quantity    |
| `DELETE` | `/api/cart/:productId`       | Yes  | Remove item from cart        |

#### Orders

| Method | Endpoint                       | Auth | Description                         |
|--------|--------------------------------|------|-------------------------------------|
| `POST` | `/api/orders/checkout`         | Yes  | Checkout cart and create order      |
| `GET`  | `/api/orders`                  | Yes  | Get user's order history            |
| `GET`  | `/api/orders/:orderId`         | Yes  | Get order detail with items         |

#### Notifications

| Method  | Endpoint                            | Auth | Description                    |
|---------|-------------------------------------|------|--------------------------------|
| `GET`   | `/api/notifications`                | Yes  | Get user's notifications       |
| `PATCH` | `/api/notifications/:id/read`       | Yes  | Mark notification as read      |

#### Device Tokens

| Method   | Endpoint               | Auth | Description                             |
|----------|------------------------|------|-----------------------------------------|
| `POST`   | `/api/device-tokens`   | Yes  | Register FCM device token               |
| `DELETE` | `/api/device-tokens`   | Yes  | Unregister device token                 |

#### Admin

| Method | Endpoint                            | Auth | Description                    |
|--------|-------------------------------------|------|--------------------------------|
| `POST` | `/api/admin/orders/:orderId/deliver`| Yes  | Mark an order as delivered     |

---

### Response Format

All endpoints return a consistent JSON envelope:

```json
{
  "success": true,
  "message": "Description of the result",
  "errors": {},
  "data": {}
}
```

| Field     | Type    | Description                          |
|-----------|---------|--------------------------------------|
| `success` | boolean | `true` for 2xx, `false` for errors   |
| `message` | string  | Human-readable result description    |
| `errors`  | object  | Validation errors (on 400 responses) |
| `data`    | any     | Response payload                     |

**Pagination** — `GET /api/products/all?page=1&pageSize=10`

| Param      | Default | Description    |
|------------|---------|----------------|
| `page`     | `1`     | Page number    |
| `pageSize` | `10`    | Items per page |

**Authentication header**

```
Authorization: Bearer <token>
```

---

### npm Scripts

| Script                                   | Description                                 |
|------------------------------------------|---------------------------------------------|
| `npm start`                              | Start dev server with live-reload (nodemon) |
| `npm run db:migrate`                     | Run all pending migrations                  |
| `npm run db:migrate:undo`                | Rollback the last migration                 |
| `npm run db:migrate:undo:all`            | Rollback all migrations                     |
| `npm run db:seed:default-user`           | Seed the default user                       |
| `npm run db:seed:default-product-categories` | Seed product categories               |
| `npm run db:seed:default-products`       | Seed sample products                        |
| `npm run db:seed:default-product-images` | Seed product images                         |

---

### Project Structure

```
src/
├── config/          # Sequelize database configuration
├── controllers/     # Request handlers (auth, user, product, cart, order, notification, admin, deviceToken)
├── helpers/         # Response formatting and validation utilities
├── middleware/      # JWT authentication middleware
├── migrations/      # Versioned database schema changes
├── models/          # Sequelize model definitions and associations
├── routes/          # Express route definitions
├── seeders/         # Database seed scripts
├── services/        # Push notification service (FCM)
└── index.js         # Application entry point
```

---

## iOS App (EcommerceApp)

### Tech Stack

| Layer              | Technology                              |
|--------------------|-----------------------------------------|
| Language           | Swift                                   |
| UI Framework       | SwiftUI                                 |
| Local Persistence  | SwiftData                               |
| Networking         | URLSession (custom NetworkService)      |
| Push Notifications | Firebase Cloud Messaging (FCM) + APNs  |
| Architecture       | MVVM + Repository pattern               |
| DI                 | Custom AppContainer resolver            |

### Screens

| Screen                    | Description                                            |
|---------------------------|--------------------------------------------------------|
| `LoginScreen`             | Email/password login and sign-up                       |
| `HomeScreen`              | Product categories and product listing                 |
| `CategoryProductsScreen`  | Products filtered by selected category                 |
| `ProductDetailScreen`     | Full product detail, image slider, add to cart         |
| `CartScreen`              | Shopping cart, quantity controls, checkout             |
| `OrdersScreen`            | User order history                                     |
| `OrderDetailScreen`       | Single order detail with items and total               |
| `NotificationsScreen`     | In-app notifications, mark as read                     |
| `ProfileScreen`           | Authenticated user profile                             |
| `ConfigurationsScreen`    | App settings                                           |

### Features

- **JWT Auth** — Login, sign-up, token refresh, secure token storage, auto-logout
- **Product Catalog** — Paginated product listing, category filtering, image slider
- **Shopping Cart** — Add/remove items, quantity control, checkout
- **Orders** — Place orders, view history and order detail
- **Push Notifications** — FCM integration, deep linking from notification payload, device token registration
- **Dark/Light Theme** — ThemeManager with AppColorTokens and AppTheme
- **Custom UI Components** — AppButton, AppTextField, AppProductCard, AppCategoryCard, AppImageSlider, AppQuantityControl, AppShimmer (skeleton loading), AppSpinner, SVGIcon

### Project Structure

```
EcommerceApp/
├── UI/
│   ├── Screens/        # One folder per screen (Login, Home, Cart, Orders, …)
│   └── Components/     # Reusable UI components
├── ViewModels/         # MVVM view models for each screen
├── Data/
│   └── Repositories/   # Repository layer (Auth, Product, Cart, Order, …)
├── Network/
│   ├── Services/       # One API service per domain
│   └── NetworkService.swift  # Core HTTP client with auth interceptor
├── Navigation/         # AppRoute and AppTab enums
├── Storage/            # TokenManager, SwiftData models
├── Config/             # AppTheme, AppColorTokens, ThemeManager
├── DI/                 # AppContainer (dependency injection)
└── Push/               # AppDelegate, DeepLinkManager
```

---

## Tutorial Series

### Production-Ready Stack (Node.js API)

- **Part 1** — [Designing a Secure Node.js API](https://medium.com/@russelrajitha/production-ready-stack-part-1-designing-a-secure-node-js-api-f240a1f6467c)
- **Part 2** — [Connecting the Database](https://medium.com/@russelrajitha/building-an-industrial-production-ready-node-js-api-part-2-connecting-the-database-3e3a973edc29)
- **Part 3** — [Response Helpers, Validation & Authentication](https://medium.com/@russelrajitha/production-ready-stack-part-3-response-helpers-validation-authentication-0f40d5dd6dc3)
- **Part 4** — [Products & Shopping Cart](https://medium.com/@russelrajitha/production-ready-stack-part-4-products-shopping-cart-d8f7121ede72)
- **Part 5** — [Push Notifications with Firebase Cloud Messaging](https://medium.com/@russelrajitha/production-ready-stack-part-5-push-notifications-with-firebase-cloud-messaging-9e9bae2ee262)

### Building a Production iOS App with SwiftUI

- **Part 1** — [Project Setup, MVVM & Swinject DI](https://medium.com/@russelrajitha/building-a-production-ios-app-with-swiftui-part-1-project-setup-mvvm-swinject-di-f94496880f86)
- **Part 2** — [Design System, Theming & Dark Mode](https://medium.com/@russelrajitha/building-a-production-ios-app-with-swiftui-part-2-design-system-theming-dark-mode-763ca7ea2b7f)
- **Part 3** — [Navigation, Tab Bar & Typed Routes](https://medium.com/@russelrajitha/building-a-production-ios-app-with-swiftui-part-3-navigation-tab-bar-typed-routes-26aa8cec524b)
