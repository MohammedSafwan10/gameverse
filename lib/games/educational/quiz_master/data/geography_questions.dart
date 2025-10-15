import '../models/quiz_question.dart';

final List<QuizQuestion> geographyQuestions = [
  QuizQuestion(
    id: 'geo1',
    question: 'What is the capital of Japan?',
    options: ['Seoul', 'Beijing', 'Tokyo', 'Bangkok'],
    correctOptionIndex: 2,
    explanation: 'Tokyo is the capital and largest city of Japan.',
    category: 'geography',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'geo2',
    question: 'Which is the largest continent by land area?',
    options: ['North America', 'Africa', 'Europe', 'Asia'],
    correctOptionIndex: 3,
    explanation:
        'Asia is the largest continent, covering about 30% of Earth\'s total land area.',
    category: 'geography',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'geo3',
    question: 'Which desert is the largest in the world?',
    options: [
      'Sahara Desert',
      'Arabian Desert',
      'Antarctic Desert',
      'Arctic Desert'
    ],
    correctOptionIndex: 2,
    explanation:
        'The Antarctic Desert is the largest desert in the world, covering an area of about 5.5 million square miles.',
    category: 'geography',
    difficulty: 'Medium',
    points: 20,
  ),
  QuizQuestion(
    id: 'geo4',
    question: 'What is the longest river in the world?',
    options: [
      'Amazon River',
      'Nile River',
      'Yangtze River',
      'Mississippi River'
    ],
    correctOptionIndex: 1,
    explanation:
        'The Nile River is the longest river in the world, stretching about 6,650 kilometers.',
    category: 'geography',
    difficulty: 'Easy',
    points: 10,
  ),
  // Additional Easy Questions
  QuizQuestion(
    id: 'geo5',
    question: 'Which country has the largest population in the world?',
    options: ['India', 'China', 'USA', 'Indonesia'],
    correctOptionIndex: 0,
    explanation:
        'India has surpassed China to become the most populous country in the world.',
    category: 'geography',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'geo6',
    question: 'What is the capital of Australia?',
    options: ['Sydney', 'Melbourne', 'Canberra', 'Perth'],
    correctOptionIndex: 2,
    explanation:
        'Canberra is the capital city of Australia, not Sydney or Melbourne as many people think.',
    category: 'geography',
    difficulty: 'Easy',
    points: 10,
  ),
  // Additional Medium Questions
  QuizQuestion(
    id: 'geo7',
    question: 'Which mountain range separates Europe from Asia?',
    options: ['Alps', 'Himalayas', 'Andes', 'Ural Mountains'],
    correctOptionIndex: 3,
    explanation:
        'The Ural Mountains form a natural boundary between Europe and Asia.',
    category: 'geography',
    difficulty: 'Medium',
    points: 20,
  ),
  QuizQuestion(
    id: 'geo8',
    question: 'What is the deepest point in the ocean?',
    options: [
      'Mariana Trench',
      'Puerto Rico Trench',
      'Java Trench',
      'Tonga Trench'
    ],
    correctOptionIndex: 0,
    explanation:
        'The Mariana Trench in the Pacific Ocean is the deepest known point on Earth, reaching a depth of about 11,034 meters.',
    category: 'geography',
    difficulty: 'Medium',
    points: 20,
  ),
  // Additional Hard Questions
  QuizQuestion(
    id: 'geo9',
    question: 'Which country is located in all four hemispheres?',
    options: ['Brazil', 'Indonesia', 'Kiribati', 'France'],
    correctOptionIndex: 2,
    explanation:
        'Kiribati is the only country in the world that is situated in all four hemispheres.',
    category: 'geography',
    difficulty: 'Hard',
    points: 30,
  ),
  QuizQuestion(
    id: 'geo10',
    question:
        'What is the only country that borders both the Caspian Sea and the Persian Gulf?',
    options: ['Turkey', 'Iran', 'Iraq', 'Azerbaijan'],
    correctOptionIndex: 1,
    explanation:
        'Iran is the only country that has coastlines on both the Caspian Sea and the Persian Gulf.',
    category: 'geography',
    difficulty: 'Hard',
    points: 30,
  ),
  // Add more geography questions...
];
