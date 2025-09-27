-- ===============================================================
-- Questfully Database Schema
-- ===============================================================
-- This script creates the necessary tables for the Questfully app.
-- It is designed for PostgreSQL.
-- ===============================================================

-- Enable the pgcrypto extension to generate UUIDs
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- -----------------------------------------------------
-- Table: categories
-- -----------------------------------------------------
-- Stores the different categories for the questions.
--
CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  color TEXT NOT NULL
);

-- Add a comment to the table for clarity
COMMENT ON TABLE categories IS 'Stores the different categories for the questions.';


-- -----------------------------------------------------
-- Table: questions
-- -----------------------------------------------------
-- Stores the individual questions, linked to a category.
--
CREATE TABLE IF NOT EXISTS questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  text TEXT NOT NULL,
  category_id UUID NOT NULL,
  
  CONSTRAINT fk_category
    FOREIGN KEY(category_id) 
    REFERENCES categories(id)
    ON DELETE CASCADE -- If a category is deleted, its questions are also deleted.
);

-- Add a comment to the table for clarity
COMMENT ON TABLE questions IS 'Stores the individual questions, linked to a category.';

-- Create an index on the foreign key for faster lookups
CREATE INDEX IF NOT EXISTS idx_questions_category_id ON questions(category_id);


-- -----------------------------------------------------
-- Table: users
-- -----------------------------------------------------
-- Stores application users identified via Sign in with Apple.
--
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  apple_user_id TEXT NOT NULL UNIQUE,
  email TEXT,
  display_name TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE users IS 'Stores users authenticated through Sign in with Apple.';


-- -----------------------------------------------------
-- Table: apple_credentials
-- -----------------------------------------------------
-- Stores hashed Apple authentication artifacts for auditing/refreshing.
--
CREATE TABLE IF NOT EXISTS apple_credentials (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  authorization_code_hash TEXT,
  identity_token_hash TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE apple_credentials IS 'Holds hashed Apple sign-in codes tied to a user.';


-- -----------------------------------------------------
-- Table: user_sessions
-- -----------------------------------------------------
-- Stores session tokens issued by the API for authenticated users.
--
CREATE TABLE IF NOT EXISTS user_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_user_sessions_user_id ON user_sessions(user_id);


-- ===============================================================
-- Sample Data (Optional)
-- ===============================================================
-- You can uncomment the lines below to insert some initial data
-- for testing purposes.
-- ===============================================================

-- DO $$
-- DECLARE
--   deep_questions_id UUID;
--   faith_beliefs_id UUID;
-- BEGIN
--   -- Insert categories and capture their generated IDs
--   INSERT INTO categories (name, color) VALUES ('Deep Questions', '8E44AD') RETURNING id INTO deep_questions_id;
--   INSERT INTO categories (name, color) VALUES ('Faith & Beliefs', '3498DB') RETURNING id INTO faith_beliefs_id;
--   INSERT INTO categories (name, color) VALUES ('Silly Questions', '2ECC71');

--   -- Insert questions linked to the categories above
--   INSERT INTO questions (text, category_id) VALUES ('What is a belief you hold with which many people disagree?', deep_questions_id);
--   INSERT INTO questions (text, category_id) VALUES ('What is the most important lesson you''ve learned in life?', deep_questions_id);
--   INSERT INTO questions (text, category_id) VALUES ('If love is real do you think it points to something bigger than biology?', faith_beliefs_id);
-- END $$;


-- --- END OF SCRIPT ---
