# HR Management System

A **Full Stack HR Management System** built with **Spring Boot**, **Flutter Web**, **MySQL**, and **Docker**. Complete with **JWT authentication**, **role-based access control**, and **CI/CD** via GitHub Actions.

[![Backend CI](https://github.com/ahmedshawky7/hr-management-system/actions/workflows/backend-ci.yml/badge.svg)](https://github.com/ahmedshawky7/hr-management-system/actions/workflows/backend-ci.yml)
[![Frontend CI](https://github.com/ahmedshawky7/hr-management-system/actions/workflows/frontend-ci.yml/badge.svg)](https://github.com/ahmedshawky7/hr-management-system/actions/workflows/frontend-ci.yml)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue?style=flat-square&logo=docker)](https://www.docker.com/)
[![Java](https://img.shields.io/badge/Java-17-orange?style=flat-square&logo=openjdk)](https://openjdk.org/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-4.1-brightgreen?style=flat-square&logo=springboot)](https://spring.io/projects/spring-boot)
[![Flutter](https://img.shields.io/badge/Flutter-3.47-blue?style=flat-square&logo=flutter)](https://flutter.dev/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?style=flat-square&logo=mysql)](https://www.mysql.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)](LICENSE)

---

## Overview

A production-ready HR Management System that handles:

- **Employee Management** - Full CRUD with department and manager hierarchy
- **Department Management** - Organized employee grouping
- **Leave Request Workflow** - Request, approve, reject, and cancel
- **Authentication & Authorization** - JWT-based with 4 role levels
- **Email Notifications** - Automatic account activation emails
- **Fully Dockerized** - One command to run everything

---

## Features

### Authentication & Security
- JWT-based stateless authentication (14-day tokens)
- BCrypt password hashing
- 4 roles: `SUPER_ADMIN`, `HR_ADMIN`, `MANAGER`, `EMPLOYEE`
- Fine-grained ownership-based authorization
- Forgot password flow with email reset links
- Account activation via email verification

### Employee Management
- Create, read, update, delete employees
- Paginated employee listing
- Hierarchical manager-employee relationship
- Transfer employees between departments
- Role-based data visibility (Managers see direct reports)

### Leave Request System
- Employees can request leaves
- Managers/HR can approve or reject
- Employees can cancel pending requests
- Status tracking: `PENDING`, `APPROVED`, `REJECTED`, `CANCELLED`
- Scoped visibility: managers see only their team's requests

### Security
- JWT authentication filter on every request
- Custom 401 and 403 error handlers
- `@PreAuthorize` method-level security
- CORS configuration for frontend
- JSON serialization protection with `@JsonIgnore`

---

## Tech Stack

### Backend

| Technology | Version | Purpose |
|-----------|---------|---------|
| **Java** | 17 | Programming Language |
| **Spring Boot** | 4.1.1 | Backend Framework |
| **Spring Security** | 7.x | Authentication & Authorization |
| **Spring Data JPA** | 4.x | Data Access Layer |
| **Hibernate** | 7.x | ORM |
| **JJWT** | 0.12.5 | JWT Handling |
| **MySQL** | 8.0 | Database |
| **Lombok** | 1.18.38 | Boilerplate Reduction |
| **Maven** | 3.9+ | Build Tool |

### Frontend

| Technology | Version | Purpose |
|-----------|---------|---------|
| **Flutter** | 3.47 | Cross-platform UI |
| **Dart** | 3.13 | Programming Language |
| **flutter_bloc** | 8.x | State Management |
| **Dio** | 5.x | HTTP Client |
| **go_router** | 13.x | Navigation |
| **shared_preferences** | 2.x | Local Storage |

### DevOps

| Technology | Purpose |
|-----------|---------|
| **Docker** | Containerization |
| **Docker Compose** | Multi-container Orchestration |
| **GitHub Actions** | CI/CD Pipeline |
| **Nginx** | Serve Flutter Web |

---

## Architecture

<pre>
+----------------------------------------------------------+
|                     User (Browser)                       |
|                   http://localhost                       |
+---------------------------+------------------------------+
                            |
                            | REST API
                            v
+----------------------------------------------------------+
|             Frontend (Flutter Web + Nginx)               |
|                       Port: 80                           |
+---------------------------+------------------------------+
                            |
                            | REST API
                            v
+----------------------------------------------------------+
|                 Backend (Spring Boot)                    |
|                     Port: 8080                           |
|                                                          |
|   +--------------+   +--------------+   +------------+   |
|   | Controllers  |-> |   Services   |-> |Repositories|   |
|   +--------------+   +--------------+   +------------+   |
|                            |                             |
|                            v                             |
|                   +----------------+                     |
|                   | SecurityUtils  |                     |
|                   +----------------+                     |
+---------------------------+------------------------------+
                            |
                            | JDBC
                            v
+----------------------------------------------------------+
|                    MySQL Database                        |
|                       Port: 3307                         |
|                Database: hr_management_db                |
+----------------------------------------------------------+
</pre>

---

## Quick Start (Docker)

### Prerequisites

- **Docker Desktop** installed and running
- **Git** (optional, for cloning)

### 1. Clone the repository

```bash
git clone https://github.com/ahmedshawky7/hr-management-system.git
cd hr-management-system
```

### 2. Create environment file

```bash
cp .env.example .env
```

Edit `.env` with your values:

<pre>
DB_NAME=hr_management_db
DB_USERNAME=root
DB_PASSWORD=your_secure_password
DB_ROOT_PASSWORD=your_secure_password

JWT_SECRET=your_base64_secret_key_here

MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your_email@gmail.com
MAIL_PASSWORD=your_app_password

BACKEND_ORIGIN=http://localhost
</pre>

> **Tip:** For Gmail, generate an App Password at https://myaccount.google.com/apppasswords

### 3. Run everything

```bash
docker compose up --build
```

**First build takes ~10 minutes.** Subsequent runs take ~30 seconds.

### 4. Access the application

| Service | URL |
|---------|-----|
| **Frontend** | http://localhost |
| **Backend API** | http://localhost:8080 |
| **MySQL** | `localhost:3307` |

### 5. Default credentials

| Username | Password | Role |
|----------|----------|------|
| `admin` | `admin1234` | SUPER_ADMIN |

> **Important:** Change the default password after first login.

---

## API Endpoints

### Authentication (`/auth`)

| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| POST | `/auth/login` | Public | Login and get JWT token |
| POST | `/auth/signup` | Public | Activate account with token |
| GET | `/auth/me` | Authenticated | Get current user info |
| POST | `/auth/forgot-password/{username}` | Public | Request password reset |
| POST | `/auth/reset-password` | Public | Reset password with token |

### Employees (`/employees`)

| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| GET | `/employees?page=1&size=10` | ADMIN, HR, MANAGER | List employees (paginated) |
| GET | `/employees/{id}` | ALL (owner access) | Get employee details |
| POST | `/employees` | ADMIN, HR, MANAGER | Create employee |
| PUT | `/employees/{id}` | ALL (owner access) | Update employee |
| DELETE | `/employees/{id}` | ADMIN, HR | Delete employee |
| PUT | `/employees/{id}/role` | ADMIN, HR | Change employee role |
| GET | `/employees/department/{id}` | ADMIN, HR, MANAGER | Get employees by department |

### Departments (`/departments`)

| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| GET | `/departments` | ALL | List all departments |
| GET | `/departments/{id}` | ALL | Get department details |
| POST | `/departments` | SUPER_ADMIN | Create department |
| DELETE | `/departments/{id}` | SUPER_ADMIN | Delete department |

### Leave Requests (`/leave-requests`)

| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| POST | `/leave-requests/employee/{id}` | ALL (owner) | Create leave request |
| GET | `/leave-requests/employee/{id}` | ALL (owner access) | Get employee's leaves |
| GET | `/leave-requests/pending` | ADMIN, HR, MANAGER | Get pending requests |
| PUT | `/leave-requests/{id}/status` | ADMIN, HR, MANAGER | Approve or reject |
| PUT | `/leave-requests/{id}/cancel` | Owner | Cancel pending request |

---

## Roles & Permissions

| Feature | SUPER_ADMIN | HR_ADMIN | MANAGER | EMPLOYEE |
|---------|:-----------:|:--------:|:-------:|:--------:|
| **Manage Departments** | YES | NO | NO | NO |
| **Create Employee** | YES | YES | YES | NO |
| **Update Any Employee** | YES | YES | NO | NO |
| **Update Own Data** | YES | YES | YES | YES |
| **Update Direct Reports** | YES | YES | YES | NO |
| **Delete Employee** | YES | YES | NO | NO |
| **Change Roles** | YES | YES | NO | NO |
| **View All Employees** | YES | YES | NO | NO |
| **View Team** | YES | YES | YES | NO |
| **Request Leave** | YES | YES | YES | YES |
| **Approve Leave** | YES | YES | YES (team only) | NO |

> * HR_ADMIN cannot promote to SUPER_ADMIN

---

## Testing

```bash
# Run backend tests
cd backend
mvn test

# Run frontend analysis
cd frontend
flutter analyze
```

**All tests are also run automatically via GitHub Actions on every push.**

---

## Docker Commands

```bash
# Start all services
docker compose up

# Start in background
docker compose up -d

# Rebuild images
docker compose up --build

# Stop all services
docker compose down

# Stop and remove volumes (deletes database)
docker compose down -v

# View logs
docker compose logs -f backend
docker compose logs -f frontend
docker compose logs -f mysql

# Execute command in running container
docker exec -it hr-backend sh
docker exec -it hr-mysql mysql -uroot -p
```

---

## Project Structure

<pre>
hr-management-system/
|
+-- .github/
|   +-- workflows/
|       +-- backend-ci.yml
|       +-- frontend-ci.yml
|
+-- backend/
|   +-- src/
|   |   +-- main/
|   |   |   +-- java/com/example/hrmanagement/
|   |   |   |   +-- abstracts/
|   |   |   |   +-- config/
|   |   |   |   +-- controller/
|   |   |   |   +-- dto/
|   |   |   |   +-- entities/
|   |   |   |   +-- enums/
|   |   |   |   +-- repository/
|   |   |   |   +-- service/
|   |   |   |   +-- shared/
|   |   |   |   +-- utils/
|   |   |   +-- resources/
|   |   |       +-- application.properties
|   |   +-- test/
|   +-- Dockerfile
|   +-- .dockerignore
|   +-- pom.xml
|
+-- frontend/
|   +-- lib/
|   |   +-- core/
|   |   |   +-- constants/
|   |   |   +-- network/
|   |   |   +-- router/
|   |   |   +-- storage/
|   |   |   +-- theme/
|   |   +-- features/
|   |   |   +-- auth/
|   |   |   +-- dashboard/
|   |   |   +-- departments/
|   |   |   +-- employees/
|   |   |   +-- leaves/
|   |   +-- main.dart
|   +-- Dockerfile
|   +-- .dockerignore
|   +-- nginx.conf
|   +-- pubspec.yaml
|
+-- docker-compose.yml
+-- .env.example
+-- .gitignore
+-- LICENSE
+-- README.md
</pre>

---

## Roadmap

- [x] Backend API with JWT
- [x] Role-based access control
- [x] Flutter Web frontend
- [x] Docker containerization
- [x] CI/CD with GitHub Actions
- [ ] Deploy to cloud (Render + GitHub Pages)
- [ ] Add Swagger/OpenAPI docs
- [ ] Add audit logging
- [ ] Implement soft delete
- [ ] Add leave balance tracking
- [ ] Real-time notifications

---

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'feat: Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## License

This project is licensed under the **MIT License** - see [LICENSE](LICENSE) for details.

---

## Author

**Ahmed Shawky** - Full Stack Developer

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/ahmed-shawky2/)
[![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/ahmedshawky7)
[![Email](https://img.shields.io/badge/Email-D14836?style=for-the-badge&logo=gmail&logoColor=white)](mailto:ahmedeltabakh703@gmail.com)

---

**If you found this project useful, please give it a star!**
