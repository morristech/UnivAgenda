import 'package:flutter/material.dart';
import 'package:myagenda/keys/assets.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/utils/login/login_base.dart';
import 'package:myagenda/utils/login/login_cas.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/ui/list_divider.dart';
import 'package:myagenda/widgets/ui/dropdown.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  void _onSubmit() async {
    final translations = Translations.of(context);

    // Get username and password from inputs
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // Check fields values
    if (username.isEmpty || password.isEmpty) {
      _showMessage(translations.get(StringKey.REQUIRE_FIELD));
      return;
    }

    _setLoading(true);

    final prefs = PreferencesProvider.of(context);
    prefs.setUserLogged(false, false);

    // Login process
    final loginResult =
        await LoginCAS(prefs.loginUrl, username, password).login();

    _setLoading(false);

    if (loginResult.result == LoginResultType.LOGIN_FAIL) {
      _showMessage(loginResult.message);
    } else if (loginResult.result == LoginResultType.NETWORK_ERROR) {
      _showMessage(
        translations.get(StringKey.LOGIN_SERVER_ERROR, [prefs.university]),
      );
    } else if (loginResult.result == LoginResultType.LOGIN_SUCCESS) {
      _scaffoldKey.currentState.removeCurrentSnackBar();
      // Redirect user if no error
      prefs.setUserLogged(true, false);
      Navigator.of(context).pushReplacementNamed(RouteKey.HOME);
    } else {
      _showMessage("Unknown error :/");
    }
  }

  void _showMessage(String msg) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context);
    final theme = Theme.of(context);
    final prefs = PreferencesProvider.of(context);
    final orientation = MediaQuery.of(context).orientation;

    final logo = Hero(
      tag: Asset.LOGO,
      child: Image.asset(Asset.LOGO, width: 100.0),
    );

    final titleApp = Text(
      translations.get(StringKey.APP_NAME),
      style: theme.textTheme.title.copyWith(fontSize: 28.0),
    );

    final username = TextField(
      controller: _usernameController,
      autofocus: false,
      decoration: InputDecoration(
        hintText: translations.get(StringKey.LOGIN_USERNAME),
        prefixIcon: Icon(Icons.person_outline, color: theme.accentColor),
        contentPadding: const EdgeInsets.symmetric(vertical: 18.0),
        border: InputBorder.none,
      ),
    );

    final password = TextField(
      controller: _passwordController,
      autofocus: false,
      obscureText: true,
      decoration: InputDecoration(
        hintText: translations.get(StringKey.LOGIN_PASSWORD),
        prefixIcon: Icon(Icons.lock_outline, color: theme.accentColor),
        contentPadding: const EdgeInsets.symmetric(vertical: 18.0),
        border: InputBorder.none,
      ),
    );

    final loginButton = FloatingActionButton(
      onPressed: _onSubmit,
      child: const Icon(Icons.send),
      backgroundColor: theme.accentColor,
    );

    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(32.0),
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              Expanded(
                child: (orientation == Orientation.portrait)
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [logo, titleApp],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [logo, 
                        const SizedBox(width: 16.0,),
                        titleApp],
                      ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Dropdown(
                      items: prefs.getAllUniversity(),
                      value: prefs.university,
                      onChanged: (university) {
                        prefs.setUniversity(university);
                      },
                    ),
                    Card(
                      shape: OutlineInputBorder(),
                      elevation: 4.0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: (orientation == Orientation.portrait)
                            ? Column(
                                children: [
                                  username,
                                  const ListDivider(),
                                  password
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(child: username),
                                  Container(
                                    height: 32.0,
                                    width: 1.0,
                                    color: Colors.black54,
                                  ),
                                  Expanded(child: password)
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    _isLoading ? CircularProgressIndicator() : loginButton,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
