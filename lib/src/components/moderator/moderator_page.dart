import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_read/src/components/auth/auth_logic.dart';
import 'package:we_read/src/components/moderator/moderator_page_logic.dart';
import 'package:we_read/src/logic/style_logic.dart';
import 'package:we_read/src/widgets/scaffold.dart';
import 'package:we_read/src/widgets/widget_lib.dart';

class ModeratorPage extends StatelessWidget {
  final AuthLogic authLogic;
  final StyleLogic styleLogic;
  ModeratorPage({this.authLogic, this.styleLogic})
      : assert(authLogic != null, styleLogic != null);

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => styleLogic,
      child: Provider(
        create: (_) => ModeratorPageLogic(authLogic: authLogic),
        dispose: (_, logic) => logic.dispose(),
        child: ProvidedModeratorPage(),
      ),
    );
  }
}

class ProvidedModeratorPage extends StatefulWidget {
  @override
  _ProvidedModeratorPageState createState() => _ProvidedModeratorPageState();
}

class _ProvidedModeratorPageState extends State<ProvidedModeratorPage> {
  ModeratorPageLogic logic;
  @override
  Widget build(BuildContext context) {
    logic = Provider.of<ModeratorPageLogic>(context, listen: false);
    return WeReadScaffold(
        body: StreamBuilder<ModeratorPageState>(
      stream: logic.pageStateStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        if (snapshot.data is NoPostsToModerate) {
          return Center(
            child: Paragraph('No Posts to Moderate'),
          );
        }
        if (snapshot.data is PostRetrieved) {
          PostRetrieved data = snapshot.data;
          return Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Paragraph(
                        'Accept the comment if it does not violate any rules:\n1. No profanity, insults, or slurs\n2. The comment should be relavent to the book and not completely off-topic\n3. No low-effort, offensive, grossly formated, or otherwise low-value comments\n\nTry to be as objective as possible and not base your decision on whether you agree with the post, or whether it has a typo. Be welcoming to new members!'),
                  ),
                  ChapterTitle('Comment to Moderate:'),
                  MediumText('Book:'),
                  MediumText(data.comment.book),
                  VerticalSpace(20.0),
                  MediumText('Username:'),
                  MediumText(logic.commenterUsername),
                  VerticalSpace(20.0),
                  MediumText('Comment:'),
                  ContainerProportionalWidth(
                    proportion: .8,
                    child: MediumText(data.comment.text),
                  ),
                  VerticalSpace(20.0),
                  WeReadButton(
                    text: 'Accept Comment',
                    onPressed: logic.approvePost,
                  ),
                  WeReadButton(
                    text: 'Reject Comment',
                    onPressed: logic.disapprovePost,
                  ),
                  WeReadButton(
                    text:
                        'Disapprove and Report (Inapropriate Post or Username)',
                    onPressed: () => showDialog(
                        context: context,
                        builder: (_) => Provider(
                              create: (_) => Provider.of<StyleLogic>(context),
                              child: WeReadDialog(
                                child: Column(
                                  children: <Widget>[
                                    ChapterTitle(
                                        'What would you like to report?'),
                                    WeReadButton(
                                      text: 'Report post: ${data.comment.text}',
                                      onPressed: () =>
                                          Navigator.pop(context, 'Post'),
                                    ),
                                    WeReadButton(
                                      text:
                                          'Report username: ${logic.commenterUsername}',
                                      onPressed: () =>
                                          Navigator.pop(context, 'Username'),
                                    ),
                                    WeReadButton(
                                      text: 'Cancel',
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                    ),
                                  ],
                                ),
                              ),
                            )).then(
                      (val) {
                        if (val != null && val is! bool) {
                          if (val == 'Post') {
                            // report post
                            logic.disapproveAndReportComment();
                          }
                          if (val == 'Username') {
                            // report username
                            logic.disapproveAndReportUsername();
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        if (snapshot.data is LoadingPost) {
          return Center(
            child: Paragraph('Loading'),
          );
        }
      },
    ));
  }

  @override
  void dispose() {
    logic.pageClosed();
    super.dispose();
  }
}
