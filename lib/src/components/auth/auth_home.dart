import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_read/src/components/auth/auth_logic.dart';
import 'package:we_read/src/components/login/login_page.dart';
import 'package:we_read/src/components/profile/profile_page.dart';
import 'package:we_read/src/logic/main_logic.dart';
import 'package:we_read/src/logic/style_logic.dart';
import 'package:we_read/src/widgets/widget_lib.dart';

class AuthHome extends StatelessWidget {
  final AuthLogic authLogic;
  final StyleLogic styleLogic;
  final MainLogic mainLogic;

  AuthHome({this.authLogic, this.styleLogic, this.mainLogic})
      : assert(authLogic != null, styleLogic != null), assert(mainLogic != null);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => authLogic),
        Provider(create: (_) => styleLogic),
        Provider(create: (_) => mainLogic),
      ],
      child: _ProvidedAuthorizationHome(),
    );
  }
}

class _ProvidedAuthorizationHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AuthLogic authLogic = Provider.of<AuthLogic>(context);
    return WeReadScaffold(
      body: StreamBuilder<AuthState>(
        stream: authLogic.authenticationStateStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data is AuthStateLoading)
            return Center(
              child: CircularProgressIndicator(),
            );
          if (snapshot.data is AuthStateNotAuthenticated) {
            return LoginPage();
          }
          if (snapshot.data is AuthStateAuthenticated) {
            return UserProfilePage(
              token: authLogic.token,
              ownProfile: true,
            );
          }
        },
      ),
    );
  }
}
