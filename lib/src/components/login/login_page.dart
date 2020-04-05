import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_read/src/components/auth/auth_logic.dart';
import 'package:we_read/src/components/login/login_logic.dart';
import 'package:we_read/src/logic/style_logic.dart';
import 'package:we_read/src/widgets/widget_lib.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<LoginLogic>(
        create: (_) => LoginLogic(
              authLogic: Provider.of<AuthLogic>(context),
            ),
        dispose: (context, logic) => logic.dispose(),
        child: _ProvidedLoginPage());
  }
}

class _ProvidedLoginPage extends StatefulWidget {
  @override
  _ProvidedLoginPageState createState() => _ProvidedLoginPageState();
}

class _ProvidedLoginPageState extends State<_ProvidedLoginPage> {
  LoginLogic loginBloc;

  @override
  Widget build(BuildContext context) {
    loginBloc = Provider.of<LoginLogic>(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: StreamBuilder<LoginState>(
          stream: Provider.of<LoginLogic>(context).loginState,
          builder: (context, snapshot) {
            if (snapshot.data is LoginFailure) {
              LoginFailure failure = snapshot.data;
              WidgetsBinding.instance.addPostFrameCallback((duration) =>
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text(failure.error))));
            }

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  VerticalSpace(20.0),
                  snapshot.data is! LoginLoading
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            MediumText('Email'),
                            StreamTextField<String>(
                              stream: loginBloc.email,
                              onChanged: loginBloc.updateEmailField,
                            ),
                            MediumText('Password'),
                            StreamTextField<String>(
                              stream: loginBloc.password,
                              onChanged: loginBloc.updatePasswordField,
                              obscureText: true,
                            ),
                            WeReadButton(
                              text: 'Login',
                              onPressed: loginBloc.loginPressed,
                            ),
                            WeReadButton(
                              text: 'CreateAccount',
                              onPressed: loginBloc.createUserPressed,
                            ),
                            WeReadButton(
                              text: 'Reset Password',
                              onPressed: loginBloc.resetPasswordPressed,
                            ),
                            WeReadButton(
                              text: 'Back',
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        )
                      : Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(),
                        ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
