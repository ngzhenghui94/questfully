const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false,
  },
});

const setupDatabase = async () => {
  const client = await pool.connect();
  try {
    // Create Categories Table
    await client.query(`
      CREATE TABLE IF NOT EXISTS categories (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        name TEXT NOT NULL,
        color TEXT NOT NULL
      );
    `);
    console.log('Categories table created successfully.');

    // Create Questions Table
    await client.query(`
      CREATE TABLE IF NOT EXISTS questions (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        text TEXT NOT NULL,
        category_id UUID REFERENCES categories(id) ON DELETE CASCADE
      );
    `);
    console.log('Questions table created successfully.');

    // Create Favorites Table
    await client.query(`
      CREATE TABLE IF NOT EXISTS favorites (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        device_id TEXT NOT NULL,
        question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        UNIQUE(device_id, question_id)
      );
    `);
    console.log('Favorites table created successfully.');

    // Deduplicate any legacy favorites before enforcing uniqueness
    await client.query(`
      DELETE FROM favorites f
      USING favorites dup
      WHERE f.device_id = dup.device_id
        AND f.question_id = dup.question_id
        AND f.ctid > dup.ctid;
    `);

    // Ensure a unique index exists for device/question pairs (covers legacy tables without the constraint)
    await client.query(`
      CREATE UNIQUE INDEX IF NOT EXISTS favorites_device_id_question_id_key
      ON favorites(device_id, question_id);
    `);

    // Create Profiles Table
    await client.query(`
      CREATE TABLE IF NOT EXISTS profiles (
        id TEXT PRIMARY KEY DEFAULT 'default',
        display_name TEXT,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
      );
    `);
    console.log('Profiles table created successfully.');

    // Create Users Table for Apple Sign-In
    await client.query(`
      CREATE TABLE IF NOT EXISTS users (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        apple_user_id TEXT NOT NULL UNIQUE,
        email TEXT,
        display_name TEXT,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
      );
    `);
    console.log('Users table created successfully.');

    // Create Apple Credentials Table
    await client.query(`
      CREATE TABLE IF NOT EXISTS apple_credentials (
        user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
        authorization_code_hash TEXT,
        identity_token_hash TEXT,
        updated_at TIMESTAMPTZ DEFAULT NOW()
      );
    `);
    console.log('Apple credentials table created successfully.');

    // Create User Sessions Table
    await client.query(`
      CREATE TABLE IF NOT EXISTS user_sessions (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        token_hash TEXT NOT NULL UNIQUE,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        expires_at TIMESTAMPTZ NOT NULL
      );
    `);
    await client.query(`
      CREATE INDEX IF NOT EXISTS idx_user_sessions_user_id ON user_sessions(user_id);
    `);
    console.log('User sessions table created successfully.');

    console.log('Tables verified. Use insert_questions.js to seed categories and questions.');

  } catch (err) {
    console.error('Error setting up database:', err);
  } finally {
    client.release();
  }
};

setupDatabase().then(() => {
  console.log('Database setup complete.');
  pool.end();
});
