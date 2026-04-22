# API Server

A production-ready REST API built with **Node.js**, **Express**, **PostgreSQL**, and **Sequelize**. Used as the example
project for the [Building an Industrial Production-Ready Node.js API](#) tutorial series.

---

## Tech Stack

| Layer      | Technology     |
|------------|----------------|
| Runtime    | Node.js v18+   |
| Framework  | Express 4      |
| Database   | PostgreSQL 14+ |
| ORM        | Sequelize 6    |
| Auth       | JWT + bcryptjs |
| Validation | validate.js    |

---

## Prerequisites

- Node.js v18 or later
- PostgreSQL running locally (or via Docker)
- npm v9 or later

---

## Getting Started

### 1. Clone and install dependencies

```bash
git clone <repo-url>
cd api-server
npm install
```

### 2. Configure environment variables

Copy the example below into a `.env` file in the `api-server/` root:

```bash
APP_PORT=4000
TIME_ZONE=Asia/Colombo

DATABASE_URL="postgresql://<user>@localhost:5432/ecommerce_db"

JWT_SECRET="change-me-to-a-strong-secret"
JWT_EXPIRES_IN="7d"
```

Replace `<user>` with your PostgreSQL username.

### 3. Create the database

```bash
psql -U <user> -c "CREATE DATABASE ecommerce_db;"
```

### 4. Run migrations

```bash
npm run db:migrate
```

This creates the `users`, `product_categories`, `products`, and `product_images` tables.

### 5. Seed the database

```bash
npm run db:seed:default-user
```

Seeds a default user and sample product data.

### 6. Start the server

```bash
npm start
```

Server runs at `http://localhost:4000`.

---

## API Reference

### Authentication

| Method | Endpoint            | Auth | Description                   |
|--------|---------------------|------|-------------------------------|
| `POST` | `/api/auth/sign-up` | No   | Register a new user           |
| `POST` | `/api/auth/login`   | No   | Login and receive a JWT token |

**Sign Up** — `POST /api/auth/sign-up`

```json
{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john@example.com",
  "password": "secret123"
}
```

**Login** — `POST /api/auth/login`

```json
{
  "email": "john@example.com",
  "password": "secret123"
}
```

Both return:

```json
{
  "success": true,
  "message": "...",
  "data": {
    "token": "<jwt>"
  }
}
```

---

### User

| Method | Endpoint            | Auth | Description                      |
|--------|---------------------|------|----------------------------------|
| `GET`  | `/api/user/profile` | Yes  | Get authenticated user's profile |

Pass the token in the `Authorization` header:

```
Authorization: Bearer <token>
```

---

### Products

| Method | Endpoint                    | Auth | Description                   |
|--------|-----------------------------|------|-------------------------------|
| `GET`  | `/api/products/all`         | No   | List all products (paginated) |
| `GET`  | `/api/products/:product_id` | No   | Get a single product by UUID  |

**Pagination** — `GET /api/products/all?page=1&pageSize=10`

Query params:

| Param      | Default | Description    |
|------------|---------|----------------|
| `page`     | `1`     | Page number    |
| `pageSize` | `10`    | Items per page |

---

## Response Format

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

---

## npm Scripts

| Script                         | Description                                 |
|--------------------------------|---------------------------------------------|
| `npm start`                    | Start dev server with live-reload (nodemon) |
| `npm run db:migrate`           | Run all pending migrations                  |
| `npm run db:migrate:undo`      | Rollback the last migration                 |
| `npm run db:migrate:undo:all`  | Rollback all migrations                     |
| `npm run db:seed:default-user` | Seed the default user                       |

---

## Project Structure

```
src/
├── config/          # Sequelize database configuration
├── controllers/     # Request handlers (auth, user, product)
├── helpers/         # Response formatting and validation utilities
├── middleware/       # JWT authentication middleware
├── migrations/      # Versioned database schema changes
├── models/          # Sequelize model definitions and associations
├── routes/          # Express route definitions
├── seeders/         # Database seed scripts
└── index.js         # Application entry point
```

---

## Tutorial Series

This project is built step by step in the blog series:

- **Part 1** — Initiating the Project
- **Part 2** — Connecting the Database
- **Part 3** — Models, Associations & Seeders
- **Part 4** — Response Helpers & Validation
- **Part 5** — Authentication (Sign-up, Login, JWT)
- **Part 6** — Auth Middleware & Protected Routes
- **Part 7** — Products API with Pagination *(coming soon)*
- **Part 8** — Environment, Deployment & Production Hardening *(coming soon)*