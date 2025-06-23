import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _weightController = TextEditingController();
  final _heightFeetController = TextEditingController();
  final _heightInchController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  String _result = '';
  String _message = '';
  double _opacity = 0;
  bool _isDarkMode = false;

  void _calculateBMI() {
    if (!_formKey.currentState!.validate()) return;

    final weight = double.parse(_weightController.text.trim());
    final feet = int.parse(_heightFeetController.text.trim());
    final inches = int.parse(_heightInchController.text.trim());

    final totalInches = feet * 12 + inches;
    final meters = totalInches * 0.0254;
    final bmi = weight / (meters * meters);

    if (bmi < 18.5) {
      _message = 'You are under-weight';
    } else if (bmi < 25) {
      _message = 'You have normal weight';
    } else if (bmi < 30) {
      _message = 'You are over-weight';
    } else {
      _message = 'You lie in obese category';
    }

    setState(() {
      _result = '$_message\nYour BMI is: ${bmi.toStringAsFixed(2)}';
      _opacity = 0;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() => _opacity = 1);
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
  }

  void _resetFields() {
    _weightController.clear();
    _heightFeetController.clear();
    _heightInchController.clear();

    setState(() {
      _result = '';
      _message = '';
      _opacity = 0;
    });
  }

  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightFeetController.dispose();
    _heightInchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.teal,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('BMI Calculator'),
          centerTitle: true,
          actions: [
            Row(
              children: [
                const Icon(Icons.light_mode),
                Switch(
                  value: _isDarkMode,
                  onChanged: _toggleTheme,
                ),
                const Icon(Icons.dark_mode),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          double maxWidth =
              constraints.maxWidth < 450 ? constraints.maxWidth * 0.9 : 400;

          return SingleChildScrollView(
            controller: _scrollController,
            child: Center(
              child: Container(
                width: maxWidth,
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      const Text(
                        'Body Mass Index (BMI)',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      _buildNumberField(
                        controller: _weightController,
                        label: 'Weight in Kg',
                        icon: Icons.line_weight,
                        validatorMsg: 'Please enter your weight',
                        isDecimal: true,
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: _buildNumberField(
                              controller: _heightFeetController,
                              label: 'Height (Feet)',
                              icon: Icons.height,
                              validatorMsg: 'Please enter feet',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildNumberField(
                              controller: _heightInchController,
                              label: 'Height (Inches)',
                              icon: Icons.height_outlined,
                              validatorMsg: 'Please enter inches',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      ElevatedButton(
                        onPressed: _calculateBMI,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Calculate BMI',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      if (_result.isNotEmpty) ...[
                        const SizedBox(height: 30),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 500),
                          opacity: _opacity,
                          child: Card(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                _result,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        OutlinedButton(
                          onPressed: _resetFields,
                          child: const Text('Reset'),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String validatorMsg,
    bool isDecimal = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isDecimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return validatorMsg;
        final parsed = isDecimal
            ? double.tryParse(value.trim())
            : int.tryParse(value.trim());
        if (parsed == null || parsed <= 0) {
          return 'Enter a valid positive number';
        }
        return null;
      },
    );
  }
}
