# Copilot Coding Agent Instructions for houseplant.app

## Project Overview
- **Purpose:** Web application for delivering houseplants, built in Rust using Actix-Web, SQLx (SQLite), Tera templates, and Actix-Session for session management.
- **Main entrypoint:** `src/main.rs` (previously `main.rs` at root, now migrated to `src/`)
- **Frontend:** HTML templates in `templates/` and static assets in `static/`.
- **Database:** SQLite, accessed via SQLx. Migrations and schema are managed in code.

## Architecture & Patterns
- **Actix-Web** is used for HTTP server, routing, and middleware.
- **Session management** uses `SessionMiddleware` and `CookieSessionStore` (not `CookieSession`).
- **Tera** is used for server-side HTML rendering. Templates are organized by feature (e.g., `admin/`).
- **Data models** are defined as Rust structs with `sqlx::FromRow`, `Serialize`, and `Deserialize` derives.
- **User authentication/authorization** is handled via session and role checks in routes (see `/admin` scope).
- **Database fields**: For date/time, use `Option<String>` or `Option<chrono::NaiveDateTime>` for compatibility with SQLite and SQLx.

## Developer Workflows
- **Build:** Use `cargo build` or `docker build -t houseplant-app .` (see `Dockerfile`).
- **Run:** Use `cargo run` or run the built Docker image.
- **Deploy:** Use `./deploy.sh` (ensure all quotes are closed in the script).
- **Environment:** Set `DATABASE_URL` in `.env` for SQLite path.
- **Session key:** Use a 64-byte key for `SessionMiddleware` (see `main.rs`).

## Conventions & Practices
- **Routes** are grouped by feature and use Actix's `web::scope` for admin separation.
- **Admin routes** are protected by a session-based guard (`is_admin`).
- **Templates**: Place feature-specific templates in subfolders (e.g., `templates/admin/`).
- **Static files**: Served from `static/` via `actix-files`.
- **Error handling**: Use `expect` for critical failures (e.g., DB connection), otherwise return `HttpResponse`.
- **Code organization**: All new logic should go in `src/`.

## Integration Points
- **External dependencies:**
  - `actix-web`, `actix-files`, `actix-session`, `sqlx`, `tera`, `dotenv`, `reqwest`, `csv`, `chrono`
- **Session/DB integration:** Session data is stored in cookies; user data is loaded from SQLite.
- **Environment variables:** Managed via `.env` and `dotenv`.

## Examples
- See `src/main.rs` for:
  - Session middleware setup
  - Route and scope definitions
  - Data model definitions
  - Tera template rendering

---

If you add new features, follow the established patterns for routing, session, and template organization. For any unclear conventions, check `src/main.rs` and `templates/` for examples.
