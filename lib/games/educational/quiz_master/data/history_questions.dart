import '../models/quiz_question.dart';

final List<QuizQuestion> historyQuestions = [
  // Easy Questions
  QuizQuestion(
    id: 'his1',
    question: 'In which year did World War II end?',
    options: ['1943', '1944', '1945', '1946'],
    correctOptionIndex: 2,
    explanation: 'World War II ended in 1945 with the surrender of Japan.',
    category: 'history',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'his2',
    question: 'Who was the first President of the United States?',
    options: [
      'John Adams',
      'Thomas Jefferson',
      'Benjamin Franklin',
      'George Washington'
    ],
    correctOptionIndex: 3,
    explanation:
        'George Washington served as the first President from 1789 to 1797.',
    category: 'history',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'his3',
    question: 'Who painted the Mona Lisa?',
    options: [
      'Michelangelo',
      'Leonardo da Vinci',
      'Raphael',
      'Vincent van Gogh'
    ],
    correctOptionIndex: 1,
    explanation:
        'Leonardo da Vinci painted the Mona Lisa in the early 16th century.',
    category: 'history',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'his4',
    question: 'Which empire was ruled by the Aztecs?',
    options: [
      'Roman Empire',
      'Persian Empire',
      'Mexican Empire',
      'Egyptian Empire'
    ],
    correctOptionIndex: 2,
    explanation:
        'The Aztecs ruled a large empire in what is now central Mexico.',
    category: 'history',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'his5',
    question: 'Who wrote the Declaration of Independence?',
    options: [
      'George Washington',
      'Thomas Jefferson',
      'Benjamin Franklin',
      'John Adams'
    ],
    correctOptionIndex: 1,
    explanation:
        'Thomas Jefferson was the primary author of the Declaration of Independence.',
    category: 'history',
    difficulty: 'Easy',
    points: 10,
  ),

  // Medium Questions
  QuizQuestion(
    id: 'his6',
    question: 'Which ancient wonder was located in Alexandria, Egypt?',
    options: [
      'The Great Pyramid',
      'The Lighthouse',
      'The Hanging Gardens',
      'The Colossus'
    ],
    correctOptionIndex: 1,
    explanation:
        'The Lighthouse of Alexandria was one of the Seven Wonders of the Ancient World.',
    category: 'history',
    difficulty: 'Medium',
    points: 20,
  ),
  QuizQuestion(
    id: 'his7',
    question: 'Who was the first Emperor of China?',
    options: ['Kublai Khan', 'Sun Yat-sen', 'Qin Shi Huang', 'Han Wudi'],
    correctOptionIndex: 2,
    explanation:
        'Qin Shi Huang unified China in 221 BCE and became its first emperor.',
    category: 'history',
    difficulty: 'Medium',
    points: 20,
  ),
  QuizQuestion(
    id: 'his8',
    question: 'Which civilization built Machu Picchu?',
    options: ['Aztecs', 'Mayans', 'Incas', 'Olmecs'],
    correctOptionIndex: 2,
    explanation:
        'Machu Picchu was built by the Inca Empire in the 15th century.',
    category: 'history',
    difficulty: 'Medium',
    points: 20,
  ),
  QuizQuestion(
    id: 'his9',
    question: 'What was the main cause of the French Revolution?',
    options: [
      'Foreign invasion',
      'Social inequality',
      'Religious conflict',
      'Natural disaster'
    ],
    correctOptionIndex: 1,
    explanation:
        'Social and economic inequality between the classes was a major cause of the French Revolution.',
    category: 'history',
    difficulty: 'Medium',
    points: 20,
  ),

  // Hard Questions
  QuizQuestion(
    id: 'his10',
    question: 'In which year was the Magna Carta signed?',
    options: ['1215', '1225', '1235', '1245'],
    correctOptionIndex: 0,
    explanation: 'The Magna Carta was signed by King John of England in 1215.',
    category: 'history',
    difficulty: 'Hard',
    points: 30,
  ),
  QuizQuestion(
    id: 'his11',
    question: 'Who was the last Ptolemaic ruler of Egypt?',
    options: ['Nefertiti', 'Cleopatra VII', 'Hatshepsut', 'Nefertari'],
    correctOptionIndex: 1,
    explanation:
        'Cleopatra VII was the last active ruler of the Ptolemaic Kingdom of Egypt.',
    category: 'history',
    difficulty: 'Hard',
    points: 30,
  ),
  QuizQuestion(
    id: 'his12',
    question: 'Which battle marked the end of the Western Roman Empire?',
    options: [
      'Battle of Adrianople',
      'Battle of Ravenna',
      'Battle of Constantinople',
      'Battle of Carthage'
    ],
    correctOptionIndex: 1,
    explanation:
        'The Battle of Ravenna in 476 CE marked the end of the Western Roman Empire.',
    category: 'history',
    difficulty: 'Hard',
    points: 30,
  ),
  QuizQuestion(
    id: 'his13',
    question: 'Who was the first Shogun of the Tokugawa shogunate?',
    options: [
      'Tokugawa Ieyasu',
      'Oda Nobunaga',
      'Toyotomi Hideyoshi',
      'Ashikaga Takauji'
    ],
    correctOptionIndex: 0,
    explanation: 'Tokugawa Ieyasu founded the Tokugawa shogunate in 1603.',
    category: 'history',
    difficulty: 'Hard',
    points: 30,
  ),

  // Additional Easy Questions
  QuizQuestion(
    id: 'his14',
    question: 'Which ancient civilization built the pyramids of Giza?',
    options: ['Romans', 'Greeks', 'Egyptians', 'Persians'],
    correctOptionIndex: 2,
    explanation:
        'The ancient Egyptians built the pyramids of Giza around 2500 BCE.',
    category: 'history',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'his15',
    question: 'Who was the first woman to win a Nobel Prize?',
    options: ['Mother Teresa', 'Marie Curie', 'Jane Addams', 'Pearl Buck'],
    correctOptionIndex: 1,
    explanation:
        'Marie Curie won the Nobel Prize in Physics in 1903 and in Chemistry in 1911.',
    category: 'history',
    difficulty: 'Easy',
    points: 10,
  ),

  // Additional Medium Questions
  QuizQuestion(
    id: 'his16',
    question:
        'Which empire was known as "the empire on which the sun never sets"?',
    options: [
      'Roman Empire',
      'British Empire',
      'Ottoman Empire',
      'Mongol Empire'
    ],
    correctOptionIndex: 1,
    explanation:
        'The British Empire was so vast that it was always daytime in at least one of its territories.',
    category: 'history',
    difficulty: 'Medium',
    points: 20,
  ),
  QuizQuestion(
    id: 'his17',
    question: 'What was the main purpose of the Marshall Plan?',
    options: [
      'To rebuild Western Europe after WWII',
      'To develop nuclear weapons',
      'To establish NATO',
      'To explore space'
    ],
    correctOptionIndex: 0,
    explanation:
        'The Marshall Plan was a U.S. initiative to help rebuild Western European economies after World War II.',
    category: 'history',
    difficulty: 'Medium',
    points: 20,
  ),

  // Additional Hard Questions
  QuizQuestion(
    id: 'his18',
    question: 'Which treaty ended the Thirty Years\' War?',
    options: [
      'Treaty of Versailles',
      'Treaty of Westphalia',
      'Treaty of Utrecht',
      'Treaty of Paris'
    ],
    correctOptionIndex: 1,
    explanation:
        'The Peace of Westphalia in 1648 ended both the Thirty Years\' War and the Eighty Years\' War.',
    category: 'history',
    difficulty: 'Hard',
    points: 30,
  ),
  QuizQuestion(
    id: 'his19',
    question: 'Who was the last Tang Emperor of China?',
    options: [
      'Emperor Ai',
      'Emperor Xizong',
      'Emperor Zhaozong',
      'Emperor Ai Di'
    ],
    correctOptionIndex: 3,
    explanation:
        'Emperor Ai Di was the last emperor of the Tang Dynasty, ruling from 904 to 907 CE.',
    category: 'history',
    difficulty: 'Hard',
    points: 30,
  ),
];
