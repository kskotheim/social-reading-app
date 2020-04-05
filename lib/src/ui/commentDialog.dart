import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_read/src/components/auth/auth_logic.dart';
import 'package:we_read/src/logic/book_logic.dart';
import 'package:we_read/src/logic/new_comment_logic.dart';
import 'package:we_read/src/logic/style_logic.dart';
import 'package:we_read/src/widgets/form_widgets.dart';
import 'package:we_read/src/widgets/widget_lib.dart';

class CommentDialog extends StatelessWidget {
  final StyleLogic styleLogic;
  final AuthLogic authLogic;
  final BookLogic bookLogic;
  NewCommentLogic commentLogic;

  CommentDialog({this.styleLogic, this.authLogic, this.bookLogic}) {
    assert(styleLogic != null);
    assert(authLogic != null);
    assert(bookLogic != null);
    commentLogic = NewCommentLogic(authLogic: authLogic, bookLogic: bookLogic);
  }
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => styleLogic,
      child: StreamBuilder<CommentState>(
          stream: commentLogic.commentState,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data is CommentStateInitial) {
              return SimpleDialog(
                  contentPadding: const EdgeInsets.all(12.0),
                  backgroundColor:
                      styleLogic.darkModeEnabled ? Colors.black : Colors.white,
                  title: ChapterTitle('New Comment'),
                  children: [
                    CommentField(
                      stream: commentLogic.commentText,
                      onChanged: commentLogic.onChanged,
                    ),
                    WeReadButton(
                      text: 'Submit',
                      onPressed: commentLogic.submitComment,
                    ),
                  ]);
            }
            if (snapshot.data is CommentStateLoading) {
              return SimpleDialog(
                contentPadding: const EdgeInsets.all(12.0),
                backgroundColor:
                    styleLogic.darkModeEnabled ? Colors.black : Colors.white,
                title: ChapterTitle('Submitting Comment'),
                children: <Widget>[
                  ChapterTitle(commentLogic.comment),
                  Center(child: CircularProgressIndicator())
                ],
              );
            }
            if (snapshot.data is CommentStateSubmitted) {
              return SimpleDialog(
                contentPadding: const EdgeInsets.all(12.0),
                backgroundColor:
                    styleLogic.darkModeEnabled ? Colors.black : Colors.white,
                title: ChapterTitle('Submitted!'),
                children: <Widget>[
                  WeReadButton(
                    onPressed: () => Navigator.pop(context),
                    text: 'Back',
                  )
                ],
              );
            }
          }),
    );
  }
}
