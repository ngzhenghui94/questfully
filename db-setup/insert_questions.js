const { Pool } = require("pg");
require("dotenv").config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false,
  },
});

const toUniqueCount = (name, source, desired = 150) => {
  const unique = Array.from(new Set(source.map((q) => q.trim())));
  if (unique.length < desired) {
    throw new Error(`${name} needs at least ${desired} questions, but only ${unique.length} were generated.`);
  }
  return unique.slice(0, desired);
};

const createDeepQuestions = () => {
  const questions = [
    "When do you feel most like yourself?",
    "What everyday moment makes you pause and smile?",
    "Which memory still guides your choices today?",
    "How do you notice that you are growing?",
    "What does comfort look like for you right now?",
    "Who helps you see yourself more clearly?",
    "How do you recharge after a busy week?",
    "What lesson keeps showing up in your life?",
    "How do you track your quiet victories?",
    "What helps you stay hopeful during routine days?",
    "When do you feel brave without trying?",
    "How do you describe a good day in one sentence?",
    "What place makes you feel calm instantly?",
    "How do you know it is time to make a change?",
    "What habit reminds you that you matter?",
    "Who notices the small wins you often forget?",
    "How do you share your honest thoughts with others?",
    "What story from your life do you retell often?",
    "How do you welcome new chapters?",
    "What makes you feel grateful in the middle of chores?",
    "Who helps you laugh at yourself kindly?",
    "How do you handle plans that do not work out?",
    "What do you wish people asked you more often?",
    "When do you feel proud of your patience?",
    "How do you stay grounded when life speeds up?",
  ];

  const reflections = [
    "success",
    "friendship",
    "happiness",
    "kindness",
    "forgiveness",
    "courage",
    "creativity",
    "family",
    "tradition",
    "change",
    "rest",
    "ambition",
    "failure",
    "motivation",
    "trust",
    "love",
    "community",
    "leadership",
    "learning",
    "patience",
    "gratitude",
    "confidence",
    "faith",
    "service",
    "adventure",
    "responsibility",
    "growth",
    "self-care",
    "balance",
    "honesty",
    "empathy",
    "purpose",
    "resilience",
    "curiosity",
    "risk",
    "hope",
    "joy",
    "routine",
    "celebration",
    "healing",
    "listening",
    "storytelling",
    "mentorship",
    "celebrating others",
    "setting goals",
    "handling stress",
    "asking for help",
    "letting go",
    "making memories",
    "new beginnings",
  ];
  reflections.forEach((topic) => {
    questions.push(`How has your view of ${topic} changed over time?`);
  });

  const decisions = [
    "your next project",
    "how to spend a free evening",
    "where to travel next",
    "who to ask for advice",
    "what to learn online",
    "which invitations to accept",
    "how to set boundaries",
    "when to take a day off",
    "what to cook for loved ones",
    "how to use your savings",
    "when to say no",
    "how to celebrate progress",
    "which stories to share",
    "when to reach out to friends",
    "how to plan your weekends",
    "what to do when you feel stuck",
    "how to spend holidays",
    "where to focus your energy",
    "how to divide your time between people",
    "what to keep and what to donate",
    "when to start new routines",
    "what to read next",
    "how to make mornings easier",
    "when to rest during the day",
    "how to approach new ideas",
    "what to prioritize at work",
    "how to show appreciation",
    "when to ask for help",
    "what to simplify at home",
    "how to respond to criticism",
    "where to volunteer",
    "how to handle conflict",
    "when to celebrate",
    "what to journal about",
    "how to tackle big goals",
    "when to unplug from screens",
    "what makes a promise worth keeping",
    "how to balance routines and spontaneity",
    "when to revisit old dreams",
    "what to do with free mornings",
    "how to protect quiet time",
    "when to try something bold",
    "what to listen to on a commute",
    "how to encourage yourself",
    "where to look for inspiration",
  ];
  decisions.forEach((topic) => {
    questions.push(`What helps you choose ${topic} in everyday life?`);
  });

  const feelings = [
    "peace",
    "gratitude",
    "motivation",
    "joy",
    "clarity",
    "belonging",
    "purpose",
    "creativity",
    "confidence",
    "kindness",
    "wonder",
    "curiosity",
    "focus",
    "rest",
    "balance",
    "self-belief",
    "compassion",
    "faith",
    "patience",
    "energy",
    "connection with others",
    "connection with yourself",
    "optimism",
    "calm",
    "trust",
    "self-compassion",
    "resilience",
    "hope",
    "meaning",
    "inspiration",
    "playfulness",
    "courage",
    "love",
    "acceptance",
    "healing",
    "humility",
    "learning",
    "storytelling",
    "service",
    "community",
    "forgiveness",
    "adventure",
    "comfort",
    "self-expression",
    "mindfulness",
    "gratitude for small things",
    "contentment",
    "drive",
    "imagination",
    "stability",
  ];
  feelings.forEach((topic) => {
    questions.push(`When do you feel closest to ${topic}?`);
  });

  const reminders = [
    "your morning mindset",
    "the lessons from last year",
    "the people who cheer you on",
    "the feedback that made you better",
    "the promises you made to yourself",
    "the reasons you chose your work",
    "the goals you set this month",
    "the kindness you've received",
    "the mistakes that taught you something",
    "the dreams you still want to chase",
    "the boundaries that protect your peace",
    "the routines that give you energy",
    "the risks that paid off",
    "the words that motivate you",
    "the mentors who shaped you",
    "the friends who keep you grounded",
    "the hobbies that light you up",
    "the progress you can see",
    "the progress others see in you",
    "the challenges that stretched you",
    "the comfort of familiar places",
    "the importance of rest",
    "the values you refuse to compromise",
    "the memories you treasure",
    "the new skills you are building",
    "the hope you hold onto",
    "the adventures you want to plan",
    "the ways you celebrate others",
    "the support you offer friends",
    "the things you are thankful for today",
  ];
  reminders.forEach((topic) => {
    questions.push(`Who reminds you to pay attention to ${topic}?`);
  });

  return toUniqueCount("Deep Questions", questions);
};

const createFaithQuestions = () => {
  const questions = [
    "What helps you feel calm during prayer or reflection?",
    "Who first showed you what faith could look like?",
    "How do you bring gratitude into your morning?",
    "What song or phrase lifts your spirit quickly?",
    "How do you talk about hope with friends?",
    "What part of creation makes you feel awe?",
    "How do you recognize answered prayers?",
    "What tradition keeps you grounded?",
    "How do you handle doubts when they appear?",
    "What reminder helps you trust during change?",
    "How do you include kindness in your spiritual life?",
    "What does a peaceful Sabbath look like for you?",
    "How do you encourage others in their faith?",
    "Who do you reach out to when you need prayer?",
    "What simple ritual calms your heart?",
    "How do you stay present during worship?",
    "What inspires you to serve others?",
    "How do you pass along your beliefs to younger people?",
    "What helps you notice everyday blessings?",
    "How do you remember to practice forgiveness?",
    "What story from your faith journey do you love to share?",
    "How do you reset when your faith routine feels dry?",
    "What helps you listen for God's voice?",
    "How do you bring faith into stressful moments?",
    "What makes your faith feel personal?",
  ];

  const practices = [
    "morning prayer",
    "evening reflection",
    "keeping a gratitude list",
    "reading inspiring verses",
    "listening to worship music",
    "journaling about blessings",
    "fasting gently",
    "serving neighbors",
    "joining a small group",
    "mentoring youth",
    "celebrating communion",
    "lighting candles",
    "walking in nature",
    "memorizing scripture",
    "sharing testimonies",
    "hosting a bible study",
    "writing prayers",
    "praying over meals",
    "volunteering weekly",
    "encouraging coworkers",
    "visiting shut-ins",
    "singing hymns",
    "praying with family",
    "reading devotionals",
    "keeping a prayer board",
    "listening in silence",
    "lighting incense",
    "calling a prayer partner",
    "sending encouragement texts",
    "praying for leaders",
    "supporting missions",
    "donating quietly",
    "writing thank-you notes",
    "pausing for breath prayers",
    "listening to sermons",
    "memorizing quotes",
    "meditating on psalms",
    "praying scripture",
    "reflecting on sermons",
    "studying with friends",
    "praying during chores",
    "creating gratitude jars",
    "painting faith journaling pages",
    "praying before meetings",
    "listening for nudges",
    "sharing verses online",
    "praying for strangers",
    "lighting advent candles",
    "blessing food deliveries",
    "writing letters of encouragement",
  ];
  practices.forEach((topic) => {
    questions.push(`How do you make space for ${topic} in your routine?`);
  });

  const reflections = [
    "grace",
    "hope",
    "forgiveness",
    "service",
    "patience",
    "trust",
    "joy",
    "peace",
    "gratitude",
    "kindness",
    "gentleness",
    "self-control",
    "faithfulness",
    "mercy",
    "humility",
    "courage",
    "perseverance",
    "hospitality",
    "friendship",
    "boldness",
    "lament",
    "rest",
    "discipline",
    "listening",
    "obedience",
    "generosity",
    "compassion",
    "healing",
    "hopeful waiting",
    "sabbath",
    "wonder",
    "stewardship",
    "wisdom",
    "servant leadership",
    "contentment",
    "justice",
    "community",
    "testimony",
    "mentorship",
    "hospitality at home",
  ];
  reflections.forEach((topic) => {
    questions.push(`What has ${topic} taught you recently?`);
  });

  const community = [
    "supporting neighbors",
    "sharing meals",
    "volunteering together",
    "joining small groups",
    "mentoring youth",
    "celebrating holidays",
    "singing together",
    "listening to sermons",
    "asking big questions",
    "learning from elders",
    "talking about doubts",
    "welcoming newcomers",
    "praying with friends",
    "comforting others",
    "serving online",
    "studying together",
    "showing kindness at work",
    "spending quiet moments outdoors",
    "writing letters of encouragement",
    "sharing testimonies",
    "helping during crises",
    "celebrating answered prayers",
    "remembering God in the mundane",
    "seeking wise counsel",
    "journaling about faith",
    "encouraging family",
    "teaching children",
    "exploring traditions",
    "praying while commuting",
    "finding rest on weekends",
    "seeing beauty in creation",
    "blessing strangers",
    "supporting missions",
    "being generous",
    "trusting during change",
    "leaning on scripture",
    "building patience",
    "living with joy",
    "acting with compassion",
    "learning from mistakes",
  ];
  community.forEach((topic) => {
    questions.push(`How does ${topic} strengthen your faith?`);
  });

  return toUniqueCount("Faith & Beliefs", questions);
};

const createSillyQuestions = () => {
  const questions = [
    "What snack do you think aliens would love?",
    "If you were a weather report, what would you predict today?",
    "What would your superhero name be if your power was napping?",
    "Which emoji best describes your dance moves?",
    "If your pet could text, what would they send first?",
    "What cartoon should get a cooking show?",
    "What sound would you make to scare away boredom?",
    "If socks could talk, what secrets would they spill?",
    "What animal would make the silliest roommate?",
    "How many pancakes could you stack before it collapses?",
    "What would be the theme song for your laundry day?",
    "If you had to wear one color forever, which would be funniest?",
    "What would you rename Monday to make it friendlier?",
    "Which vegetable deserves a standing ovation?",
    "What is the best joke a toddler ever told you?",
    "If you had a parade, what float would lead?",
    "Which household chore should have a trophy?",
    "If you could high-five any historical figure, who gets it?",
    "What dance move should be mandatory at weddings?",
    "What flavor should never be turned into ice cream?",
    "If pillows had catchphrases, what would yours shout?",
    "What would you name a pet cloud?",
    "Which song turns any commute into a music video?",
    "What is your favorite useless talent?",
    "What would you trade for an unlimited supply of bubble wrap?",
  ];

  const wouldYouRather = [
    ["have glitter trail behind you", "leave a confetti cloud wherever you sit"],
    ["speak only in rhymes", "sing every sentence"],
    ["wear mismatched shoes", "wear a hat made of lettuce"],
    ["ride a tiny tricycle", "bounce on a pogo stick"],
    ["have marshmallow pillows", "have popcorn blankets"],
    ["eat cereal with a fork", "eat soup with chopsticks"],
    ["have a pet dinosaur", "have a pet dragon"],
    ["turn invisible when you sneeze", "glow when you hiccup"],
    ["wear pajamas to a fancy dinner", "wear a tuxedo to the beach"],
    ["only whisper", "only shout whispers"],
    ["laugh like a goat", "snort like a pig when you giggle"],
    ["have shoes that squeak", "have clothes that sparkle"],
    ["eat tacos for breakfast forever", "eat pancakes for dinner forever"],
    ["travel by roller skates", "travel by kangaroo pouch"],
    ["turn every drink into lemonade", "turn every snack into popcorn"],
    ["have a tail that wags", "have ears that wiggle"],
    ["sneeze glitter", "cough bubbles"],
    ["ride a giant snail", "ride a giant turtle"],
    ["have spoons for fingers", "have forks for toes"],
    ["sing instead of speaking", "dance instead of walking"],
    ["have a cat narrate your life", "have a parrot comment on everything"],
    ["sleep in a hammock", "sleep in a treehouse"],
    ["wear sunglasses at night", "wear socks on your hands"],
    ["eat only blue food", "eat only orange food"],
    ["use a pogo stick to commute", "skip everywhere you go"],
    ["live in a gingerbread house", "live in a tree shaped like a cupcake"],
    ["be chased by friendly puppies", "be chased by giggling kittens"],
    ["have a fridge that sings", "have a couch that dances"],
    ["play tag with penguins", "play hide and seek with koalas"],
    ["have spaghetti hair", "have broccoli eyebrows"],
    ["wear a superhero cape daily", "wear rollerblades everywhere"],
    ["eat dessert first", "eat breakfast twice"],
    ["sleep on a trampoline", "sleep on a pile of pillows"],
    ["have an endless supply of stickers", "have endless balloons"],
    ["wear a pizza hat", "wear a donut necklace"],
    ["pet a shark wearing mittens", "pet a porcupine wearing oven mitts"],
    ["grow a carrot nose", "grow pinecone ears"],
    ["only watch cartoons", "only listen to jingles"],
    ["swim in a pool of pudding", "swim in a pool of jelly"],
    ["have a laugh that sounds like a trumpet", "have a sneeze that sounds like a drum"],
    ["have a talking backpack", "have a talking hat"],
    ["ride a unicycle", "ride a llama"],
    ["wear glow-in-the-dark clothes", "wear clothes that change colors"],
    ["have a pet that knows magic tricks", "have a pet that tells jokes"],
    ["live in a world of bubblegum", "live in a world of chocolate"],
    ["eat soup through a straw", "eat salad with chopsticks"],
    ["have a broomstick car", "have a hoverboard skateboard"],
    ["dress like a pirate", "dress like an astronaut"],
    ["balance a book on your head all day", "wear clown shoes all day"],
    ["sleep upside down like a bat", "sleep standing up like a horse"],
    ["have rainbow freckles", "have glow-in-the-dark teeth"],
  ];
  wouldYouRather.forEach(([a, b]) => {
    questions.push(`Would you rather ${a} or ${b}?`);
  });

  const whatIf = [
    "your morning alarm cheered for you",
    "you could taste colors",
    "clouds were made of cotton candy",
    "pets could answer emails",
    "traffic lights told jokes",
    "shoes could teleport",
    "hats could predict the weather",
    "pencils could sing",
    "chairs had opinions",
    "plants gave advice",
    "mirrors complimented you",
    "umbrellas could gossip",
    "laundry folded itself",
    "backpacks had secret compartments",
    "pillows could read bedtime stories",
    "ceilings changed colors",
    "stairs turned into slides",
    "refrigerators applauded",
    "phone chargers told riddles",
    "keyboards played music",
    "socks could teleport",
    "doorbells sang harmonies",
    "smartphones grew legs",
    "bikes floated in air",
    "ice cubes glowed in the dark",
    "sandwiches introduced themselves",
    "hats changed outfits",
    "books told alternate endings",
    "cars spoke in movie quotes",
    "street signs danced",
    "pill bottles told jokes",
    "lamps recorded dreams",
    "headphones shared secrets",
    "handbags had opinions",
    "bus stops hosted trivia",
    "mirrors offered encouraging pep talks",
    "benches granted wishes",
    "coffee mugs cheered in the morning",
    "door mats started conversations",
    "televisions responded to applause",
  ];
  whatIf.forEach((scenario) => {
    questions.push(`What would you do if ${scenario}?`);
  });

  const favorites = [
    "ridiculous movie quote",
    "childhood knock-knock joke",
    "rainy day board game",
    "comfort snack",
    "karaoke anthem",
    "dance move",
    "silly hat",
    "retro cartoon",
    "made-up word",
    "costume idea",
    "imaginary friend name",
    "dessert topping",
    "bedtime story twist",
    "party theme",
    "animal sound to imitate",
    "day of the week for adventures",
    "mini road trip stop",
    "childhood prank",
    "go-to parody song",
    "summer popsicle flavor",
    "bundle of random fun facts",
    "person to swap lives with for a day",
    "odd collection",
    "walk-up song",
    "gnome name",
    "campfire story",
    "made-up sport",
    "toy from childhood",
    "catchphrase",
    "unexpected pizza topping",
    "backyard game",
    "midnight snack",
    "silly holiday tradition",
    "random hobby",
    "jellybean flavor",
    "Muppet character",
    "cartoon mashup idea",
    "dance partner",
    "funny podcast",
  ];
  favorites.forEach((topic) => {
    questions.push(`What is your favorite ${topic}?`);
  });

  return toUniqueCount("Silly Questions", questions);
};

const createPersonalGrowthQuestions = () => {
  const questions = [
    "What small habit is making a big difference lately?",
    "How do you track personal wins each week?",
    "What new idea are you experimenting with?",
    "When do you feel proud of your discipline?",
    "Who keeps you motivated when progress is slow?",
    "How do you celebrate learning something new?",
    "What helps you stay consistent on tough days?",
    "How do you check in with your goals?",
    "What routine gives you energy in the morning?",
    "How do you reset after a setback?",
    "What book or podcast is inspiring you now?",
    "How do you practice being patient with yourself?",
    "What keeps you curious about the future?",
    "How do you bring creativity into everyday tasks?",
    "What mantra keeps you moving forward?",
    "How do you balance ambition with rest?",
    "What helps you ask for feedback kindly?",
    "How do you measure growth beyond numbers?",
    "What skill are you excited to sharpen?",
    "How do you turn mistakes into lessons?",
    "What motivates you during quiet seasons?",
    "How do you protect time for reflection?",
    "What encourages you to try again?",
    "How do you share your progress with others?",
    "What keeps your goals meaningful?",
  ];

  const habits = [
    "morning stretching",
    "hydration",
    "mindful meals",
    "daily reading",
    "evening gratitude",
    "weekly planning",
    "budget check-ins",
    "learning a language",
    "writing to reflect",
    "vision boarding",
    "habit stacking",
    "sleep routines",
    "digital breaks",
    "daily journaling",
    "small workouts",
    "walking meetings",
    "habit tracking apps",
    "podcast learning",
    "time blocking",
    "meal prepping",
    "decluttering",
    "minimalist challenges",
    "creative doodling",
    "taking notes",
    "guided meditation",
    "breath work",
    "gratitude texts",
    "learning communities",
    "accountability buddies",
    "Sunday resets",
    "monthly reviews",
    "brain dumps",
    "pomodoro sessions",
    "vision casting",
    "stacking micro habits",
    "celebrating small wins",
    "sharing progress",
    "asking powerful questions",
    "cleaning routines",
    "calendar reminders",
    "slow mornings",
    "goal journaling",
    "values check-ins",
    "gratitude walks",
    "mindful budgeting",
    "skills challenges",
    "gratitude jars",
    "self-care Sundays",
    "playlist motivation",
  ];
  habits.forEach((topic) => {
    questions.push(`What small step are you taking with ${topic}?`);
  });

  const skills = [
    "public speaking",
    "writing",
    "coding",
    "storytelling",
    "time management",
    "conflict resolution",
    "active listening",
    "networking",
    "mentoring",
    "coaching",
    "photography",
    "video editing",
    "design thinking",
    "facilitation",
    "emotional intelligence",
    "goal setting",
    "creative brainstorming",
    "problem solving",
    "adaptability",
    "strategic planning",
    "decision making",
    "habit building",
    "focus",
    "delegation",
    "stress management",
    "critical thinking",
    "presentation skills",
    "negotiation",
    "feedback delivery",
    "empathetic leadership",
    "mentoring younger peers",
    "facilitating meetings",
    "project planning",
    "research",
    "data storytelling",
    "financial literacy",
    "goal mapping",
    "career design",
    "wellness planning",
    "habit reflection",
  ];
  skills.forEach((topic) => {
    questions.push(`Which resource helps you learn ${topic}?`);
  });

  const mindsets = [
    "staying optimistic",
    "embracing change",
    "building confidence",
    "welcoming feedback",
    "remaining teachable",
    "choosing gratitude",
    "leading with empathy",
    "embracing rest",
    "staying curious",
    "finding balance",
    "living with purpose",
    "practicing humility",
    "showing compassion",
    "staying hopeful",
    "embracing simple joys",
    "valuing progress",
    "trusting the process",
    "holding boundaries",
    "sharing kindness",
    "investing in friendships",
    "serving others",
    "being adaptable",
    "staying patient",
    "learning from mistakes",
    "speaking kindly to yourself",
    "celebrating others",
    "living with integrity",
    "staying playful",
    "seeking wisdom",
    "following curiosity",
    "staying focused",
    "finding calm",
    "carrying joy",
    "embracing vulnerability",
    "practicing self-compassion",
    "keeping promises",
    "valuing consistency",
    "noticing progress",
    "staying grounded",
    "sharing inspiration",
  ];
  mindsets.forEach((topic) => {
    questions.push(`How do you stay patient with ${topic}?`);
  });

  return toUniqueCount("Personal Growth", questions);
};

const createRelationshipQuestions = () => {
  const questions = [
    "Who taught you how to show up for others?",
    "What small gesture makes you feel loved?",
    "How do you keep in touch during busy weeks?",
    "What helps you listen well?",
    "How do you celebrate your friends?",
    "What builds trust with you quickly?",
    "How do you repair after a disagreement?",
    "What makes you feel included?",
    "How do you like to be cheered on?",
    "What helps you speak kindly under stress?",
    "How do you welcome new people into your circle?",
    "What is your favorite shared ritual?",
    "How do you remember important dates?",
    "What makes a conversation meaningful?",
    "How do you keep relationships fun?",
    "What support do you value most?",
    "How do you show appreciation daily?",
    "What helps you share honest feelings?",
    "How do you check in on friends far away?",
    "What helps you set healthy boundaries?",
    "How do you encourage someone chasing a goal?",
    "What small thing makes you feel seen?",
    "How do you balance alone time and together time?",
    "What makes you a dependable friend?",
    "How do you celebrate your partner's wins?",
  ];

  const connectionMoments = [
    "sharing meals",
    "taking walks",
    "drinking coffee",
    "running errands",
    "celebrating holidays",
    "watching movies",
    "planning trips",
    "playing games",
    "working on projects",
    "sending voice notes",
    "leaving sticky notes",
    "sharing playlists",
    "writing letters",
    "checking in at lunch",
    "laughing about memories",
    "hosting dinners",
    "celebrating milestones",
    "supporting new jobs",
    "cheering at events",
    "splitting chores",
    "planning budgets",
    "dreaming about the future",
    "gardening",
    "volunteering",
    "taking day trips",
    "sharing books",
    "learning skills together",
    "joining classes",
    "building traditions",
    "hosting movie nights",
    "having picnics",
    "sharing podcasts",
    "running together",
    "celebrating birthdays",
    "meal prepping",
    "walking pets",
    "doing puzzles",
    "planning staycations",
    "exploring new restaurants",
    "decorating spaces",
    "making photo albums",
    "chatting before bed",
    "sharing calendars",
    "checking on health",
    "reading devotionals",
    "planning date nights",
    "sharing gratitude",
    "talking about dreams",
    "reflecting on progress",
  ];
  connectionMoments.forEach((moment) => {
    questions.push(`When do you feel closest while ${moment}?`);
  });

  const careSkills = [
    "solving conflicts",
    "splitting chores",
    "planning finances",
    "supporting careers",
    "raising kids",
    "caring for parents",
    "managing stress",
    "celebrating wins",
    "handling disagreements",
    "discussing budgets",
    "planning schedules",
    "sharing responsibilities",
    "supporting mental health",
    "building routines",
    "managing expectations",
    "planning traditions",
    "hosting guests",
    "handling change",
    "moving homes",
    "supporting studies",
    "planning surprises",
    "celebrating small wins",
    "managing time",
    "checking in emotionally",
    "talking through feedback",
    "caring during illness",
    "navigating busy seasons",
    "planning rest",
    "balancing social circles",
    "sharing updates",
    "planning gatherings",
    "supporting hobbies",
    "making big decisions",
    "discussing boundaries",
    "parenting styles",
    "finding compromises",
    "planning vacations",
    "supporting healing",
    "resetting expectations",
    "celebrating resilience",
  ];
  careSkills.forEach((topic) => {
    questions.push(`How do you approach ${topic} with care?`);
  });

  const sharedGoals = [
    "saving money",
    "decorating a home",
    "starting a side project",
    "planning adventures",
    "building health routines",
    "supporting education",
    "volunteering",
    "raising pets",
    "hosting friends",
    "learning languages",
    "starting a garden",
    "training for races",
    "writing a book",
    "recording memories",
    "building community",
    "joining clubs",
    "cooking together",
    "learning instruments",
    "creating playlists",
    "renovating spaces",
    "planning charity events",
    "teaching each other skills",
    "exploring new hobbies",
    "planning retirement",
    "supporting small businesses",
    "learning to dance",
    "planning family reunions",
    "taking classes",
    "improving communication",
    "writing gratitude notes",
    "planning digital detoxes",
    "building traditions",
    "creating monthly themes",
    "planning staycations",
    "sharing dream boards",
    "building emergency plans",
    "supporting big dreams",
    "showing up for causes",
    "praying together",
    "building legacies",
  ];
  sharedGoals.forEach((topic) => {
    questions.push(`What helps you talk about ${topic}?`);
  });

  return toUniqueCount("Relationships", questions);
};

const createSimpleQuestions = () => {
  const questions = [
    "How do you like to start your day?",
    "What breakfast never lets you down?",
    "Who makes you laugh the hardest?",
    "What app do you open first in the morning?",
    "Where do you feel most relaxed?",
    "What treat do you save for special days?",
    "How do you unwind after work?",
    "What song always lifts your mood?",
    "How do you spend a perfect Saturday?",
    "What hobby are you into right now?",
    "When do you feel most creative?",
    "Who do you call when you have good news?",
    "What snack reminds you of home?",
    "Where would you like to travel next?",
    "What show are you binge-watching?",
    "How do you like to celebrate small wins?",
    "What chore do you secretly enjoy?",
    "How do you plan your weekends?",
    "What small luxury do you love?",
    "How do you take your coffee or tea?",
    "What does a cozy evening look like?",
    "Which season makes you happiest?",
    "What store could you browse for hours?",
    "How do you stay active?",
    "What makes you smile instantly?",
  ];

  const favorites = [
    "way to spend a rainy day",
    "comfort movie",
    "easy dinner",
    "weekend getaway",
    "podcast for commutes",
    "playlist for cleaning",
    "place to journal",
    "local coffee shop",
    "bookstore",
    "road trip snack",
    "walk in the neighborhood",
    "family tradition",
    "childhood dessert",
    "evening walk route",
    "holiday treat",
    "board game",
    "card game",
    "picnic spot",
    "sunset view",
    "brunch spot",
    "movie night snack",
    "fitness class",
    "type of flower",
    "candle scent",
    "podcast host",
    "streaming series",
    "lazy Sunday routine",
    "lunch order",
    "work-from-home outfit",
    "self-care ritual",
    "weeknight recipe",
    "city skyline",
    "childhood TV show",
    "type of soup",
    "morning playlist",
    "park bench",
    "local bakery",
    "travel souvenir",
    "pasta dish",
    "ice cream topping",
    "beach activity",
    "mountain activity",
    "side hustle idea",
    "craft project",
    "fitness app",
    "recipe blog",
    "seasonal drink",
    "place to donate",
    "weekday breakfast",
    "motivational quote",
    "afternoon pick-me-up",
    "summer fruit",
    "winter comfort food",
    "road trip podcast",
    "festival",
    "local event",
    "restaurant patio",
    "movie soundtrack",
  ];
  favorites.forEach((topic) => {
    questions.push(`What's your favorite ${topic}?`);
  });

  const daily = [
    "morning commute",
    "lunch break",
    "weeknight wind-down",
    "evening routine",
    "grocery shop",
    "meal prep",
    "workout",
    "budget check",
    "closet refresh",
    "desk setup",
    "phone cleanup",
    "holiday planning",
    "gift giving",
    "packing for trips",
    "weekend chores",
    "Sunday reset",
    "digital detox",
    "bedtime routine",
    "self-care night",
    "morning playlist",
    "garden care",
    "pet care",
    "car maintenance",
    "keeping in touch with family",
    "staying hydrated",
    "keeping healthy snacks",
    "organizing photos",
    "reading habits",
    "tracking steps",
    "planning outfits",
    "saving for goals",
    "planning staycations",
    "learning new recipes",
    "trying new workouts",
    "tracking sleep",
    "checking news",
    "managing notifications",
    "planning date nights",
    "volunteering",
    "finding alone time",
  ];
  daily.forEach((topic) => {
    questions.push(`How do you usually enjoy ${topic}?`);
  });

  const memories = [
    "family dinners",
    "school field trips",
    "summer vacations",
    "birthday parties",
    "holiday mornings",
    "road trips",
    "sleepovers",
    "weekend markets",
    "college breaks",
    "first jobs",
    "favorite teachers",
    "team sports",
    "concert nights",
    "library visits",
    "park picnics",
    "snow days",
    "favorite books",
    "school dances",
    "childhood pets",
    "family reunions",
    "graduations",
    "first apartments",
    "weekend adventures",
    "neighborhood games",
    "parental advice",
    "siblings' jokes",
    "grandparents' stories",
    "favorite teachers' lessons",
    "college roommates",
    "career milestones",
    "travel mishaps",
    "holiday traditions",
    "childhood heroes",
    "summer camps",
    "favorite playgrounds",
    "little victories",
    "favorite birthday gifts",
    "first concerts",
    "best compliments",
    "favorite home-cooked meals",
  ];
  memories.forEach((topic) => {
    questions.push(`What memory comes to mind when you think about ${topic}?`);
  });

  return toUniqueCount("Simple", questions);
};

const createHowManyQuestions = () => {
  const questions = [
    "How many vacations do you take per year?",
    "How many siblings do you have?",
    "How many people live in your home right now?",
    "How many close friends do you talk to each week?",
    "How many books are you reading at the moment?",
    "How many hours of sleep feel perfect to you?",
    "How many cups of coffee or tea do you enjoy in a day?",
    "How many playlists have you made this year?",
    "How many photos do you take on a typical trip?",
    "How many goals are you focusing on this season?",
    "How many chores did you finish today?",
    "How many steps do you try to hit on an average day?",
    "How many hobbies are you balancing right now?",
    "How many shows are on your watch list?",
    "How many memories from last month stand out?",
    "How many holidays do you host with family or friends?",
    "How many meals do you cook at home each week?",
    "How many traditions do you want to keep alive?",
    "How many neighbors do you know by name?",
    "How many local spots feel like a second home to you?",
  ];

  const routines = [
    "work meetings fill your calendar",
    "times you hit snooze",
    "emails you clear before noon",
    "walks you take to reset",
    "water breaks you aim for",
    "breaks you schedule during the workday",
    "texts you send to check in on loved ones",
    "gratitude moments you jot down",
    "quiet minutes you carve out for yourself",
    "moments you laugh in a typical day",
    "times you cook the same favorite meal",
    "errands you usually run on weekends",
    "times you reorganize your space each year",
    "times you call family members every week",
    "stretch sessions you squeeze into your day",
    "times you pause for prayer or reflection",
    "shared meals you enjoy with others each week",
    "times you open a window for fresh air",
    "pages you read before bed",
    "alarms you set to stay on track",
    "video calls you plan each month",
    "screen-free hours you try to keep",
    "times you pack a lunch for yourself",
    "days you work remotely in a month",
    "moments you celebrate small wins",
  ];
  routines.forEach((topic) => {
    questions.push(`How many ${topic}?`);
  });

  const experiences = [
    "new places you want to visit this year",
    "recipes you hope to learn soon",
    "podcasts you keep up with",
    "creative projects you have in motion",
    "weekend getaways you would like to plan",
    "concerts or events you want to attend",
    "books on your must-read list",
    "skills you are trying to pick up",
    "times you have moved homes",
    "languages you would like to practice",
    "times you have switched careers or roles",
    "volunteer events you join yearly",
    "letters or cards you send to friends",
    "traditions you would like to start",
    "moments this year that surprised you",
    "fairs or festivals you try to visit",
    "projects you finish in a typical month",
    "classes or workshops you want to take",
    "times you have changed your daily routine",
    "moments that made you proud this quarter",
    "road trips you took last year",
    "vacation ideas you keep in your notes app",
    "new foods you sampled recently",
    "times you have redecorated your space",
    "milestones you celebrated recently",
  ];
  experiences.forEach((topic) => {
    questions.push(`How many ${topic}?`);
  });

  const connections = [
    "people you send holiday cards to",
    "mentors you turn to for advice",
    "group chats you follow",
    "people who share your hobbies",
    "coworkers you collaborate with daily",
    "family traditions you cherish",
    "friends you have known since childhood",
    "people you met through volunteering",
    "celebrations you plan with friends each year",
    "gatherings you host per season",
    "calls you make to relatives each month",
    "support systems you lean on",
    "people who ask about your day",
    "moments you share updates with loved ones",
    "times you send encouragement notes",
    "community groups you are part of",
    "neighbors you see during evening walks",
    "team activities you enjoy",
    "family recipes you keep in rotation",
    "people you reach out to during tough times",
    "friendships that started in unexpected places",
    "connections you maintain across cities",
    "events you plan with extended family",
    "people you cheer for at their milestones",
    "traditions you attend with your community",
  ];
  connections.forEach((topic) => {
    questions.push(`How many ${topic}?`);
  });

  const practical = [
    "plants you care for",
    "projects waiting on your to-do list",
    "apps you open every morning",
    "tabs you keep open on your browser",
    "bags you carry around daily",
    "credit cards you actually use",
    "subscriptions you still enjoy",
    "membership cards you keep in your wallet",
    "smart devices you rely on",
    "alarms you have set right now",
    "keys on your keychain",
    "pairs of shoes you wear regularly",
    "jackets you rotate each season",
    "mugs you reach for most",
    "notes you keep on your phone",
    "things you currently have on loan",
    "loyalty programs you are signed up for",
    "appointments you have coming up",
    "packages you expect this month",
    "projects you track in your planner",
    "items you are saving to buy",
    "backup plans you usually make",
    "journals or notebooks you use",
    "photos you have printed around your home",
    "emergency contacts saved in your phone",
  ];
  practical.forEach((topic) => {
    questions.push(`How many ${topic}?`);
  });

  const reflections = [
    "memories from childhood you revisit",
    "habits you are trying to build",
    "moments you felt grateful today",
    "promises you are keeping to yourself",
    "times you paused to pray this week",
    "lessons you learned in the past year",
    "accomplishments you are celebrating",
    "risks you want to take this year",
    "habits you want to let go of",
    "dreams you are actively pursuing",
    "times you journaled this month",
    "moments you smiled during the workday",
    "new routines you tested this season",
    "acts of kindness you received recently",
    "changes you noticed in yourself",
    "moments you felt proud this week",
    "questions you are still exploring",
    "ways you find peace after a long day",
    "reminders you set for encouragement",
    "things you are grateful for right now",
    "times you encouraged someone else",
    "ideas you want to brainstorm soon",
    "lessons you want to share with others",
    "moments that made you laugh today",
    "times you paused just to breathe",
  ];
  reflections.forEach((topic) => {
    questions.push(`How many ${topic}?`);
  });

  const aspirations = [
    "dream trips you want to experience in your lifetime",
    "traditions you hope to start with future generations",
    "ideas you have saved for rainy days",
    "milestones you are planning over the next five years",
    "books you want to gift to someone you love",
    "changes you are preparing to make this season",
    "ways you plan to give back this year",
    "lessons you want to remember from this month",
    "conversations you hope to finish soon",
    "moments you want to capture in photos this year",
  ];
  aspirations.forEach((topic) => {
    questions.push(`How many ${topic}?`);
  });

  return toUniqueCount("How Many", questions);
};

const createData = () => [
  {
    category: { name: "Deep Questions", color: "8E44AD" },
    questions: createDeepQuestions(),
  },
  {
    category: { name: "Faith & Beliefs", color: "3498DB" },
    questions: createFaithQuestions(),
  },
  {
    category: { name: "Silly Questions", color: "2ECC71" },
    questions: createSillyQuestions(),
  },
  {
    category: { name: "Personal Growth", color: "F39C12" },
    questions: createPersonalGrowthQuestions(),
  },
  {
    category: { name: "Relationships", color: "E74C3C" },
    questions: createRelationshipQuestions(),
  },
  {
    category: { name: "Simple", color: "1ABC9C" },
    questions: createSimpleQuestions(),
  },
  {
    category: { name: "How Many", color: "9B59B6" },
    questions: createHowManyQuestions(),
  },
];

const seedThemes = async (client, categoryMap, questionMapByCategory) => {
  const themes = [
    {
      slug: "first-5-dates",
      title: "First 5 Dates",
      subtitle: "Build connection one date at a time",
      description: "Guided prompts to help you go deeper with each date night.",
      icon: "heart.circle.fill",
      steps: [
        { title: "Date 1", reflection: "Plan a small surprise based on what you learn tonight." },
        { title: "Date 2", reflection: "Write down a moment you want to remember together." },
        { title: "Date 3", reflection: "Share one thing you appreciate this week." },
        { title: "Date 4", reflection: "Pick a ritual you’d like to keep doing." },
        { title: "Date 5", reflection: "Celebrate what you’ve discovered as a pair." },
      ],
      category: "Relationships",
    },
    {
      slug: "roommate-reset",
      title: "Roommate Reset",
      subtitle: "Refresh your living harmony",
      description: "Weekly check-ins to align on expectations, routines, and connection.",
      icon: "house.fill",
      steps: [
        { title: "Reset Session 1", reflection: "List one shared space win you noticed." },
        { title: "Reset Session 2", reflection: "Name one new rhythm to try next week." },
        { title: "Reset Session 3", reflection: "Decide how you’ll celebrate teamwork." },
        { title: "Reset Session 4", reflection: "Plan a small moment of fun together." },
        { title: "Reset Session 5", reflection: "Check in on how everyone is feeling." },
        { title: "Reset Session 6", reflection: "Capture any agreements you want to revisit." },
      ],
      category: "Simple",
    },
    {
      slug: "parent-teen-dialogues",
      title: "Parent & Teen Dialogues",
      subtitle: "Spark meaningful communication at home",
      description: "Conversation starters designed to build empathy and understanding.",
      icon: "person.2.fill",
      steps: [
        { title: "Dialogue 1", reflection: "Share one highlight from this chat." },
        { title: "Dialogue 2", reflection: "Note something new you learned today." },
        { title: "Dialogue 3", reflection: "Plan a follow-up activity together." },
        { title: "Dialogue 4", reflection: "Talk about upcoming hopes or worries." },
        { title: "Dialogue 5", reflection: "Celebrate growth you’ve both seen." },
        { title: "Dialogue 6", reflection: "Agree on the next check-in date." },
      ],
      category: "Personal Growth",
    },
    {
      slug: "know-a-new-person",
      title: "Get to Know a New Person",
      subtitle: "Ease into a new connection",
      description: "A three-part path from introductions to light next steps.",
      icon: "person.crop.circle.badge.questionmark",
      steps: [
        {
          title: "Discover",
          reflection: "Swap origin stories, share one unexpected fact, and trade a favorite link to keep the chat going.",
        },
        {
          title: "Deepen",
          reflection: "Explore current passions and recent challenges, then plan a casual catch-up to exchange recommendations.",
        },
        {
          title: "Celebrate",
          reflection: "Call out something you appreciated learning and suggest a simple next step like meeting for coffee.",
        },
      ],
      category: "Relationships",
    },
    {
      slug: "know-a-new-friend",
      title: "Get to Know a New Friend",
      subtitle: "Turn new friendships into shared traditions",
      description: "Guided prompts to move from first impressions to meaningful rituals.",
      icon: "person.2.circle",
      steps: [
        {
          title: "Discover",
          reflection: "Revisit how you met, compare first impressions, and capture the story in a shared note or message.",
        },
        {
          title: "Deepen",
          reflection: "Swap highlights from the last month, talk about current focuses, and plan an experience around a shared interest.",
        },
        {
          title: "Celebrate",
          reflection: "Create a small tradition together and express support for an upcoming milestone or goal.",
        },
      ],
      category: "Relationships",
    },
    {
      slug: "know-a-new-date",
      title: "Get to Know a New Date",
      subtitle: "Grow chemistry with clarity",
      description: "Stages that move a date from small talk to aligned next steps.",
      icon: "heart.circle.fill",
      steps: [
        {
          title: "Discover",
          reflection: "Share a formative place or person and compare ideal weekends, noting any overlapping interests.",
        },
        {
          title: "Deepen",
          reflection: "Talk about future chapters, growth goals, and expectations while checking in on alignment.",
        },
        {
          title: "Celebrate",
          reflection: "Name a memorable moment from the date and co-design the next experience you want to share.",
        },
      ],
      category: "Relationships",
    },
  ];

  for (const theme of themes) {
    const categoryId = categoryMap[theme.category];
    if (!categoryId) {
      console.warn(`Skipping theme ${theme.slug}; category ${theme.category} missing.`);
      continue;
    }

    const questionList = questionMapByCategory[categoryId] || [];
    const themeQuestions = questionList.slice(0, theme.steps.length);
    if (themeQuestions.length < theme.steps.length) {
      console.warn(`Not enough questions for theme ${theme.slug}; found ${themeQuestions.length}.`);
      continue;
    }

    const themeResult = await client.query(
      `INSERT INTO journey_themes (slug, title, subtitle, description, icon)
       VALUES ($1, $2, $3, $4, $5)
       ON CONFLICT (slug) DO UPDATE SET
         title = EXCLUDED.title,
         subtitle = EXCLUDED.subtitle,
         description = EXCLUDED.description,
         icon = EXCLUDED.icon,
         updated_at = NOW()
       RETURNING id`,
      [theme.slug, theme.title, theme.subtitle, theme.description, theme.icon]
    );

    const themeId = themeResult.rows[0].id;

    await client.query('DELETE FROM journey_theme_steps WHERE theme_id = $1', [themeId]);

    for (let index = 0; index < theme.steps.length; index++) {
      const step = theme.steps[index];
      const question = themeQuestions[index];
      await client.query(
        `INSERT INTO journey_theme_steps (theme_id, question_id, step_order, title, reflection)
         VALUES ($1, $2, $3, $4, $5)`,
        [themeId, question.id, index + 1, step.title, step.reflection]
      );
    }
  }
};

const insertData = async () => {
  const client = await pool.connect();
  try {
    const data = createData();
    const categoryMap = {};
    const questionMapByCategory = {};

    for (const item of data) {
      const result = await client.query(
        "INSERT INTO categories (name, color) VALUES ($1, $2) ON CONFLICT (name) DO UPDATE SET color = EXCLUDED.color RETURNING id",
        [item.category.name, item.category.color],
      );
      const categoryId = result.rows[0].id;
      categoryMap[item.category.name] = categoryId;

      questionMapByCategory[categoryId] = [];

      for (const question of item.questions) {
        const questionResult = await client.query(
          "INSERT INTO questions (text, category_id) VALUES ($1, $2) ON CONFLICT (text) DO UPDATE SET category_id = EXCLUDED.category_id RETURNING id",
          [question, categoryId],
        );
        questionMapByCategory[categoryId].push({ id: questionResult.rows[0].id, text: question });
      }
    }

    await seedThemes(client, categoryMap, questionMapByCategory);

    const summary = data.map(({ category, questions }) => ({
      category: category.name,
      questions: questions.length,
    }));
    console.table(summary);
    console.log("Data inserted successfully, including journey themes.");
  } catch (err) {
    console.error("Error inserting data:", err);
  } finally {
    client.release();
  }
};

if (require.main === module) {
  insertData()
    .then(() => {
      console.log("Data insertion complete.");
    })
    .finally(() => {
      pool.end();
    });
}

module.exports = {
  createData,
  createDeepQuestions,
  createFaithQuestions,
  createSillyQuestions,
  createPersonalGrowthQuestions,
  createRelationshipQuestions,
  createSimpleQuestions,
  createHowManyQuestions,
};