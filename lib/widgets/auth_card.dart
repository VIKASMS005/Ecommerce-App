import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
//import '../screens/home_screen.dart';

enum AuthMode { signUp, login }

class AuthCard extends StatefulWidget {
  const AuthCard({super.key});

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.login;
  final Map<String, String> _authData = {'email': '', 'password': ''};
  var isLoading = false;
  final _passwordController = TextEditingController();
  late AnimationController _animationController;
  //late Animation<Size> _heightAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    // _heightAnimation = Tween<Size>(
    //   begin: Size(double.infinity, 260),
    //   end: Size(double.infinity, 320),
    // ).animate(
    //   CurvedAnimation(
    //     parent: _animationController,
    //     curve: Curves.fastOutSlowIn,
    //   ),
    // );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1.5),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // _heightAnimation.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      isLoading = true;
    });

    try {
      if (_authMode == AuthMode.login) {
        await Provider.of<Auth>(
          context,
          listen: false,
        ).login(_authData['email']!, _authData['password']!);
      } else {
        await Provider.of<Auth>(
          context,
          listen: false,
        ).signup(_authData['email']!, _authData['password']!);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Authentication failed')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.login) {
      setState(() {
        _authMode = AuthMode.signUp;
      });
      _animationController.forward();
    } else {
      setState(() {
        _authMode = AuthMode.login;
      });
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 8,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
        height:
            _authMode == AuthMode.signUp
                ? deviceSize.height * 0.38
                : deviceSize.height * 0.32,
        // height: _heightAnimation.value.height,
        constraints: BoxConstraints(
          minHeight:
              _authMode == AuthMode.signUp
                  ? deviceSize.height * 0.38
                  : deviceSize.height * 0.32,
          // minHeight: _heightAnimation.value.height,
        ),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-Mail :'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty ||
                        !value.contains('@gmail.com')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password :'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value!.isEmpty || value.length < 7) {
                      return 'Password is too short!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['password'] = value!;
                  },
                ),

                AnimatedContainer(
                  constraints: BoxConstraints(
                    minHeight:
                        _authMode == AuthMode.signUp
                            ? deviceSize.height * 0.07
                            : 0,
                    maxHeight:
                        _authMode == AuthMode.signUp
                            ? deviceSize.height * 0.14
                            : 0,
                  ),
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: TextFormField(
                        enabled: _authMode == AuthMode.signUp,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password :',
                          // enabledBorder: UnderlineInputBorder(
                          //   borderSide: BorderSide(
                          //     color: Colors.grey,
                          //     width: 1,
                          //   ),
                          // ),
                        ),
                        obscureText: true,
                        validator:
                            _authMode == AuthMode.signUp
                                ? (value) {
                                  if (value != _passwordController.text) {
                                    return 'Password do not match!';
                                  }
                                  return null;
                                }
                                : null,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                if (isLoading)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 8.0,
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: Text(
                      _authMode == AuthMode.login ? 'LOGIN' : 'SIGNUP',
                    ),
                  ),
                TextButton(
                  onPressed: _switchAuthMode,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    '${_authMode == AuthMode.login ? 'SIGNUP' : 'LOGIN'} INSTEAD',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
