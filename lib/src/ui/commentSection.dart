import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_read/src/components/auth/auth_home.dart';
import 'package:we_read/src/components/auth/auth_logic.dart';
import 'package:we_read/src/components/currencyIndicator/currency_indicator.dart';
import 'package:we_read/src/components/profile/other_user_profile.dart';
import 'package:we_read/src/logic/book_logic.dart';
import 'package:we_read/src/logic/comment_logic.dart';
import 'package:we_read/src/logic/main_logic.dart';
import 'package:we_read/src/logic/style_logic.dart';
import 'package:we_read/src/models/bookmark.dart';
import 'package:we_read/src/models/comment.dart';
import 'package:we_read/src/ui/commentDialog.dart';
import 'package:we_read/src/widgets/widget_lib.dart';

class CommentSection extends StatefulWidget {
  @override
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => CommentLogic(
        bookLogic: Provider.of<BookLogic>(context, listen: false),
        authLogic: Provider.of<AuthLogic>(context, listen: false),
      ),
      dispose: (_, logic) => logic.dispose(),
      child: StreamBuilder<List<Comment>>(
        stream: Provider.of<BookLogic>(context).currentParagraphComments,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Paragraph('loading comments');
          }
          if (snapshot.data.length == 0 && expanded) {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => setState(() => expanded = false));
          }
          return InkWell(
            onTap: () => setState(() => expanded = !expanded),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                !expanded && snapshot.hasData && snapshot.data.length > 0
                    ? Paragraph('Comments')
                    : Container(),
                Divider(
                  height: 3.0,
                  color: Colors.blueGrey,
                ),
                Container(
                  height:
                      expanded ? MediaQuery.of(context).size.height * .3 : null,
                  child: expanded
                      ? Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: snapshot.data.map((comment) {
                                return CommentCard(comment);
                              }).toList(),
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ChapterCommentSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => CommentLogic(
        bookLogic: Provider.of<BookLogic>(context, listen: false),
        authLogic: Provider.of<AuthLogic>(context, listen: false),
      ),
      dispose: (_, logic) => logic.dispose(),
      child: StreamBuilder<List<Comment>>(
        stream: Provider.of<BookLogic>(context).currentParagraphComments,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return WeReadCard(
              child: Paragraph('loading comments ...'),
            );
          }
          if (snapshot.data.length == 0) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                WeReadCard(
                  child: Paragraph('no comments here, add the first?'),
                ),
                ChapterCommentOptionsRow(),
              ],
            );
          }
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: snapshot.data.map((comment) {
                    return CommentCard(comment);
                  }).toList(),
                ),
                ChapterCommentOptionsRow()
              ],
            ),
          );
        },
      ),
    );
  }
}

class ChapterCommentOptionsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    BookLogic bookLogic = Provider.of<BookLogic>(context);
    MainLogic mainLogic = Provider.of<MainLogic>(context);
    AuthLogic authLogic = Provider.of<AuthLogic>(context);
    StyleLogic styleLogic = Provider.of<StyleLogic>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        WeReadIconButton(
          icon: 'comment',
          onPressed: () => authLogic.token != null
              ? authLogic.userHasAmpersands
                  ? showDialog(
                      context: context,
                      builder: (_) {
                        return CommentDialog(
                          styleLogic:
                              Provider.of<StyleLogic>(context, listen: false),
                          authLogic:
                              Provider.of<AuthLogic>(context, listen: false),
                          bookLogic: bookLogic,
                        );
                      },
                    ).whenComplete(Provider.of<Executor>(context, listen: false)
                      .runFunctions)
                  : null
              : Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AuthHome(
                      authLogic: authLogic,
                      styleLogic: styleLogic,
                      mainLogic: mainLogic,
                    ),
                  ),
                ),
        ),
        StreamBuilder<Bookmark>(
          stream: bookLogic.bookmarkStream,
          builder: (context, snapshot) {
            return WeReadIconButton(
              icon: bookLogic.currentParagraphIsBookmark
                  ? 'bookmark'
                  : 'bookmarkOutline',
              onPressed: bookLogic.setBookmarkCurrentParagraph,
            );
          },
        ),
        StreamBuilder<List<Bookmark>>(
          stream: mainLogic.favoritesStream,
          builder: (context, snapshot) {
            return WeReadIconButton(
              icon:
                  mainLogic.favorites.contains(bookLogic.currentSpotAsBookmark)
                      ? 'currentFavorite'
                      : 'favorite',
              onPressed: () =>
                  mainLogic.setFavorite(bookLogic.currentSpotAsBookmark),
            );
          },
        ),
      ],
    );
  }
}

class CommentCard extends StatelessWidget {
  final Comment comment;
  final bool popToUser;

  CommentCard(this.comment, {this.popToUser = false}) : assert(comment != null);

  @override
  Widget build(BuildContext context) {
    AuthLogic authLogic = Provider.of<AuthLogic>(context, listen: false);
    StyleLogic styleLogic = Provider.of<StyleLogic>(context, listen: false);
    return WeReadCard(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              WeReadIconButton(
                icon: 'up',
                onPressed: () => authLogic.token != null
                    ? Provider.of<CommentLogic>(context, listen: false)
                        .upvoteComment(comment)
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (newContext) => AuthHome(
                                  authLogic: authLogic,
                                  styleLogic: styleLogic,
                                  mainLogic: Provider.of<MainLogic>(context),
                                ))),
              ),
              Paragraph('${comment.votes}'),
            ],
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    if (popToUser) {
                      Navigator.pop(context);
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => OtherUserProfile(
                                    comment.userId,
                                    styleLogic: styleLogic,
                                    authLogic: authLogic,
                                    mainLogic: Provider.of<MainLogic>(context),
                                  )));
                    }
                  },
                  child: Paragraph(
                    comment.username ?? 'no-user',
                    faded: true,
                  ),
                ),
                Paragraph(
                  comment.text,
                ),
              ],
            ),
          ),
          Provider.of<AuthLogic>(context, listen: false).userIsArbiter
              ? WeReadIconButton(
                  icon: 'delete',
                  onPressed: () => showDialog(
                      context: context,
                      builder: (_) => SimpleDialog(
                            title: Text('Delete Comment?'),
                            children: <Widget>[
                              FlatButton(
                                child: Text('Yes'),
                                onPressed: () => Navigator.pop(context, true),
                              ),
                              FlatButton(
                                child: Text('No'),
                                onPressed: () => Navigator.pop(context, false),
                              )
                            ],
                          )).then((val) {
                    if (val) {
                      Provider.of<MainLogic>(context, listen: false)
                          .deleteComment(comment.id);
                    }
                  }),
                )
              : Container()
        ],
      ),
    );
  }
}
