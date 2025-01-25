import 'package:flutter/material.dart';
import 'nbi_header.dart';

class JobseekerRegistrationScreen extends StatefulWidget {
  const JobseekerRegistrationScreen({super.key});

  @override
  _JobseekerRegistrationScreenState createState() => _JobseekerRegistrationScreenState();
}

class _JobseekerRegistrationScreenState extends State<JobseekerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _motherFirstNameController = TextEditingController();
  final _motherMiddleNameController = TextEditingController();
  final _motherSurnameController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  DateTime? selectedDate;
  String? gender;
  String? civilStatus;
  bool acceptTerms = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _showValidationDialog(String message) {
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text('Registration Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Personal Details:'),
              Text('Sex: $gender'),
              Text('Civil Status: $civilStatus'), 
              Text('Birth Date: ${selectedDate?.toString().split(' ')[0]}'),
              Text('Name: ${_firstNameController.text} ${_middleNameController.text} ${_surnameController.text}'),
              Text('\nMother\'s Details:'),
              Text('Name: ${_motherFirstNameController.text} ${_motherMiddleNameController.text} ${_motherSurnameController.text}'),
              Text('\nContact Details:'),
              Text('Mobile: ${_mobileNumberController.text}'),
              Text('Email: ${_emailController.text}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[900],
      body: SingleChildScrollView(
        child: Column(
          children: [
            NbiHeader(showBackButton: true),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Personal Identity',
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                    SizedBox(height: 20),
                    
                    // Alignment 1: Gender and Civil Status
                    Row(
                      children: [
                        Expanded(child: _buildGenderDropdown()),
                        SizedBox(width: 10),
                        Expanded(child: _buildCivilStatusDropdown()),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Alignment 2: Birthdate
                    _buildBirthDatePicker(),
                    SizedBox(height: 20),

                    // Alignment 3-5: Name fields
                    _buildTextField(_firstNameController, 'First Name'),
                    SizedBox(height: 20),
                    _buildTextField(_middleNameController, 'Middle Name'),
                    SizedBox(height: 20),
                    _buildTextField(_surnameController, 'Surname'),
                    SizedBox(height: 30),

                    // Mother's Maiden Name section
                    Text('Mother\'s Maiden Name',
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                    SizedBox(height: 20),

                    // Alignment 6: Mother's name fields
                    Row(
                      children: [
                        Expanded(child: _buildTextField(_motherFirstNameController, 'First Name')),
                        SizedBox(width: 10),
                        Expanded(child: _buildTextField(_motherMiddleNameController, 'Middle Name')),
                        SizedBox(width: 10),
                        Expanded(child: _buildTextField(_motherSurnameController, 'Last Name')),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Alignment 7-8: Contact details
                    _buildTextField(_mobileNumberController, 'Mobile Number (09XXXXXXXXX)'),
                    SizedBox(height: 20),
                    _buildTextField(_emailController, 'Enter new Email Address'),
                    SizedBox(height: 20),

                    // Alignment 9: Password fields
                    Row(
                      children: [
                        Expanded(child: _buildPasswordField(_passwordController, 'Enter new Password', _showPassword)),
                        SizedBox(width: 10),
                        Expanded(child: _buildConfirmPasswordField()),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Alignment 10: Terms of Service
                    Row(
                      children: [
                        Checkbox(
                          value: acceptTerms,
                          onChanged: (value) => setState(() => acceptTerms = value ?? false),
                          fillColor: WidgetStateProperty.all(Colors.white),
                          checkColor: Colors.brown[900],
                        ),
                        Text('I have read and accept the ', style: TextStyle(color: Colors.white)),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TermsOfServiceScreen()),
                          ),
                          child: Text('TERMS OF SERVICE',
                              style: TextStyle(color: Colors.yellow, decoration: TextDecoration.underline)),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Alignment 11: Sign up button
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        side: BorderSide(color: Colors.yellow, width: 2),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate() && acceptTerms) {
                          _showValidationDialog('Registration successful!\n\n${_getFormData()}');
                        } else {
                          _showValidationDialog('Please fill all required fields and accept the terms of service.');
                        }
                      },
                      child: Text('SIGN UP', style: TextStyle(color: Colors.yellow)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFormData() {
    return '''
      Personal Details:
      Sex: $gender
      Civil Status: $civilStatus
      Birth Date: ${selectedDate?.toString().split(' ')[0]}
      Full Name: ${_firstNameController.text} ${_middleNameController.text} ${_surnameController.text}
      
      Mother's Details:
      Full Name: ${_motherFirstNameController.text} ${_motherMiddleNameController.text} ${_motherSurnameController.text}
      
      Contact Details:
      Mobile: ${_mobileNumberController.text}
      Email: ${_emailController.text}
    ''';
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      maxLength: label.contains('Mobile') ? 11 : null,
      keyboardType: label.contains('Mobile') ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
        border: OutlineInputBorder(borderRadius: BorderRadius.zero),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: Colors.yellow, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: Colors.yellow, width: 2),
        ),
        counterStyle: TextStyle(color: Colors.white),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) return 'This field is required';
        if (label.contains('Mobile') && value!.length != 11) {
          return 'Mobile number must be 11 digits';
        }
        return null;
      },
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: gender,
      decoration: InputDecoration(
        labelText: 'Select Sex',
        labelStyle: TextStyle(color: Colors.white),
        border: OutlineInputBorder(borderRadius: BorderRadius.zero),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: Colors.yellow, width: 2),
        ),
      ),
      style: TextStyle(color: Colors.white),
      dropdownColor: Colors.brown[900],
      items: ['MALE', 'FEMALE'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: TextStyle(color: Colors.white)),
        );
      }).toList(),
      onChanged: (value) => setState(() => gender = value),
    );
  }

  Widget _buildCivilStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: civilStatus,
      decoration: InputDecoration(
        labelText: 'Select Civil Status',
        labelStyle: TextStyle(color: Colors.white),
        border: OutlineInputBorder(borderRadius: BorderRadius.zero),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: Colors.yellow, width: 2),
        ),
      ),
      style: TextStyle(color: Colors.white),
      dropdownColor: Colors.brown[900],
      items: ['SINGLE', 'MARRIED', 'SEPARATED', 'WIDOW', 'DIVORCED',
             'ANNULLED', 'WIDOWER', 'SINGLE PARENT'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: TextStyle(color: Colors.white)),
        );
      }).toList(),
      onChanged: (value) => setState(() => civilStatus = value),
    );
  }

  Widget _buildBirthDatePicker() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Birth Date',
          labelStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(borderRadius: BorderRadius.zero),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: Colors.yellow, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: Colors.yellow, width: 2),
          ),
        ),
        child: Text(
          selectedDate != null
              ? "${selectedDate!.toLocal()}".split(' ')[0]
              : 'Select Date',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label, bool showPassword) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
        border: OutlineInputBorder(borderRadius: BorderRadius.zero),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: Colors.yellow, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: Colors.yellow, width: 2),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            showPassword ? Icons.visibility : Icons.visibility_off,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _showPassword = !_showPassword;
            });
          },
        ),
      ),
      obscureText: !showPassword,
      validator: (value) {
        if (value == null || value.isEmpty || value.length < 6) {
          return 'Please enter a valid password';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      obscureText: !_showConfirmPassword,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        labelStyle: TextStyle(color: Colors.white),
        border: OutlineInputBorder(borderRadius: BorderRadius.zero),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: Colors.yellow, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: Colors.yellow, width: 2),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _showConfirmPassword = !_showConfirmPassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }
}

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[900],
      body: Column(
        children: [
          NbiHeader(showBackButton: true),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Terms of Service',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    '''
1. ACCEPTANCE OF TERMS
By accessing and using the NBI Clearance Online Services, you agree to be bound by these Terms of Service.

2. ELIGIBILITY
You must be a first-time jobseeker to be eligible for this service.

3. PERSONAL INFORMATION
You agree to provide accurate and complete information during registration.

4. PRIVACY POLICY
Your personal information will be handled in accordance with our Privacy Policy.

5. USER RESPONSIBILITIES
You are responsible for maintaining the confidentiality of your account.

6. SERVICE MODIFICATIONS
We reserve the right to modify or discontinue the service at any time.

7. LIMITATION OF LIABILITY
We shall not be liable for any indirect, incidental, special, or consequential damages.
                    ''',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    onPressed: () {
                      // Reset form and navigate back
                      Navigator.pop(context, false);
                    },
                    child: Text('DECLINE', style: TextStyle(color: Colors.red)),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.yellow, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    onPressed: () {
                      // Accept terms and navigate back
                      Navigator.pop(context, true);
                    },
                    child: Text('ACCEPT', style: TextStyle(color: Colors.yellow)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
