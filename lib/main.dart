import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:collection';
import 'jar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Jungle',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Money Jungle'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _balance = 100;
  late TextEditingController _balanceController;
  List<LinkedHashMap<String, dynamic>> _jars = [
    LinkedHashMap<String, dynamic>.from({'title': 'Needs', 'percentage': 0.4}),
    LinkedHashMap<String, dynamic>.from({'title': 'Fun', 'percentage': 0.1}),
    LinkedHashMap<String, dynamic>.from({'title': 'Save', 'percentage': 0.2}),
    LinkedHashMap<String, dynamic>.from({'title': 'Invest', 'percentage': 0.2}),
    LinkedHashMap<String, dynamic>.from({'title': 'Give', 'percentage': 0.1}),
  ];
  List<TextEditingController> _titleControllers = [];

  @override
  void initState() {
    super.initState();
    _balanceController = TextEditingController();
    _loadData().then((_) {
      setState(() {});
    });
    _initializeTitleControllers();
  }

  void _initializeTitleControllers() {
    _titleControllers = _jars.map((jar) {
      return TextEditingController(text: jar['title']);
    }).toList();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _balance = prefs.getInt('balance') ?? 100;
    _balanceController.text = _balance.toString();
    String? jarsString = prefs.getString('jars');
    if (jarsString != null) {
      _jars = (json.decode(jarsString) as List)
          .map((item) => LinkedHashMap<String, dynamic>.from(item))
          .toList();
      _initializeTitleControllers();
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('balance', _balance);
    prefs.setString('jars', json.encode(_jars));
  }

  bool _onPercentageChanged(double newPercentage, bool isReleased, int jarIndex) {
    double totalPercentage = _jars.fold(0, (sum, jar) => sum + jar['percentage']);
    double otherJarPercentage = totalPercentage - _jars[jarIndex]['percentage'];
    if (newPercentage + otherJarPercentage <= 1.0) {
      setState(() {
        _jars[jarIndex]['percentage'] = newPercentage;
        if (isReleased) {
          _saveData();
        }
      });
      return true;
    }
    return false;
  }

  void _onTitleChanged(String newTitle, int jarIndex) {
    setState(() {
      _jars[jarIndex]['title'] = newTitle;
      _saveData();
    });
  }

  void _addJar() {
    setState(() {
      int jarNumber = _jars.length + 1;
      _jars.add(LinkedHashMap<String, dynamic>.from({'title': 'Jar $jarNumber', 'percentage': 0.0}));
      _titleControllers.add(TextEditingController(text: 'Jar $jarNumber'));
      _saveData();
    });
  }

  void _removeJar(int jarIndex) {
    setState(() {
      _jars.removeAt(jarIndex);
      _titleControllers.removeAt(jarIndex);
      _saveData();
    });
  }

  // lib/main.dart

  @override
  Widget build(BuildContext context) {
    if (_balanceController.text.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    double totalPercentage = _jars.fold(0, (sum, jar) => sum + jar['percentage']);
    double leftoverPercentage = 1.0 - totalPercentage;
    int leftoverBalance = (_balance * leftoverPercentage).round();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 200, // Set a fixed width for the TextField
                  child: TextField(
                    controller: _balanceController,
                    keyboardType: TextInputType.number,
                    onChanged: _valueChanged,
                    style: const TextStyle(fontSize: 48,
                      fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      labelText: 'Balance (€)',
                    ),
                  ),

                ),
                // some empty space
                const SizedBox(height: 20),
                ..._jars.asMap().entries.map((entry) {
                  int index = entry.key;
                  LinkedHashMap<String, dynamic> jar = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Jar(
                      titleController: _titleControllers[index],
                      blnc: _balance,
                      percentage: jar['percentage'],
                      onPercentageChanged: (newPercentage, isReleased) => _onPercentageChanged(newPercentage, isReleased, index),
                      onTitleChanged: (newTitle) => _onTitleChanged(newTitle, index),
                      onRemove: () => _removeJar(index),
                    ),
                  );
                }),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addJar,
                  child: // A plus icon
                  const Icon(Icons.add,
                    size: 72),

                ),
                const SizedBox(height: 20),
                Text(
                  'Leftover: $leftoverBalance€ (${(leftoverPercentage * 100).toStringAsFixed(2)}%)',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _valueChanged(String value) {
    setState(() {
      _balance = int.parse(value);
      _saveData();
    });
  }
}