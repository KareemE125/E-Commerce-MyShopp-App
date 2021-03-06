import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth-screen';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:[ Colors.tealAccent, Colors.pinkAccent ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.1, 1],
              ),
            ),
          ),
          Container(
            height: deviceSize.height,
            width: deviceSize.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 20.0),
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                    transform: Matrix4.rotationZ(-0.14)..translate(-8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.pink.shade900,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          color: Colors.pinkAccent,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Text(
                      'MyShop',
                      style: TextStyle(
                        color: Theme.of(context).accentTextTheme.headline6.color,
                        fontSize: 50,
                        fontFamily: 'Anton',
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: deviceSize.width > 600 ? 2 : 1,
                  child: AuthCard(),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget
{
   @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
{
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {'email': '', 'password': '',};
  var _isLoading = false;
  final _passwordController = TextEditingController();

  void alert(String message)
  {
    showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          title: Text('Error Occurred'),
          content: Text(message),
          actions: [TextButton(child:Text('ok'), onPressed: (){ Navigator.of(context).pop();},),],
        );
      }
    );
  }

  void _submit() async
  {
    if ( !_formKey.currentState.validate() ){ return; }
    _formKey.currentState.save();
    setState((){ _isLoading = true; });

    if (_authMode == AuthMode.Login)
    {
      try{ await FirebaseAuth.instance.signInWithEmailAndPassword(email: _authData['email'], password: _authData['password']); }
      catch(e){ alert(e.toString()); }

    }
    else
    {
      try{ await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _authData['email'], password: _authData['password']); }
      catch(e){ alert(e.toString()); }
    }

    setState((){ _isLoading = false; });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login){  setState((){ _authMode = AuthMode.Signup; });  }
    else{  setState((){ _authMode = AuthMode.Login; });  }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        height: _authMode == AuthMode.Signup ? 320 : 260,
        constraints: BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 320 : 260),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-Mail',),
                  keyboardType: TextInputType.emailAddress,
                  validator:(value)
                  {
                    if( value.isEmpty || !value.contains('@') ){ return 'Invalid email!'; }
                    return null;
                  },
                  onSaved: (value){ _authData['email'] = value; },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator:(value)
                  {
                    if( value.isEmpty || value.length < 5 ){ return 'Password is too short!'; }
                    return null;
                  },
                  onSaved: (value){ _authData['password'] = value; },
                ),
                if (_authMode == AuthMode.Signup)
                  TextFormField(
                    enabled: _authMode == AuthMode.Signup,
                    decoration: InputDecoration(labelText: 'Confirm Password'),
                    obscureText: true,
                    validator: _authMode == AuthMode.Signup
                        ? (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match!';
                            }
                          }
                        : null,
                  ),
                SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  RaisedButton(
                    child:
                        Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                    onPressed: _submit,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button.color,
                  ),
                FlatButton(
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'}'),
                  onPressed: _switchAuthMode,
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
