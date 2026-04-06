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
  QuizQuestion(
    id: 'tech11',
    question: 'What does Wi-Fi primarily allow devices to do?',
    options: [
      'Print documents',
      'Connect wirelessly to a network',
      'Increase battery life',
      'Store more files'
    ],
    correctOptionIndex: 1,
    explanation:
        'Wi-Fi allows devices to connect wirelessly to local networks and the internet.',
    category: 'technology',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'tech12',
    question: 'Which device is commonly used to move a cursor on a desktop computer?',
    options: ['Scanner', 'Router', 'Mouse', 'Projector'],
    correctOptionIndex: 2,
    explanation:
        'A mouse is a pointing device used to move the cursor and interact with items on screen.',
    category: 'technology',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'tech13',
    question: 'What does the "www" in a website address stand for?',
    options: [
      'World Wide Web',
      'Web World Work',
      'Wide Web Window',
      'World Web Wire'
    ],
    correctOptionIndex: 0,
    explanation:
        'WWW stands for World Wide Web, the system of interlinked web pages accessed through the internet.',
    category: 'technology',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'tech14',
    question: 'Which company is known for the Windows operating system?',
    options: ['Apple', 'Microsoft', 'Intel', 'Dell'],
    correctOptionIndex: 1,
    explanation:
        'Microsoft developed Windows, one of the most widely used desktop operating systems.',
    category: 'technology',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'tech15',
    question: 'What type of device is used to take paper documents and turn them into digital files?',
    options: ['Monitor', 'Keyboard', 'Scanner', 'Speaker'],
    correctOptionIndex: 2,
    explanation:
        'A scanner captures paper documents as digital images or PDFs.',
    category: 'technology',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'tech16',
    question: 'Which of these is an example of a web browser?',
    options: ['Chrome', 'Excel', 'Windows', 'Android'],
    correctOptionIndex: 0,
    explanation:
        'Google Chrome is a web browser used to access websites on the internet.',
    category: 'technology',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'tech17',
    question: 'What is the main job of a keyboard?',
    options: [
      'To display images',
      'To enter text and commands',
      'To connect to Wi-Fi',
      'To cool the computer'
    ],
    correctOptionIndex: 1,
    explanation:
        'A keyboard is an input device used to type text and send commands to a computer.',
    category: 'technology',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'tech18',
    question: 'Which storage unit is larger?',
    options: ['Kilobyte', 'Megabyte', 'Byte', 'Bit'],
    correctOptionIndex: 1,
    explanation:
        'A megabyte is larger than a kilobyte, byte, or bit.',
    category: 'technology',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'tech19',
    question: 'What is an app short for?',
    options: ['Appliance', 'Application', 'Approach', 'Appender'],
    correctOptionIndex: 1,
    explanation:
        'App is short for application, meaning a software program for a specific task.',
    category: 'technology',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'tech20',
    question: 'Which symbol is commonly used in email addresses?',
    options: ['#', '@', '&', '%'],
    correctOptionIndex: 1,
    explanation:
        'The @ symbol is a standard part of email addresses.',
    category: 'technology',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'tech21',
    question: 'What does a battery do in a phone or laptop?',
    options: [
      'Stores internet data',
      'Provides electrical power',
      'Improves screen resolution',
      'Adds more memory'
    ],
    correctOptionIndex: 1,
    explanation:
        'A battery supplies portable electrical power so the device can run without being plugged in.',
    category: 'technology',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'tech22',
    question: 'Which of these is used to listen to sound from a computer?',
    options: ['Speakers', 'Webcam', 'Scanner', 'Microchip'],
    correctOptionIndex: 0,
    explanation:
        'Speakers output audio from a computer or other digital device.',
    category: 'technology',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'tech23',
    question: 'What does GPS help you do?',
    options: [
      'Cook food faster',
      'Find your location and navigate',
      'Charge devices wirelessly',
      'Write code automatically'
    ],
    correctOptionIndex: 1,
    explanation:
        'GPS is used for location tracking and navigation.',
    category: 'technology',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'tech24',
    question: 'Which company is famous for the search engine Google?',
    options: ['Meta', 'Amazon', 'Google', 'IBM'],
    correctOptionIndex: 2,
    explanation:
        'Google is the company behind the Google search engine.',
    category: 'technology',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'tech25',
    question: 'What is the main purpose of a password?',
    options: [
      'To decorate a profile',
      'To protect access to an account or device',
      'To increase internet speed',
      'To cool hardware'
    ],
    correctOptionIndex: 1,
    explanation:
        'Passwords help protect accounts and devices from unauthorized access.',
    category: 'technology',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'tech26',
    question: 'What kind of device is a smartwatch?',
    options: ['A kitchen appliance', 'A wearable device', 'A desktop computer', 'A printer'],
    correctOptionIndex: 1,
    explanation:
        'A smartwatch is a wearable technology device worn on the wrist.',
    category: 'technology',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'tech27',
    question: 'Which cable type is often used to charge modern Android phones?',
    options: ['USB-C', 'VGA', 'Ethernet', 'PS/2'],
    correctOptionIndex: 0,
    explanation:
        'USB-C is commonly used for charging and data transfer on modern Android devices.',
    category: 'technology',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'tech28',
    question: 'What does downloading mean?',
    options: [
      'Sending a file from your device to the internet',
      'Getting data from another system to your device',
      'Deleting files permanently',
      'Scanning for viruses'
    ],
    correctOptionIndex: 1,
    explanation:
        'Downloading means transferring data from another computer or server to your own device.',
    category: 'technology',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'tech29',
    question: 'What does RAM mainly help a computer do?',
    options: [
      'Store files long-term',
      'Run active programs smoothly',
      'Print documents',
      'Connect to Bluetooth'
    ],
    correctOptionIndex: 1,
    explanation:
        'RAM stores temporary data for currently running programs, helping the system work faster.',
    category: 'technology',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'tech30',
    question: 'Which of these is used to connect devices over short distances wirelessly?',
    options: ['Bluetooth', 'HDMI', 'Ethernet', 'VGA'],
    correctOptionIndex: 0,
    explanation:
        'Bluetooth is used for short-range wireless communication between devices.',
    category: 'technology',
    difficulty: 'Easy',
    points: 10,
  ),
  QuizQuestion(
    id: 'tech31',
    question: 'What is phishing in cybersecurity?',
    options: [
      'A way to cool servers',
      'A scam to steal information by pretending to be trustworthy',
      'A type of computer mouse',
      'A method of compressing files'
    ],
    correctOptionIndex: 1,
    explanation:
        'Phishing is a scam where attackers trick people into revealing passwords, card details, or other sensitive data.',
    category: 'technology',
    difficulty: 'Medium',
    points: 20,
  ),
  QuizQuestion(
    id: 'tech32',
    question: 'What does DNS do on the internet?',
    options: [
      'Encrypts files',
      'Translates domain names into IP addresses',
      'Stores passwords',
      'Increases CPU speed'
    ],
    correctOptionIndex: 1,
    explanation:
        'DNS converts domain names like example.com into IP addresses that computers can use.',
    category: 'technology',
    difficulty: 'Medium',
    points: 20,
  ),
  QuizQuestion(
    id: 'tech33',
    question: 'What is the primary role of an operating system?',
    options: [
      'Only browse the web',
      'Manage hardware and software resources',
      'Replace the CPU',
      'Increase battery size'
    ],
    correctOptionIndex: 1,
    explanation:
        'An operating system manages hardware, memory, files, and applications for a device.',
    category: 'technology',
    difficulty: 'Medium',
    points: 20,
  ),
  QuizQuestion(
    id: 'tech34',
    question: 'Which of these is a cloud storage service?',
    options: ['Google Drive', 'Intel Core', 'Bluetooth', 'HDMI'],
    correctOptionIndex: 0,
    explanation:
        'Google Drive is a cloud storage service used to store and share files online.',
    category: 'technology',
    difficulty: 'Medium',
    points: 20,
  ),
  QuizQuestion(
    id: 'tech35',
    question: 'What is two-factor authentication (2FA)?',
    options: [
      'Using two usernames at once',
      'Verifying identity with two different methods',
      'Logging into two apps together',
      'Using two keyboards'
    ],
    correctOptionIndex: 1,
    explanation:
        '2FA requires two different authentication methods, such as a password plus a code from a phone.',
    category: 'technology',
    difficulty: 'Medium',
    points: 20,
  ),
  QuizQuestion(
    id: 'tech36',
    question: 'What is open-source software?',
    options: [
      'Software with visible and modifiable source code',
      'Software that only works online',
      'Software with no license',
      'Software made only by one company'
    ],
    correctOptionIndex: 0,
    explanation:
        'Open-source software makes its source code available for inspection, modification, and sharing.',
    category: 'technology',
    difficulty: 'Medium',
    points: 20,
  ),
  QuizQuestion(
    id: 'tech37',
    question: 'What does SSD stand for in computer storage?',
    options: [
      'Super Storage Disk',
      'Solid State Drive',
      'Secure System Device',
      'Serial Storage Drive'
    ],
    correctOptionIndex: 1,
    explanation:
        'SSD stands for Solid State Drive, a fast storage device with no moving parts.',
    category: 'technology',
    difficulty: 'Medium',
    points: 20,
  ),
  QuizQuestion(
    id: 'tech38',
    question: 'Which protocol is commonly used to securely browse websites?',
    options: ['FTP', 'SSH', 'HTTPS', 'SMTP'],
    correctOptionIndex: 2,
    explanation:
        'HTTPS is the secure version of HTTP and uses encryption for web traffic.',
    category: 'technology',
    difficulty: 'Medium',
    points: 20,
  ),
  QuizQuestion(
    id: 'tech39',
    question: 'What does "streaming" mean in media technology?',
    options: [
      'Watching or listening to content as it is delivered over the internet',
      'Saving every file to a USB drive',
      'Printing a video frame by frame',
      'Running software without electricity'
    ],
    correctOptionIndex: 0,
    explanation:
        'Streaming allows users to play audio or video as it arrives, without downloading the whole file first.',
    category: 'technology',
    difficulty: 'Medium',
    points: 20,
  ),
  QuizQuestion(
    id: 'tech40',
    question: 'What is the purpose of version control systems like Git?',
    options: [
      'To clean keyboards',
      'To track changes in files over time',
      'To speed up monitors',
      'To design logos'
    ],
    correctOptionIndex: 1,
    explanation:
        'Version control systems like Git help track file changes, collaborate, and restore earlier versions.',
    category: 'technology',
    difficulty: 'Medium',
    points: 20,
  ),
  QuizQuestion(
    id: 'tech41',
    question: 'What is a QR code typically used for?',
    options: [
      'Cooling a processor',
      'Quickly storing and scanning encoded information',
      'Improving camera zoom',
      'Measuring battery health'
    ],
    correctOptionIndex: 1,
    explanation:
        'QR codes store encoded information that can be read quickly by a camera or scanner.',
    category: 'technology',
    difficulty: 'Medium',
    points: 20,
  ),
  QuizQuestion(
    id: 'tech42',
    question: 'What is the main benefit of caching in computing?',
    options: [
      'It stores more batteries',
      'It speeds up access to frequently used data',
      'It increases screen brightness',
      'It replaces the operating system'
    ],
    correctOptionIndex: 1,
    explanation:
        'Caching stores frequently accessed data closer to where it is needed, improving performance.',
    category: 'technology',
    difficulty: 'Medium',
    points: 20,
  ),
  QuizQuestion(
    id: 'tech43',
    question: 'Which file format is commonly used for portable documents?',
    options: ['PDF', 'MP3', 'PNG', 'EXE'],
    correctOptionIndex: 0,
    explanation:
        'PDF is widely used for portable documents that preserve formatting across devices.',
    category: 'technology',
    difficulty: 'Medium',
    points: 20,
  ),
  QuizQuestion(
    id: 'tech44',
    question: 'What does API stand for?',
    options: [
      'Application Programming Interface',
      'Advanced Program Internet',
      'Automated Processing Input',
      'Applied Program Integration'
    ],
    correctOptionIndex: 0,
    explanation:
        'API stands for Application Programming Interface, a way for software systems to communicate.',
    category: 'technology',
    difficulty: 'Medium',
    points: 20,
  ),
  QuizQuestion(
    id: 'tech45',
    question: 'What is a browser extension?',
    options: [
      'A physical device added to a computer',
      'A small software add-on that extends browser features',
      'A backup battery',
      'A different type of search engine'
    ],
    correctOptionIndex: 1,
    explanation:
        'A browser extension is a software add-on that adds new features or changes browser behavior.',
    category: 'technology',
    difficulty: 'Medium',
    points: 20,
  ),
  QuizQuestion(
    id: 'tech46',
    question: 'What is responsive web design?',
    options: [
      'A site that changes layout to fit different screen sizes',
      'A site that only loads on phones',
      'A website that always responds by email',
      'A design made only with animations'
    ],
    correctOptionIndex: 0,
    explanation:
        'Responsive web design adapts layout and content presentation to different devices and screen sizes.',
    category: 'technology',
    difficulty: 'Medium',
    points: 20,
  ),
  QuizQuestion(
    id: 'tech47',
    question: 'What is malware?',
    options: [
      'A software update',
      'Malicious software designed to harm or exploit systems',
      'A wireless charger',
      'A secure password manager'
    ],
    correctOptionIndex: 1,
    explanation:
        'Malware is malicious software such as viruses, worms, ransomware, or spyware.',
    category: 'technology',
    difficulty: 'Medium',
    points: 20,
  ),
  QuizQuestion(
    id: 'tech48',
    question: 'What is the purpose of a modem in home internet setups?',
    options: [
      'To display webpages',
      'To connect a local network to an internet service provider',
      'To store video files',
      'To scan documents'
    ],
    correctOptionIndex: 1,
    explanation:
        'A modem connects your home or office network to your internet service provider.',
    category: 'technology',
    difficulty: 'Medium',
    points: 20,
  ),
  QuizQuestion(
    id: 'tech49',
    question: 'Which language is primarily used to style web pages?',
    options: ['HTML', 'CSS', 'SQL', 'C'],
    correctOptionIndex: 1,
    explanation:
        'CSS is used to control the visual presentation and layout of web pages.',
    category: 'technology',
    difficulty: 'Medium',
    points: 20,
  ),
  QuizQuestion(
    id: 'tech50',
    question: 'What is machine learning?',
    options: [
      'Machines learning to repair themselves physically',
      'A field where systems learn patterns from data',
      'A way to manufacture chips',
      'A keyboard training technique'
    ],
    correctOptionIndex: 1,
    explanation:
        'Machine learning is a field of AI where systems learn patterns from data to make predictions or decisions.',
    category: 'technology',
    difficulty: 'Medium',
    points: 20,
  ),
  QuizQuestion(
    id: 'tech51',
    question: 'In networking, what does LAN stand for?',
    options: [
      'Local Access Network',
      'Local Area Network',
      'Linked Area Node',
      'Long Access Node'
    ],
    correctOptionIndex: 1,
    explanation:
        'LAN stands for Local Area Network, a network covering a small geographic area.',
    category: 'technology',
    difficulty: 'Medium',
    points: 20,
  ),
  QuizQuestion(
    id: 'tech52',
    question: 'What is the main purpose of a database index?',
    options: [
      'To make queries faster',
      'To delete duplicate rows automatically',
      'To encrypt every record',
      'To replace a primary key'
    ],
    correctOptionIndex: 0,
    explanation:
        'A database index improves data retrieval speed by creating a more efficient lookup structure.',
    category: 'technology',
    difficulty: 'Hard',
    points: 30,
  ),
  QuizQuestion(
    id: 'tech53',
    question: 'What does SQL injection exploit?',
    options: [
      'Weak monitor cables',
      'Improperly handled user input in database queries',
      'Low battery levels',
      'Slow wireless routers'
    ],
    correctOptionIndex: 1,
    explanation:
        'SQL injection happens when untrusted input is inserted into database queries without proper protection.',
    category: 'technology',
    difficulty: 'Hard',
    points: 30,
  ),
  QuizQuestion(
    id: 'tech54',
    question: 'Which data structure uses Last In, First Out (LIFO)?',
    options: ['Queue', 'Tree', 'Stack', 'Graph'],
    correctOptionIndex: 2,
    explanation:
        'A stack follows LIFO order, where the last item added is the first one removed.',
    category: 'technology',
    difficulty: 'Hard',
    points: 30,
  ),
  QuizQuestion(
    id: 'tech55',
    question: 'What is the primary purpose of SSL/TLS certificates?',
    options: [
      'To cool web servers',
      'To verify identity and enable encrypted connections',
      'To store website images',
      'To optimize CSS files'
    ],
    correctOptionIndex: 1,
    explanation:
        'SSL/TLS certificates help verify server identity and enable encrypted communication over HTTPS.',
    category: 'technology',
    difficulty: 'Hard',
    points: 30,
  ),
  QuizQuestion(
    id: 'tech56',
    question: 'Which sort algorithm has average time complexity O(n log n)?',
    options: ['Bubble sort', 'Merge sort', 'Selection sort', 'Insertion sort'],
    correctOptionIndex: 1,
    explanation:
        'Merge sort runs in O(n log n) time on average and in the worst case.',
    category: 'technology',
    difficulty: 'Hard',
    points: 30,
  ),
  QuizQuestion(
    id: 'tech57',
    question: 'What is normalization in database design mainly intended to reduce?',
    options: [
      'Screen brightness',
      'Data redundancy and update anomalies',
      'CPU temperature',
      'Network bandwidth'
    ],
    correctOptionIndex: 1,
    explanation:
        'Normalization reduces redundant data and helps avoid insertion, deletion, and update anomalies.',
    category: 'technology',
    difficulty: 'Hard',
    points: 30,
  ),
  QuizQuestion(
    id: 'tech58',
    question: 'What does JWT stand for in web authentication?',
    options: [
      'Java Web Token',
      'JSON Web Token',
      'Joint Web Transfer',
      'JavaScript Web Ticket'
    ],
    correctOptionIndex: 1,
    explanation:
        'JWT stands for JSON Web Token, a compact format often used for authentication and authorization.',
    category: 'technology',
    difficulty: 'Hard',
    points: 30,
  ),
  QuizQuestion(
    id: 'tech59',
    question: 'Which concept allows multiple objects to be treated through the same interface with different behavior?',
    options: ['Encapsulation', 'Polymorphism', 'Compilation', 'Caching'],
    correctOptionIndex: 1,
    explanation:
        'Polymorphism allows different classes to respond differently to the same interface or method call.',
    category: 'technology',
    difficulty: 'Hard',
    points: 30,
  ),
  QuizQuestion(
    id: 'tech60',
    question: 'What is a race condition in concurrent systems?',
    options: [
      'A competition between CPUs',
      'A bug caused by timing-dependent access to shared data',
      'A network speed test',
      'A graphics rendering mode'
    ],
    correctOptionIndex: 1,
    explanation:
        'A race condition occurs when system behavior depends on the timing or order of concurrent operations.',
    category: 'technology',
    difficulty: 'Hard',
    points: 30,
  ),
  QuizQuestion(
    id: 'tech61',
    question: 'What is the role of a load balancer in web architecture?',
    options: [
      'To rotate monitors',
      'To distribute traffic across multiple servers',
      'To compress source code',
      'To write SQL queries'
    ],
    correctOptionIndex: 1,
    explanation:
        'A load balancer distributes incoming traffic across multiple servers to improve availability and performance.',
    category: 'technology',
    difficulty: 'Hard',
    points: 30,
  ),
  QuizQuestion(
    id: 'tech62',
    question: 'What does idempotent mean in the context of APIs?',
    options: [
      'It only works offline',
      'Repeating the same request has the same effect as doing it once',
      'It always returns JSON',
      'It requires authentication'
    ],
    correctOptionIndex: 1,
    explanation:
        'An idempotent operation can be repeated without changing the result beyond the initial application.',
    category: 'technology',
    difficulty: 'Hard',
    points: 30,
  ),
  QuizQuestion(
    id: 'tech63',
    question: 'Which traversal visits the root node between the left and right subtrees in a binary tree?',
    options: ['Preorder', 'Inorder', 'Postorder', 'Level-order'],
    correctOptionIndex: 1,
    explanation:
        'Inorder traversal visits left subtree, then root, then right subtree.',
    category: 'technology',
    difficulty: 'Hard',
    points: 30,
  ),
  QuizQuestion(
    id: 'tech64',
    question: 'What is eventual consistency in distributed systems?',
    options: [
      'All nodes become consistent immediately',
      'System data may be temporarily inconsistent but converges over time',
      'Consistency is ignored permanently',
      'Only one server stores data'
    ],
    correctOptionIndex: 1,
    explanation:
        'Eventual consistency means replicas may temporarily differ, but they converge to the same state over time.',
    category: 'technology',
    difficulty: 'Hard',
    points: 30,
  ),
  QuizQuestion(
    id: 'tech65',
    question: 'What is the purpose of a mutex in multithreaded programming?',
    options: [
      'To speed up graphics rendering',
      'To ensure only one thread accesses a critical section at a time',
      'To increase battery efficiency',
      'To store logs'
    ],
    correctOptionIndex: 1,
    explanation:
        'A mutex prevents multiple threads from entering a critical section simultaneously.',
    category: 'technology',
    difficulty: 'Hard',
    points: 30,
  ),
  QuizQuestion(
    id: 'tech66',
    question: 'What does ACID stand for in databases?',
    options: [
      'Atomicity, Consistency, Isolation, Durability',
      'Access, Control, Integrity, Data',
      'Atomic, Computed, Integrated, Durable',
      'Application, Consistency, Indexing, Durability'
    ],
    correctOptionIndex: 0,
    explanation:
        'ACID stands for Atomicity, Consistency, Isolation, and Durability, key properties of reliable database transactions.',
    category: 'technology',
    difficulty: 'Hard',
    points: 30,
  ),
  QuizQuestion(
    id: 'tech67',
    question: 'In object-oriented programming, what is encapsulation?',
    options: [
      'Splitting one class into many languages',
      'Bundling data and methods while restricting direct access',
      'Deleting unused variables automatically',
      'Running code in parallel'
    ],
    correctOptionIndex: 1,
    explanation:
        'Encapsulation groups data with related methods and hides internal details from outside access.',
    category: 'technology',
    difficulty: 'Hard',
    points: 30,
  ),
  QuizQuestion(
    id: 'tech68',
    question: 'What is the main function of a compiler?',
    options: [
      'To cool hardware components',
      'To translate source code into another form, often machine code',
      'To display websites',
      'To encrypt network packets'
    ],
    correctOptionIndex: 1,
    explanation:
        'A compiler translates source code into machine code or another executable representation.',
    category: 'technology',
    difficulty: 'Hard',
    points: 30,
  ),
  QuizQuestion(
    id: 'tech69',
    question: 'What problem does hashing commonly help solve?',
    options: [
      'Efficient data lookup and verification',
      'Cooling laptop batteries',
      'Improving touch sensitivity',
      'Increasing monitor resolution'
    ],
    correctOptionIndex: 0,
    explanation:
        'Hashing is commonly used for quick lookups, integrity checks, and secure password storage workflows.',
    category: 'technology',
    difficulty: 'Hard',
    points: 30,
  ),
  QuizQuestion(
    id: 'tech70',
    question: 'What is containerization in software deployment?',
    options: [
      'Packaging applications with their dependencies in isolated environments',
      'Storing apps in plastic cases',
      'Making every app run on bare metal only',
      'Replacing virtual memory'
    ],
    correctOptionIndex: 0,
    explanation:
        'Containerization packages an application and its dependencies into isolated, portable units.',
    category: 'technology',
    difficulty: 'Hard',
    points: 30,
  ),
];
