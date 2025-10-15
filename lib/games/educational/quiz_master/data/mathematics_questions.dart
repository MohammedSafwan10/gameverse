import '../models/quiz_question.dart';

final List<QuizQuestion> mathematicsQuestions = [
  QuizQuestion(
    id: 'math1',
    question: 'What is the value of π (pi) to two decimal places?',
    options: ['3.12', '3.14', '3.16', '3.18'],
    correctOptionIndex: 1,
    explanation:
        'π is approximately equal to 3.14159..., which rounds to 3.14.',
    category: 'mathematics',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'math2',
    question: 'What is the square root of 144?',
    options: ['10', '11', '12', '13'],
    correctOptionIndex: 2,
    explanation: '12 × 12 = 144, therefore the square root of 144 is 12.',
    category: 'mathematics',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'math3',
    question: 'In a right triangle, what is the name of the longest side?',
    options: ['Hypotenuse', 'Adjacent', 'Opposite', 'Base'],
    correctOptionIndex: 0,
    explanation:
        'The hypotenuse is the longest side of a right triangle, opposite to the right angle.',
    category: 'mathematics',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'math4',
    question: 'What is the sum of angles in a triangle?',
    options: ['90 degrees', '180 degrees', '270 degrees', '360 degrees'],
    correctOptionIndex: 1,
    explanation: 'The sum of angles in any triangle is always 180 degrees.',
    category: 'mathematics',
    difficulty: 'Easy',
    points: 10,
  ),
  // Additional Easy Questions
  QuizQuestion(
    id: 'math5',
    question: 'What is 15% of 200?',
    options: ['20', '25', '30', '35'],
    correctOptionIndex: 2,
    explanation: '15% of 200 = (15/100) × 200 = 30',
    category: 'mathematics',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'math6',
    question: 'What is the next number in the sequence: 2, 4, 8, 16, ...?',
    options: ['24', '32', '48', '64'],
    correctOptionIndex: 1,
    explanation:
        'Each number is doubled to get the next number in the sequence.',
    category: 'mathematics',
    difficulty: 'Easy',
    points: 10,
  ),
  // Add 35 more Easy questions...

  // Additional Medium Questions
  QuizQuestion(
    id: 'math7',
    question: 'What is the value of sin(90°)?',
    options: ['0', '1', '-1', '0.5'],
    correctOptionIndex: 1,
    explanation:
        'The sine of 90 degrees is 1, a fundamental value in trigonometry.',
    category: 'mathematics',
    difficulty: 'Medium',
    points: 20,
  ),
  QuizQuestion(
    id: 'math8',
    question: 'What is the area of a circle with radius 5 units?',
    options: ['25π', '10π', '15π', '20π'],
    correctOptionIndex: 0,
    explanation:
        'The area of a circle is πr², where r is the radius. So, area = π × 5² = 25π square units.',
    category: 'mathematics',
    difficulty: 'Medium',
    points: 20,
  ),
  // Add 35 more Medium questions...

  // Additional Hard Questions
  QuizQuestion(
    id: 'math9',
    question: 'What is the derivative of ln(x)?',
    options: ['1/x', 'x', 'e^x', 'ln(x)'],
    correctOptionIndex: 0,
    explanation: 'The derivative of the natural logarithm ln(x) is 1/x.',
    category: 'mathematics',
    difficulty: 'Hard',
    points: 30,
  ),
  QuizQuestion(
    id: 'math10',
    question: 'What is the sum of the first 100 positive integers?',
    options: ['5000', '5050', '5100', '5150'],
    correctOptionIndex: 1,
    explanation:
        'Using the formula n(n+1)/2, where n=100, we get 100×101/2 = 5050.',
    category: 'mathematics',
    difficulty: 'Hard',
    points: 30,
  ),
  // Add 35 more Hard questions...
];
