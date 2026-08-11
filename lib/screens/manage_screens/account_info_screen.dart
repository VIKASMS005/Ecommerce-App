import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/widgets/profile_pic.dart';
import '../../models/profile.dart';
import '../../providers/profile_provider.dart';
import 'dart:io';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  static const routeName = '/accountInfo';

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

Widget buildCard(String title, IconData icon, List<Widget> children) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Icon(icon, size: 28),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ...children,
      ],
    ),
  );
}

Widget buildTextField(
  TextEditingController controller,
  String label,
  TextInputType keyboardType,
  int maxLines,
  bool readOnly,
  String? Function(String?)? validator,
) {
  return Padding(
    padding: const EdgeInsets.all(8),
    child: TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
  );
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _emailController = TextEditingController(
    text: FirebaseAuth.instance.currentUser?.email,
  );
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedGender;

  var isInit = true;
  var isLoading = true;

  Future<void> _selectImage(File pickedImage) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).saveToDB(user.uid, pickedImage.path);
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      _loadProfile();
      isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _aboutController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null) return;

    setState(() {
      _selectedDate = pickedDate;

      _dobController.text =
          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
    });
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    final profileProvider = Provider.of<ProfileProvider>(context);
    final scaffold = ScaffoldMessenger.of(context);
    try {
      await profileProvider.loadProfile();
      final profile = profileProvider.profile;
      _selectedDate = profile?.dateOfBirth;
      if (profile != null) {
        _firstNameController.text = profile.firstName;
        _lastNameController.text = profile.lastName;
        _emailController.text = profile.email;
        _phoneController.text = profile.phone;
        _aboutController.text = profile.bio;
        _dobController.text =
            "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}";
        _selectedGender = profile.gender;
      } else {
        _emailController.text = user?.email ?? '';
      }
    } catch (error) {
      scaffold.showSnackBar(
        SnackBar(content: Text('Failed to load profile: $error')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your date of birth')),
      );
      return;
    }

    _formKey.currentState!.save();

    final profile = Profile(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      dateOfBirth: _selectedDate!,
      gender: _selectedGender ?? '',
      bio: _aboutController.text,
    );

    final scaffold = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() {
      isLoading = true;
    });
    try {
      await Provider.of<ProfileProvider>(
        context,
        listen: false,
      ).saveProfile(profile);
      scaffold.showSnackBar(
        SnackBar(content: Text('Profile saved successfully')),
      );
      navigator.pop();
    } catch (error) {
      scaffold.showSnackBar(
        SnackBar(content: Text('Failed to save profile : $error')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Account")),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text("Account")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Center(
              child: ProfilePic(
                showCameraIcon: true,
                onSelectImage: _selectImage,
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  buildCard("Personal Information", Icons.person, [
                    buildTextField(
                      _firstNameController,
                      "First Name",
                      TextInputType.name,
                      1,
                      false,
                      (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(value)) {
                          return 'First name can only contain letters';
                        }
                        return null;
                      },
                    ),
                    buildTextField(
                      _lastNameController,
                      "Last Name",
                      TextInputType.name,
                      1,
                      false,
                      (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(value)) {
                          return 'Last name can only contain letters';
                        }
                        return null;
                      },
                    ),
                    buildTextField(
                      _aboutController,
                      "About You",
                      TextInputType.multiline,
                      3,
                      false,
                      (value) {
                        if (value!.length > 200) {
                          return 'About you must be less than 200 characters';
                        }
                        return null;
                      },
                    ),
                  ]),

                  const SizedBox(height: 14),

                  buildCard("Contact Information", Icons.phone, [
                    buildTextField(
                      _emailController,
                      "Email",
                      TextInputType.emailAddress,
                      1,
                      true,
                      (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    buildTextField(
                      _phoneController,
                      "Phone",
                      TextInputType.phone,
                      1,
                      false,
                      (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(value)) {
                          return 'Please enter a valid phone number';
                        }
                        if (value.length != 10) {
                          return 'Please enter a valid phone number';
                        }
                        if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                          return 'Please enter a valid 10-digit phone number';
                        }
                        return null;
                      },
                    ),
                  ]),

                  const SizedBox(height: 14),

                  buildCard("Additional Information", Icons.info, [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextFormField(
                        controller: _dobController,
                        readOnly: true,
                        onTap: _pickDate,
                        decoration: InputDecoration(
                          labelText: "Date of Birth",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your date of birth';
                          }
                          return null;
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedGender,
                        decoration: InputDecoration(
                          labelText: "Gender",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: "Male", child: Text("Male")),
                          DropdownMenuItem(
                            value: "Female",
                            child: Text("Female"),
                          ),
                          DropdownMenuItem(
                            value: "Other",
                            child: Text("Other"),
                          ),
                          DropdownMenuItem(
                            value: "Prefer not to say",
                            child: Text("Prefer not to say"),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your gender';
                          }
                          return null;
                        },
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                _saveForm();
              },
              icon: const Icon(
                Icons.save_outlined,
                size: 25,
                color: Colors.white,
              ),
              label: const Text(
                'Save Address',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ButtonStyle(
                elevation: WidgetStatePropertyAll(0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: WidgetStatePropertyAll(
                  Theme.of(context).primaryColor,
                ),
                foregroundColor: WidgetStatePropertyAll(Colors.white),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
