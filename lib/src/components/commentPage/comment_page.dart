import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_read/src/components/auth/auth_logic.dart';
import 'package:we_read/src/components/commentPage/comment_page_logic.dart';
import 'package:we_read/src/logic/book_logic.dart';
import 'package:we_read/src/logic/comment_logic.dart';
import 'package:we_read/src/logic/main_logic.dart';
import 'package:we_read/src/logic/style_logic.dart';
import 'package:we_read/src/models/bookmark.dart';
import 'package:we_read/src/models/books/book_list.dart';
import 'package:we_read/src/models/comment.dart';
import 'package:we_read/src/ui/book.dart';
import 'package:we_read/src/ui/commentSection.dart';
import 'package:we_read/src/widgets/scaffold.dart';
import 'package:we_read/src/widgets/widget_lib.dart';

class CommentPage extends StatelessWidget {
  final StyleLogic styleLogic;
  final AuthLogic authLogic;
  final MainLogic mainLogic;
  final Future<List<Comment>> getComments;
  final String title;
  final bool popToUser;

  CommentPage(
      {this.styleLogic,
      this.authLogic,
      this.mainLogic,
      this.getComments,
      this.title = "Comments",
      this.popToUser = false}) {
    assert(styleLogic != null);
    assert(getComments != null);
    assert(authLogic != null);
    assert(mainLogic != null);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<StyleLogic>(
          create: (_) => styleLogic,
        ),
        Provider<AuthLogic>(
          create: (_) => authLogic,
        ),
        Provider<CommentLogic>(
          create: (_) => CommentLogic(authLogic: authLogic),
          dispose: (_, logic) => logic.dispose(),
        ),
        Provider<CommentPageLogic>(
          create: (_) => CommentPageLogic(getComments: getComments),
          dispose: (_, logic) => logic.dispose(),
        ),
        Provider<MainLogic>(
          create: (_) => mainLogic,
        ),
      ],
      child: Consumer<CommentPageLogic>(
        builder: (context, logic, _) {
          return WeReadScaffold(
            body: Column(
              children: <Widget>[
                Padding(
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.width * .05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(child: ChapterTitle(title)),
                      WeReadIconButton(
                        icon: 'title',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<Comment>>(
                    stream: logic.comments,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      snapshot.data.forEach((comment) {
                        print('${comment.toJSON()}');
                      });

                      return SingleChildScrollView(
                        child: Column(
                          children: snapshot.data
                              .map(
                                (comment) => InkWell(
                                    child: CommentCard(
                                      comment,
                                      popToUser: popToUser,
                                    ),
                                    onTap: () {
                                      if (!popToUser) {
                                        Navigator.pop(context, Bookmark(bookTitle: comment.book, chapter: comment.chapter, paragraph: comment.paragraph));
                                      } else {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => BookPage(
                                              book: books.singleWhere((book) =>
                                                  book.title == comment.book),
                                              bookmark: Bookmark(
                                                  bookTitle: comment.book,
                                                  chapter: comment.chapter,
                                                  paragraph: comment.paragraph),
                                              styleLogic: styleLogic,
                                              authLogic: authLogic,
                                              mainLogic: mainLogic,
                                            ),
                                          ),
                                        );
                                      }
                                    }),
                              )

                              // ListTile(
                              //       title: Paragraph(comment.text),
                              //       subtitle: Paragraph(
                              //         '${comment.createdAt}',
                              //         faded: true,
                              //       ),
                              //       trailing: authLogic.userIsArbiter
                              //           ? WeReadIconButton(
                              //               icon: 'delete',
                              //               onPressed: () =>
                              //                   logic.deleteComment(comment.id),
                              //             )
                              //           : null,
                              //     ))
                              .toList(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
