import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


// assignment 5
class Subject {
  final String name;
  final int _mark;

  Subject({required this.name, required int mark}) : _mark = mark;

  int get mark => _mark;

  String get grade {
    if (_mark >= 80) return 'A';
    if (_mark >= 65) return 'B';
    if (_mark >= 50) return 'C';
    return 'F';
  }
}

class GradeProvider extends ChangeNotifier {
  final List<Subject> _subjects = [];
  bool _isDarkMode = false;

  List<Subject> get subjects => _subjects;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void addSubject(Subject subject) {
    _subjects.add(subject);
    notifyListeners();
  }

  void removeSubject(int index) {
    _subjects.removeAt(index);
    notifyListeners();
  }

  List<Subject> get passingSubjects {
    return _subjects.where((subject) => subject.grade != 'F').toList();
  }

  int get totalSubjects => _subjects.length;

  double get averageMark {
    if (_subjects.isEmpty) return 0.0;
    int totalMarks = _subjects.fold(0, (sum, item) => sum + item.mark);
    return totalMarks / _subjects.length;
  }

  String get overallGrade {
    double avg = averageMark;
    if (avg >= 80) return 'A';
    if (avg >= 65) return 'B';
    if (avg >= 50) return 'C';
    return 'F';
  }
}


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GradeProvider(),
      child: const StudentGradeTrackerApp(),
    ),
  );
}

class StudentGradeTrackerApp extends StatelessWidget {
  const StudentGradeTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<GradeProvider>(context);

    final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.grey[100],
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      colorScheme: ColorScheme.light(
        primary: Colors.teal,
        secondary: Colors.tealAccent[700]!,
        surface: Colors.white,
        onSurface: Colors.black,
      ),
    );


    final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.grey[950],
      appBarTheme: Colors.blueGrey[900] != null
          ? AppBarTheme(backgroundColor: Colors.blueGrey[900], foregroundColor: Colors.white, elevation: 0)
          : null,
      colorScheme: ColorScheme.dark(
        primary: Colors.blueGrey[700]!,
        secondary: Colors.amber,
        surface: Colors.grey[900]!,
        onSurface: Colors.white,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Grade Tracker',
      theme: themeProvider.isDarkMode ? darkTheme : lightTheme,
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const AddSubjectScreen(),
    const SubjectListScreen(),
    const SummaryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GradeProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grade Tracker'),
        actions: [
          IconButton(
            icon: Icon(context.watch<GradeProvider>().isDarkMode
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () => provider.toggleTheme(),
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Add Subject'),
          BottomNavigationBarItem(icon: Icon(Icons.format_list_bulleted), label: 'Subjects'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Summary'),
        ],
      ),
    );
  }
}

class AddSubjectScreen extends StatelessWidget {
  const AddSubjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final markController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Subject Name',
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Subject name cannot be empty';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: markController,
              decoration: const InputDecoration(
                labelText: 'Marks (0 - 100)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter marks';
                }
                final mark = int.tryParse(value);
                if (mark == null || mark < 0 || mark > 100) {
                  return 'Marks must be between 0 and 100';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newSubject = Subject(
                    name: nameController.text.trim(),
                    mark: int.parse(markController.text),
                  );
                  Provider.of<GradeProvider>(context, listen: false).addSubject(newSubject);

                  nameController.clear();
                  markController.clear();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Subject Added Successfully!')),
                  );
                }
              },
              child: const Text('Add Subject', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

class SubjectListScreen extends StatelessWidget {
  const SubjectListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GradeProvider>();
    final subjects = provider.subjects;

    if (subjects.isEmpty) {
      return Center(
        child: Text(
          'No subjects added yet!',
          style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
        ),
      );
    }

    return ListView.builder(
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return Dismissible(
          key: UniqueKey(),
          background: Container(
            color: Colors.red[700],
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            Provider.of<GradeProvider>(context, listen: false).removeSubject(index);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${subject.name} removed.')),
            );
          },
          child: Card(
            color: Theme.of(context).colorScheme.surface,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(
                subject.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                'Marks: ${subject.mark}',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
              ),
              trailing: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                child: Text(subject.grade, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        );
      },
    );
  }
}

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GradeProvider>();
    int passingCount = provider.passingSubjects.length;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSummaryCard(context, 'Total Subjects', '${provider.totalSubjects}'),
          _buildSummaryCard(context, 'Passed Subjects', '$passingCount'),
          _buildSummaryCard(context, 'Average Mark', provider.averageMark.toStringAsFixed(2)),
          _buildSummaryCard(context, 'Overall Grade', provider.overallGrade, isGrade: true),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value, {bool isGrade = false}) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isGrade ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}