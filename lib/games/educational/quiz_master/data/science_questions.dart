import '../models/quiz_question.dart';

final List<QuizQuestion> scienceQuestions = [
  // Easy Questions
  QuizQuestion(
    id: 'sci1',
    question: 'What is the chemical symbol for gold?',
    options: ['Au', 'Ag', 'Fe', 'Cu'],
    correctOptionIndex: 0,
    explanation: 'Au is derived from the Latin word for gold, "aurum".',
    category: 'science',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'sci2',
    question: 'Which planet is known as the Red Planet?',
    options: ['Venus', 'Mars', 'Jupiter', 'Saturn'],
    correctOptionIndex: 1,
    explanation: 'Mars appears red due to iron oxide (rust) on its surface.',
    category: 'science',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'sci3',
    question: 'What is the hardest natural substance on Earth?',
    options: ['Gold', 'Iron', 'Diamond', 'Platinum'],
    correctOptionIndex: 2,
    explanation:
        'Diamond is the hardest natural substance with a rating of 10 on the Mohs scale.',
    category: 'science',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'sci4',
    question: 'What is the largest organ in the human body?',
    options: ['Heart', 'Brain', 'Liver', 'Skin'],
    correctOptionIndex: 3,
    explanation:
        'The skin is the largest organ, covering the entire body and protecting internal organs.',
    category: 'science',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'sci5',
    question: 'Which gas do plants absorb from the atmosphere?',
    options: ['Oxygen', 'Carbon Dioxide', 'Nitrogen', 'Hydrogen'],
    correctOptionIndex: 1,
    explanation:
        'Plants absorb carbon dioxide from the atmosphere during photosynthesis.',
    category: 'science',
    difficulty: 'Easy',
    points: 10,
  ),

  // Additional Easy Questions
  QuizQuestion(
    id: 'sci14',
    question: 'Which of these is not a state of matter?',
    options: ['Solid', 'Liquid', 'Energy', 'Gas'],
    correctOptionIndex: 2,
    explanation:
        'Energy is a form of power, not a state of matter. The main states of matter are solid, liquid, gas, and plasma.',
    category: 'science',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'sci15',
    question: 'What is the main function of white blood cells?',
    options: ['Carry oxygen', 'Fight infection', 'Clot blood', 'Store energy'],
    correctOptionIndex: 1,
    explanation:
        'White blood cells are part of the immune system and help fight infections and diseases.',
    category: 'science',
    difficulty: 'Easy',
    points: 10,
  ),

  // Medium Questions
  QuizQuestion(
    id: 'sci6',
    question:
        'What is the process by which plants convert light energy into chemical energy?',
    options: ['Photosynthesis', 'Respiration', 'Fermentation', 'Decomposition'],
    correctOptionIndex: 0,
    explanation:
        'Photosynthesis is the process where plants use sunlight, water, and CO2 to produce glucose and oxygen.',
    category: 'science',
    difficulty: 'Medium',
    points: 20,
  ),
  QuizQuestion(
    id: 'sci7',
    question: 'Which of these is not a greenhouse gas?',
    options: ['Carbon Dioxide', 'Methane', 'Nitrogen', 'Water Vapor'],
    correctOptionIndex: 2,
    explanation:
        'While nitrogen is the most abundant gas in Earth\'s atmosphere, it is not a greenhouse gas.',
    category: 'science',
    difficulty: 'Medium',
    points: 20,
  ),
  QuizQuestion(
    id: 'sci8',
    question:
        'What is the smallest unit of matter that retains all of its chemical properties?',
    options: ['Atom', 'Molecule', 'Element', 'Compound'],
    correctOptionIndex: 1,
    explanation:
        'A molecule is the smallest unit of a compound that retains all of its chemical properties.',
    category: 'science',
    difficulty: 'Medium',
    points: 20,
  ),
  QuizQuestion(
    id: 'sci9',
    question: 'Which blood type is known as the universal donor?',
    options: ['Type A', 'Type B', 'Type AB', 'Type O Negative'],
    correctOptionIndex: 3,
    explanation:
        'Type O Negative blood can be given to patients of all blood types.',
    category: 'science',
    difficulty: 'Medium',
    points: 20,
  ),

  // Additional Medium Questions
  QuizQuestion(
    id: 'sci16',
    question: 'What is the atomic number of carbon?',
    options: ['4', '6', '8', '12'],
    correctOptionIndex: 1,
    explanation:
        'Carbon has an atomic number of 6, meaning it has 6 protons in its nucleus.',
    category: 'science',
    difficulty: 'Medium',
    points: 20,
  ),
  QuizQuestion(
    id: 'sci17',
    question:
        'Which part of the brain is responsible for balance and coordination?',
    options: ['Cerebrum', 'Cerebellum', 'Medulla', 'Hypothalamus'],
    correctOptionIndex: 1,
    explanation:
        'The cerebellum is responsible for maintaining balance, coordination, and fine motor control.',
    category: 'science',
    difficulty: 'Medium',
    points: 20,
  ),

  // Hard Questions
  QuizQuestion(
    id: 'sci10',
    question: 'What is the half-life of Carbon-14?',
    options: ['2,730 years', '5,730 years', '7,730 years', '9,730 years'],
    correctOptionIndex: 1,
    explanation:
        'Carbon-14 has a half-life of 5,730 years, making it useful for dating organic materials.',
    category: 'science',
    difficulty: 'Hard',
    points: 30,
  ),
  QuizQuestion(
    id: 'sci11',
    question: 'Which quantum number describes the shape of an orbital?',
    options: ['Principal', 'Angular Momentum', 'Magnetic', 'Spin'],
    correctOptionIndex: 1,
    explanation:
        'The angular momentum quantum number (l) determines the shape of an atomic orbital.',
    category: 'science',
    difficulty: 'Hard',
    points: 30,
  ),
  QuizQuestion(
    id: 'sci12',
    question: 'What is the speed of light in meters per second?',
    options: ['299,792,458', '300,000,000', '299,999,999', '298,792,458'],
    correctOptionIndex: 0,
    explanation:
        'The speed of light in a vacuum is exactly 299,792,458 meters per second.',
    category: 'science',
    difficulty: 'Hard',
    points: 30,
  ),
  QuizQuestion(
    id: 'sci13',
    question: 'Which of these forces is the weakest?',
    options: [
      'Strong Nuclear',
      'Electromagnetic',
      'Weak Nuclear',
      'Gravitational'
    ],
    correctOptionIndex: 3,
    explanation:
        'Gravity is the weakest of the four fundamental forces of nature.',
    category: 'science',
    difficulty: 'Hard',
    points: 30,
  ),

  // Additional Hard Questions
  QuizQuestion(
    id: 'sci18',
    question: 'What is the Heisenberg Uncertainty Principle?',
    options: [
      'The exact position and momentum of a particle cannot be known simultaneously',
      'Energy cannot be created or destroyed',
      'Matter cannot exceed the speed of light',
      'Two objects cannot occupy the same space'
    ],
    correctOptionIndex: 0,
    explanation:
        'The Heisenberg Uncertainty Principle states that we cannot simultaneously know both the exact position and momentum of a particle.',
    category: 'science',
    difficulty: 'Hard',
    points: 30,
  ),
  QuizQuestion(
    id: 'sci19',
    question: 'What is the function of ATP synthase?',
    options: [
      'Break down glucose',
      'Synthesize proteins',
      'Generate ATP using proton gradients',
      'Repair DNA damage'
    ],
    correctOptionIndex: 2,
    explanation:
        'ATP synthase is an enzyme that produces ATP using the energy from proton gradients in cellular respiration.',
    category: 'science',
    difficulty: 'Hard',
    points: 30,
  ),
];
