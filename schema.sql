-- ExpedientLog — Production Schema (PostgreSQL)
-- Run this against your PostgreSQL instance.
-- Safe to run on an existing exp_log database.

-- ── users ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
  id         SERIAL PRIMARY KEY,
  username   VARCHAR(50) NOT NULL UNIQUE,
  password   VARCHAR(255) NOT NULL,
  role       VARCHAR(20) NOT NULL DEFAULT 'employee'
             CHECK (role IN ('employee', 'supervisor', 'admin')),
  department VARCHAR(50) NOT NULL DEFAULT 'General',
  full_name  VARCHAR(100) NOT NULL DEFAULT '',
  email      VARCHAR(150) NOT NULL DEFAULT '',
  phone      VARCHAR(30) NOT NULL DEFAULT '',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);

-- ── tickets ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS tickets (
  id            SERIAL PRIMARY KEY,
  user_id       INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  task          TEXT NOT NULL,
  project       VARCHAR(100) NOT NULL DEFAULT 'General / Other',
  is_knowledge  BOOLEAN NOT NULL DEFAULT FALSE,
  category      VARCHAR(100) DEFAULT NULL,
  image_path    VARCHAR(255) DEFAULT NULL,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP DEFAULT NULL
);

CREATE INDEX IF NOT EXISTS idx_tickets_user_date ON tickets(user_id, created_at);
CREATE INDEX IF NOT EXISTS idx_tickets_knowledge ON tickets(is_knowledge);

-- ── announcements ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS announcements (
  id         SERIAL PRIMARY KEY,
  title      VARCHAR(200) NOT NULL,
  body       TEXT NOT NULL,
  created_by INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  is_pinned  BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_announcements_pinned_date ON announcements(is_pinned, created_at);
