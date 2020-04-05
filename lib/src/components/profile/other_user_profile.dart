import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_read/src/components/auth/auth_logic.dart';
import 'package:we_read/src/components/profile/profile_page.dart';
import 'package:we_read/src/logic/main_logic.dart';
import 'package:we_read/src/logic/style_logic.dart';
import 'package:we_read/src/widgets/scaffold.dart';

class OtherUserProfile extends StatelessWidget {
  final String token;
  final StyleLogic styleLogic;
  final AuthLogic authLogic;
  final MainLogic mainLogic;

  OtherUserProfile(this.token, {this.styleLogic, this.authLogic, this.mainLogic}) {
    assert(token != null);
    assert(styleLogic != null);
    assert(authLogic != null);
    assert(mainLogic != null);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (_) => styleLogic,
        ),
        Provider(
          create: (_) => authLogic,
        ),
        Provider(
          create: (_) => mainLogic,
        )
      ],
      child: WeReadScaffold(
        body: UserProfilePage(
          token: token,
          ownProfile: false,
        ),
      ),
    );
  }
}
