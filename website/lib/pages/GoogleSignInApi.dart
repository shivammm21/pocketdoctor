import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInApi {
  static final _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  static Future<GoogleSignInAccount?> login() async {
    try {
      return await _googleSignIn.signIn();
    } catch (error) {
      print('Google Sign-In Error: $error');
      return null;
    }
  }

  static Future<void> logout() async {
    await _googleSignIn.signOut();
  }
}

class GoogleSignInExample extends StatefulWidget {
  @override
  _GoogleSignInExampleState createState() => _GoogleSignInExampleState();
}

class _GoogleSignInExampleState extends State<GoogleSignInExample> {
  GoogleSignInAccount? _user;

  Future<void> _handleSignIn() async {
    final user = await GoogleSignInApi.login();
    setState(() {
      _user = user;
    });
  }

  Future<void> _handleSignOut() async {
    await GoogleSignInApi.logout();
    setState(() {
      _user = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Google Sign-In Example')),
        body: Center(
          child: _user == null
              ? ElevatedButton(
            onPressed: _handleSignIn,
            child: Text('Sign in with Google'),
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Signed in as: ${_user!.displayName}'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleSignOut,
                child: Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(GoogleSignInExample());
}
