import 'package:flutter/material.dart';
import 'quiz_screen.dart';
import '../info/progress_data.dart';
import '../info/progress_service.dart';

class LessonContentScreen extends StatefulWidget {
  final String level;
  final int lessonNumber;

  const LessonContentScreen({
    super.key,
    required this.level,
    required this.lessonNumber,
  });

  @override
  State<LessonContentScreen> createState() => _LessonContentScreenState();
}

class _LessonContentScreenState extends State<LessonContentScreen> {
  late int currentLesson;
  bool _showOutput = false;
  late ProgressService _progressService;

  // ===== STYLE CONSTANTS (HomeScreen aligned) =====
  static const bgColor = Color(0xFF0F0618);
  static const cardColor = Color(0xFF1A0F2E);
  static const accent = Color(0xFF7B2CBF);
  static const accentDark = Color(0xFF5A189A);
  static const codeBg = Color(0xFF0F0818);

  @override
  void initState() {
    super.initState();
    _progressService = ProgressService();
    currentLesson = widget.lessonNumber;
  }

  // ===== LESSON DATA (UNCHANGED) =====
  final Map<String, List<Map<String, String>>> lessonData = {
    // ================= BEGINNER =================
    'Beginner': [
      {
        'title': 'What is Python?',
        'content':
            'Python is a high-level, general-purpose programming language designed for readability and productivity. Its clear syntax and huge standard library make it ideal for beginners while remaining powerful enough for professionals building web apps, data pipelines, automation tools, and more.',
        'example': 'print("Hello, Python!")',
        'output': 'Hello, Python!',
        'keyTakeaway': 'Python is simple and beginner-friendly.',
      },
      {
        'title': 'Installing Python',
        'content':
            'Python can be downloaded from python.org and installed in minutes. After installation, verify it from the terminal so you know your system PATH is set correctly and you are ready to run scripts and use the interactive shell.',
        'example': 'python --version',
        'output': 'Python 3.x.x',
        'keyTakeaway': 'Always check your Python version.',
      },
      {
        'title': 'Variables',
        'content':
            'Variables store data values and give names to information so you can reuse it. In Python, variables are created when you assign a value, and their type is inferred automatically based on the value you assign.',
        'example': 'x = 10\nprint(x)',
        'output': '10',
        'keyTakeaway': 'Variables hold information.',
      },
      {
        'title': 'Data Types',
        'content':
            'Common types include int, float, string, and boolean. Understanding data types helps you predict how operations behave and prevents errors when you mix numbers, text, and logical values.',
        'example': 'age = 20\nprint(type(age))',
        'output': "<class 'int'>",
        'keyTakeaway': 'Data types define data behavior.',
      },
      {
        'title': 'Strings',
        'content':
            'Strings store text and are one of the most common data types. You can join strings, format them with variables, and access individual characters by position.',
        'example': 'name = "Alex"\nprint(name)',
        'output': 'Alex',
        'keyTakeaway': 'Strings are text values.',
      },
      {
        'title': 'User Input',
        'content':
            'Input allows users to enter data at runtime, making programs interactive. Always remember that input comes in as a string, so you may need to convert it to a number when doing calculations.',
        'example': 'name = input("Enter name: ")\nprint(name)',
        'output': 'User input',
        'keyTakeaway': 'Input makes programs interactive.',
      },
      {
        'title': 'Operators',
        'content':
            'Operators perform calculations and comparisons. Python supports arithmetic operators like + and -, as well as comparison and logical operators that are essential for building conditions.',
        'example': 'print(5 + 3)',
        'output': '8',
        'keyTakeaway': 'Operators work on values.',
      },
      {
        'title': 'If Statements',
        'content':
            'If statements make decisions by evaluating conditions. They let your program choose different paths based on user input or computed results, which is the foundation of control flow.',
        'example': 'if 5 > 3:\n  print("Yes")',
        'output': 'Yes',
        'keyTakeaway': 'Conditions control logic.',
      },
      {
        'title': 'Loops',
        'content':
            'Loops repeat actions and help you avoid writing the same code over and over. Use for-loops to iterate over a sequence and while-loops when you need to repeat until a condition changes.',
        'example': 'for i in range(3):\n  print(i)',
        'output': '0\n1\n2',
        'keyTakeaway': 'Loops save time.',
      },
      {
        'title': 'Functions',
        'content':
            'Functions group reusable code and help you organize your program into logical blocks. They reduce repetition, improve readability, and make testing and maintenance easier.',
        'example': 'def hi():\n  print("Hi")\nhi()',
        'output': 'Hi',
        'keyTakeaway': 'Functions organize programs.',
      },
    ],

    // ================= INTERMEDIATE =================
    'Intermediate': [
      {
        'title': 'Lists',
        'content':
            'Lists store multiple values in a single variable and keep them in order. You can add, remove, or update items and loop through them to process data efficiently.',
        'example': 'nums = [1,2,3]\nprint(nums)',
        'output': '[1, 2, 3]',
        'keyTakeaway': 'Lists hold collections.',
      },
      {
        'title': 'Tuples',
        'content':
            'Tuples are immutable lists, which means their values cannot be changed after creation. Use tuples to store fixed collections of related data for safety and clarity.',
        'example': 't = (1,2)\nprint(t)',
        'output': '(1, 2)',
        'keyTakeaway': 'Tuples cannot change.',
      },
      {
        'title': 'Dictionaries',
        'content':
            'Dictionaries store key-value pairs and are perfect for fast lookups. They let you map meaningful keys to values, which is useful for structured data like profiles and settings.',
        'example': 'd = {"a":1}\nprint(d)',
        'output': "{'a': 1}",
        'keyTakeaway': 'Keys map to values.',
      },
      {
        'title': 'While Loop',
        'content':
            'While loops repeat until a condition fails. They are useful when you do not know in advance how many iterations are needed, such as waiting for valid user input.',
        'example': 'i = 0\nwhile i < 2:\n  print(i)\n  i+=1',
        'output': '0\n1',
        'keyTakeaway': 'While loops are condition-based.',
      },
      {
        'title': 'Functions with Parameters',
        'content':
            'Functions accept inputs through parameters so they can work with different data each time they run. This makes your code flexible and reusable across many tasks.',
        'example': 'def add(a,b): return a+b\nprint(add(2,3))',
        'output': '5',
        'keyTakeaway': 'Parameters make functions flexible.',
      },
      {
        'title': 'Return Statement',
        'content':
            'Return sends a value back from a function to the caller. It allows you to build functions that compute results instead of only printing them.',
        'example': 'def sq(x): return x*x\nprint(sq(4))',
        'output': '16',
        'keyTakeaway': 'Return gives results.',
      },
      {
        'title': 'File Reading',
        'content':
            'Files store data persistently on disk. Reading from files lets your program process saved information such as logs, configurations, and datasets.',
        'example': 'file = open("a.txt","r")',
        'output': 'File opened',
        'keyTakeaway': 'Files store permanent data.',
      },
      {
        'title': 'File Writing',
        'content':
            'Writing data into files lets your program save results for later use. It is essential for exporting reports, saving user settings, or recording activity.',
        'example': 'file = open("a.txt","w")',
        'output': 'File written',
        'keyTakeaway': 'Writing saves data.',
      },
      {
        'title': 'Modules',
        'content':
            'Modules organize code into reusable files. Python has a rich ecosystem of modules, and importing them helps you avoid reinventing common functionality.',
        'example': 'import math\nprint(math.sqrt(16))',
        'output': '4.0',
        'keyTakeaway': 'Modules reuse code.',
      },
      {
        'title': 'Exception Handling',
        'content':
            'Exception handling lets your program recover from errors instead of crashing. Using try and except blocks helps you handle unexpected cases gracefully.',
        'example': 'try:\n  print(5/0)\nexcept:\n  print("Error")',
        'output': 'Error',
        'keyTakeaway': 'Exceptions prevent crashes.',
      },
    ],

    // ================= ADVANCED =================
    'Advanced': [
      {
        'title': 'OOP Basics',
        'content':
            'Object-oriented programming uses classes and objects to model real-world concepts. It helps you organize complex programs by grouping data and behavior together.',
        'example': 'class A: pass',
        'output': 'Class created',
        'keyTakeaway': 'OOP structures code.',
      },
      {
        'title': 'Classes & Objects',
        'content':
            'Objects are instances of classes and represent specific entities in your program. Each object can store its own data and perform actions using methods.',
        'example': 'class A: pass\na = A()',
        'output': 'Object created',
        'keyTakeaway': 'Objects represent data.',
      },
      {
        'title': 'Constructors',
        'content':
            'Constructors initialize objects and set up their starting state. In Python, the __init__ method runs automatically when you create a new object.',
        'example': 'class A:\n def __init__(self): print("Hi")\nA()',
        'output': 'Hi',
        'keyTakeaway': 'Constructors run automatically.',
      },
      {
        'title': 'Inheritance',
        'content':
            'Inheritance allows a class to reuse and extend behavior from another class. It reduces duplication and creates a clean hierarchy of related classes.',
        'example': 'class B(A): pass',
        'output': 'Inherited',
        'keyTakeaway': 'Inheritance reuses code.',
      },
      {
        'title': 'Polymorphism',
        'content':
            'Polymorphism means the same method name can behave differently depending on the object. This flexibility makes your code more scalable and easier to maintain.',
        'example': 'print(len("Hi"))',
        'output': '2',
        'keyTakeaway': 'Polymorphism is flexibility.',
      },
      {
        'title': 'Encapsulation',
        'content':
            'Encapsulation protects data inside classes by controlling access. It helps keep your objects consistent and prevents unintended changes from outside code.',
        'example': 'self.__x = 5',
        'output': 'Private variable',
        'keyTakeaway': 'Encapsulation secures data.',
      },
      {
        'title': 'Recursion',
        'content':
            'Recursion is when a function calls itself to solve smaller versions of a problem. It is powerful for tasks like traversing trees or breaking down complex problems.',
        'example': 'def f(): f()',
        'output': 'Recursive call',
        'keyTakeaway': 'Recursion repeats logic.',
      },
      {
        'title': 'Lambda Functions',
        'content':
            'Lambda functions are short anonymous functions written in a single line. They are often used for quick transformations or in places where a full function is unnecessary.',
        'example': 'x = lambda a: a+1\nprint(x(5))',
        'output': '6',
        'keyTakeaway': 'Lambda = short function.',
      },
      {
        'title': 'Decorators',
        'content':
            'Decorators modify function behavior without changing the function code itself. They are commonly used for logging, access control, and performance monitoring.',
        'example': '@decorator\ndef f(): pass',
        'output': 'Decorated',
        'keyTakeaway': 'Decorators enhance functions.',
      },
      {
        'title': 'Virtual Environments',
        'content':
            'Virtual environments create isolated spaces for project dependencies. They prevent version conflicts and make it easier to manage packages across multiple projects.',
        'example': 'python -m venv env',
        'output': 'Environment created',
        'keyTakeaway': 'Venv manages dependencies.',
      },
    ],
  };

  // ===== GLASS CARD =====
  Widget glassCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lessons = lessonData[widget.level] ?? [];
    final lesson = lessons.isNotEmpty ? lessons[currentLesson - 1] : null;

    if (lesson == null) {
      return const Scaffold(
        backgroundColor: bgColor,
        body: Center(child: Text('Lesson not found')),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor.withOpacity(0.85),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [accent, accentDark]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.code_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Pyacademy',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.level} · Lesson $currentLesson',
              style: const TextStyle(
                color: accent,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              lesson['title']!,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: currentLesson / lessons.length,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(accent),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 24),

            // ===== CONTENT =====
            glassCard(
              child: Text(
                lesson['content']!,
                style: const TextStyle(color: Colors.white70, height: 1.8),
              ),
            ),
            const SizedBox(height: 20),

            // ===== CODE EXAMPLE =====
            glassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Code Example',
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      InkWell(
                        onTap: () => setState(() => _showOutput = true),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [accent, accentDark],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: codeBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      lesson['example']!,
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        color: Color(0xFF90EE90),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_showOutput) ...[
              const SizedBox(height: 16),
              glassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Output',
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      lesson['output']!,
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // ===== KEY TAKEAWAY =====
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [accent, accentDark]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💡 Key Takeaway',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lesson['keyTakeaway']!,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ===== NAVIGATION =====
            Row(
              children: [
                if (currentLesson > 1)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          currentLesson--;
                          _showOutput = false;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: accent, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Previous',
                        style: TextStyle(color: accent),
                      ),
                    ),
                  ),
                if (currentLesson > 1) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (currentLesson < lessons.length) {
                        setState(() {
                          currentLesson++;
                          ProgressData.completedLessons[widget.level] =
                              currentLesson;
                          _showOutput = false;
                        });
                        _progressService.saveLessonProgress(
                          level: widget.level,
                          lessonsCompleted: currentLesson,
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                QuizScreen(level: widget.level, quizNumber: 1),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 10,
                    ),
                    child: Text(
                      currentLesson == lessons.length
                          ? 'Go to Quiz'
                          : 'Next Lesson',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
