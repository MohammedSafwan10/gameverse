import '../models/quiz_question.dart';

final List<QuizQuestion> technologyQuestions = [
  QuizQuestion(
    id: 'tech1',
    question: 'What does CPU stand for?',
    options: [
      'Central Processing Unit',
      'Computer Personal Unit',
      'Central Program Utility',
      'Computer Processing Unit'
    ],
    correctOptionIndex: 0,
    explanation:
        'CPU stands for Central Processing Unit, which is the primary component that processes instructions in a computer.',
    category: 'technology',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'tech2',
    question:
        'Which programming language is known as the "language of the web"?',
    options: ['Python', 'Java', 'JavaScript', 'C++'],
    correctOptionIndex: 2,
    explanation:
        'JavaScript is known as the language of the web as it is the primary language used for web development.',
    category: 'technology',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'tech3',
    question: 'What does HTML stand for?',
    options: [
      'Hyper Text Markup Language',
      'High Tech Modern Language',
      'Hyper Transfer Markup Language',
      'High Text Machine Language'
    ],
    correctOptionIndex: 0,
    explanation:
        'HTML stands for Hyper Text Markup Language, which is used to create and structure web pages.',
    category: 'technology',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'tech4',
    question: 'Which company developed the Android operating system?',
    options: ['Apple', 'Microsoft', 'Google', 'Samsung'],
    correctOptionIndex: 2,
    explanation:
        'Android was developed by Google and is the most widely used mobile operating system in the world.',
    category: 'technology',
    difficulty: 'Easy',
    points: 10,
  ),
  // Additional Easy Questions
  QuizQuestion(
    id: 'tech5',
    question: 'What does USB stand for?',
    options: [
      'Universal Serial Bus',
      'United Serial Bus',
      'Universal System Bus',
      'United System Bus'
    ],
    correctOptionIndex: 0,
    explanation:
        'USB stands for Universal Serial Bus, a standard for connecting devices to computers.',
    category: 'technology',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'tech6',
    question: 'Which company created the iPhone?',
    options: ['Samsung', 'Apple', 'Google', 'Microsoft'],
    correctOptionIndex: 1,
    explanation: 'Apple created the iPhone, first released in 2007.',
    category: 'technology',
    difficulty: 'Easy',
    points: 10,
  ),
  // Additional Medium Questions
  QuizQuestion(
    id: 'tech7',
    question: 'What is the purpose of a firewall in computer security?',
    options: [
      'To cool down the computer',
      'To block unauthorized access',
      'To increase internet speed',
      'To store data'
    ],
    correctOptionIndex: 1,
    explanation:
        'A firewall monitors and controls incoming and outgoing network traffic to protect against unauthorized access.',
    category: 'technology',
    difficulty: 'Medium',
    points: 20,
  ),
  QuizQuestion(
    id: 'tech8',
    question: 'Which programming paradigm does Flutter use?',
    options: ['Procedural', 'Object-Oriented', 'Functional', 'Reactive'],
    correctOptionIndex: 3,
    explanation:
        'Flutter uses a reactive programming paradigm where the UI automatically updates when the underlying data changes.',
    category: 'technology',
    difficulty: 'Medium',
    points: 20,
  ),
  // Additional Hard Questions
  QuizQuestion(
    id: 'tech9',
    question: 'What is the time complexity of a binary search algorithm?',
    options: ['O(n)', 'O(log n)', 'O(n²)', 'O(n log n)'],
    correctOptionIndex: 1,
    explanation:
        'Binary search has a time complexity of O(log n) as it divides the search space in half with each step.',
    category: 'technology',
    difficulty: 'Hard',
    points: 30,
  ),
  QuizQuestion(
    id: 'tech10',
    question: 'What is the difference between HTTP and HTTPS?',
    options: [
      'HTTPS is faster',
      'HTTP is more secure',
      'HTTPS uses encryption',
      'They are the same'
    ],
    correctOptionIndex: 2,
    explanation:
        'HTTPS (HTTP Secure) uses SSL/TLS encryption to secure data transmission between client and server.',
    category: 'technology',
    difficulty: 'Hard',
    points: 30,
  ),
  // Add more technology questions...
];
