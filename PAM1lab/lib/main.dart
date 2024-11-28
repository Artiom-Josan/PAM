import 'package:flutter/material.dart';

void main() {
  runApp(BMICalculator());
}

class BMICalculator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BMICalculatorPage(),
    );
  }
}

class BMICalculatorPage extends StatefulWidget {
  @override
  _BMICalculatorPageState createState() => _BMICalculatorPageState();
}

class _BMICalculatorPageState extends State<BMICalculatorPage> {
  double weight = 70;
  double age = 23;
  double height = 170;
  String gender = "Male";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 195, 208, 250),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 50),
              Text(
                'Welcome 😊',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                'BMI Calculator',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 200,
                  child: GenderButton(
                    title: 'Male',
                    isSelected: gender == "Male",
                    onTap: () {
                      setState(() {
                        gender = "Male";
                      });
                    },
                  ),
                ),
                   SizedBox(width: 20),
                SizedBox(
                  width: 200,  
                  child: GenderButton(
                    title: 'Female',
                    isSelected: gender == "Female",
                    onTap: () {
                      setState(() {
                        gender = "Female";
                      });
                    },
                  ),
                ),
              ],
),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  NumberSelector(
                    label: 'Weight',
                    value: weight,
                    onChanged: (newValue) {
                      setState(() {
                        weight = newValue;
                      });
                    },
                  ),
                  NumberSelector(
                    label: 'Age',
                    value: age,
                    onChanged: (newValue) {
                      setState(() {
                        age = newValue;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Height',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Height',
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      height = double.parse(value);
                    });
                  },
                ),
              ),
              SizedBox(height: 30),
              Text(
                calculateBMI(),
                style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              Text(
                getBMICategory(),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade600),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Lets Go',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String calculateBMI() {
    double bmi = weight / ((height / 100) * (height / 100));
    return bmi.toStringAsFixed(1);
  }

  String getBMICategory() {
    double bmi = weight / ((height / 100) * (height / 100));
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi < 25) {
      return 'Normal';
    } else if (bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }
}

class GenderButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  GenderButton({required this.title, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.blue),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            color: isSelected ? Colors.white : Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class NumberSelector extends StatelessWidget {
  final String label;
  final double value;
  final Function(double) onChanged;

  NumberSelector({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.remove, size: 30),
              onPressed: () {
                onChanged(value - 1);
              },
            ),
            Text(
              value.toInt().toString(),
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(Icons.add, size: 30),
              onPressed: () {
                onChanged(value + 1);
              },
            ),
          ],
        ),
      ],
    );
  }
}
