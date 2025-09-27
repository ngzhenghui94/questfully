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

    // Insert Sample Data
    const data = [
      {
        category: { name: 'Deep Questions', color: '8E44AD' },
        questions: [
          'What is a belief you hold with which many people disagree?',
          "What's something you're still trying to prove to yourself?",
          "What's the most important lesson you've learned from a failure?",
          'If you could live your life over again, what would you change?',
          'What does it mean to live a good life?',
          "What is a fear you have that you're trying to overcome?",
          "What is a dream you've let go of?",
          "What is the biggest risk you've ever taken?",
          'What is something you wish you were better at?',
          "What is a memory you'll cherish forever?",
          'What is a quality you admire most in others?',
          'What is a book or movie that changed your perspective on life?',
          "What is something you're grateful for today?",
          "What is a cause you're passionate about?",
          "What is a piece of advice you'd give to your younger self?",
          'What is a time you felt truly alive?',
          "What is a question you're still searching for the answer to?",
          'What is a legacy you want to leave behind?',
          'What is the meaning of your life?',
          "What is something you've never told anyone?",
        ],
      },
      {
        category: { name: 'Faith & Beliefs', color: '3498DB' },
        questions: [
          'If love is real do you think it points to something bigger than biology?',
          'Do you believe in a higher power? Why or why not?',
          'What role does spirituality play in your life?',
          'What are your thoughts on fate and free will?',
          "Do you believe in an afterlife? What do you think it's like?",
          'What is a spiritual practice you find meaningful?',
          'How do you find peace in a chaotic world?',
          'What is a moral principle you live by?',
          'What is a time you felt a deep connection to the universe?',
          'How has your understanding of faith evolved over time?',
          'What is a question you have for a divine being?',
          'What gives you hope?',
          'Do you believe in miracles? Have you ever experienced one?',
          'What is the role of forgiveness in your life?',
          'How do you deal with doubt?',
          'What is a sacred text or story that inspires you?',
          'What does it mean to be a good person?',
          'What is your purpose in life, from a spiritual perspective?',
          'How do you connect with your inner self?',
          'What is a spiritual goal you are working towards?',
        ],
      },
      {
        category: { name: 'Silly Questions', color: '2ECC71' },
        questions: [
          'If animals could talk, which would be the rudest?',
          'What is the silliest thing you have ever done?',
          'If you were a vegetable, what vegetable would you be?',
          'What is a weird food combination you love?',
          'If you could have any superpower, but it had to be useless, what would it be?',
          'What is the most embarrassing song you know by heart?',
          'If you had to be a cartoon character for a week, who would you be?',
          'What is a ridiculous fact you know?',
          'If you could only eat one food for the rest of your life, what would it be?',
          'What is the funniest joke you know?',
          'If you could replace your hands with any object, what would you choose?',
          'What is a weird habit you have?',
          'If you could talk to one species of animal, which would it be?',
          'What is the most ridiculous purchase you have ever made?',
          'If you were a ghost, who would you haunt and why?',
          'What is a funny memory from your childhood?',
          'If you could have a theme song that played every time you entered a room, what would it be?',
          'What is the weirdest dream you have ever had?',
          'If you could be any mythical creature, what would you be?',
          'What is a silly fear you have?',
        ],
      },
      {
        category: { name: 'Personal Growth', color: 'F39C12' },
        questions: [
          'What is a new skill you would like to learn?',
          'What is a habit you are trying to build or break?',
          'What is a book that has had a significant impact on you?',
          'What is a challenge you have overcome that made you stronger?',
          'What is a fear that is holding you back?',
          'What is something you are proud of accomplishing?',
          'What is a way you can step out of your comfort zone this week?',
          'What is a piece of feedback you received that was hard to hear but helpful?',
          'What is a long-term goal you are working towards?',
          'How do you practice self-care?',
          'What is a mistake you have learned from?',
          'What is a quality you want to develop in yourself?',
          'What is a way you can be more mindful in your daily life?',
          'What is a person who inspires you to be better?',
          'What is a limiting belief you are trying to let go of?',
          'How do you define success for yourself?',
          'What is a way you can contribute to your community?',
          'What is a passion you would like to pursue?',
          'What is a way you can be more creative?',
          'What is a lesson you have learned about happiness?',
        ],
      },
      {
        category: { name: 'Relationships', color: 'E74C3C' },
        questions: [
          'What is a quality you value most in a friend?',
          'What is a way you show love and appreciation to others?',
          'What is a memory of a time a friend was there for you?',
          'What is a lesson you have learned about love?',
          'How do you handle conflict in a relationship?',
          'What is a way you can be a better friend or partner?',
          'What is a relationship that has taught you a lot?',
          'What is a boundary you have set in a relationship?',
          'What is a way you can strengthen your connection with your family?',
          'What is a time you felt truly understood by someone?',
          'What is a quality you look for in a romantic partner?',
          'How do you maintain long-distance friendships?',
          'What is a piece of advice you would give to someone about relationships?',
          'What is a way you can be more present with the people you care about?',
          'What is a challenge you have faced in a relationship and how did you overcome it?',
          'What is a way you can show more empathy to others?',
          'What is a sign of a healthy relationship?',
          'What is a way you can forgive someone who has hurt you?',
          'What is a way you can be more vulnerable in your relationships?',
          'What is a relationship you are grateful for?',
        ],
      },
      {
        category: { name: 'Simple', color: '1ABC9C' },
        questions: [
          'What brought you to this city?',
          'How do you usually like to spend your weekends?',
          'Are you more of a morning person or a night owl?',
          'What type of music do you find yourself playing on repeat?',
          'Do you prefer coffee, tea, or something else to start your day?',
          'Which movie can you watch over and over without getting bored?',
          'Have you picked up any hobbies recently?',
          'What book or podcast are you into right now?',
          'What is your go-to comfort food?',
          'Do you have a favorite vacation spot or dream destination?',
          'What kind of activities help you unwind after a long day?',
          'Are you more spontaneous or a planner?',
          'What is a small thing that instantly makes your day better?',
          'Do you enjoy cooking, and if so, what do you like to make?',
          'What was the best part of your week?',
          'Do you have any pets, or did you grow up with any?',
          'What is a story your friends love hearing you tell?',
          'What show are you currently watching?',
          'If you could learn any skill instantly, what would it be?',
          'What is your favorite way to stay active?',
          'Do you like trying new restaurants or sticking to your favorites?',
          'What is a hidden gem in this city that you recommend?',
          'Are you into board games or card games?',
          'What song always gets you dancing?',
          'What is the best advice you have ever received?',
          'Do you have a favorite seasonal tradition?',
          'What kind of art or creative outlets do you enjoy?',
          'How do you like to celebrate your birthday?',
          'What is one small goal you are working on this year?',
          'What makes you laugh the most?',
          'Do you consider yourself more of an introvert or extrovert?',
          'What was your favorite cartoon growing up?',
          'What’s your favorite way to celebrate when something good happens?',
          'Do you enjoy road trips, or do you prefer flying?',
          'Which app on your phone do you open the most?',
          'What food could you eat every day and never get tired of?',
          'What’s your favorite season and why?',
          'Are you more into podcasts or audiobooks lately?',
          'What does your ideal Sunday look like?',
          'What’s your favorite dessert?',
          'Is there a sport you love to watch or play?',
          'Do you like going to concerts or live events?',
          'What’s a small act of kindness you still remember?',
          'What was the last thing that made you smile today?',
          'How do you feel about surprises?',
          'What’s one thing you always pack when you travel?',
          'Do you have a favorite quote or mantra?',
          'What’s your go-to karaoke song?',
          'Is there a language you’d love to learn?',
          'What’s your favorite way to get some fresh air?',
          'Do you remember your first job? What was it?',
          'What type of cuisine do you get most excited about?',
          'How do you stay motivated on tough days?',
          'Are you into puzzles or brain games?',
          'What’s your favorite thing about your hometown?',
          'Do you collect anything?',
          'What’s the best compliment you’ve ever received?',
          'Which movie genre do you reach for most often?',
          'Do you like visiting museums or galleries?',
          'What’s something on your bucket list this year?',
          'Do you enjoy trying new workouts or fitness classes?',
          'What’s your favorite way to give back to your community?',
          'Is there a skill you learned as a kid that you still use?',
          'What song always helps you relax?',
          'Do you enjoy planning parties or events?',
          'What local restaurant do you recommend to everyone?',
          'Do you have a favorite childhood memory?',
          'How do you usually get around the city?',
          'Are you more drawn to the mountains or the beach?',
          'What’s your favorite ice cream flavor?',
          'Do you like attending festivals or fairs?',
          'What’s your go-to conversation starter?',
          'What was the last book you couldn’t put down?',
          'Do you have a morning routine or do you go with the flow?',
          'What’s your favorite boardwalk or waterfront to visit?',
          'Do you enjoy game nights with friends?',
          'What’s your favorite memory from the past year?',
          'What’s a small luxury you treat yourself to?',
          'Do you enjoy caring for plants or gardening?',
          'What’s one city you’d love to live in for a month?',
        ],
      },
    ];

    for (const item of data) {
      const { rows: categoryRows } = await client.query(
        `INSERT INTO categories (name, color)
         VALUES ($1, $2)
         ON CONFLICT (name) DO UPDATE SET color = EXCLUDED.color
         RETURNING id`,
        [item.category.name, item.category.color]
      );
      const categoryId = categoryRows[0].id;

      for (const questionText of item.questions) {
        await client.query(
          `INSERT INTO questions (text, category_id)
           VALUES ($1, $2)
           ON CONFLICT (category_id, text) DO NOTHING`,
          [questionText, categoryId]
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
