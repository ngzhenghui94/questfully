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

    // Insert Sample Data
    const categories = [
      { name: 'Deep Questions', color: '8E44AD' },
      { name: 'Faith & Beliefs', color: '3498DB' },
      { name: 'Silly Questions', color: '2ECC71' },
    ];

    for (const category of categories) {
      const res = await client.query(
        'INSERT INTO categories (name, color) VALUES ($1, $2) RETURNING id',
        [category.name, category.color]
      );
      const categoryId = res.rows[0].id;

      if (category.name === 'Deep Questions') {
        await client.query(
          'INSERT INTO questions (text, category_id) VALUES ($1, $2)',
          ['What is a belief you hold with which many people disagree?', categoryId]
        );
      } else if (category.name === 'Faith & Beliefs') {
        await client.query(
          'INSERT INTO questions (text, category_id) VALUES ($1, $2)',
          ['If love is real do you think it points to something bigger than biology?', categoryId]
        );
      }
    }
    console.log('Sample data inserted successfully.');

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
