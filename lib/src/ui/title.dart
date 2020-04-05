import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_read/src/components/auth/auth_logic.dart';
import 'package:we_read/src/components/commentPage/comment_page.dart';
import 'package:we_read/src/data/repo.dart';
import 'package:we_read/src/logic/book_logic.dart';
import 'package:we_read/src/logic/main_logic.dart';
import 'package:we_read/src/logic/style_logic.dart';
import 'package:we_read/src/models/bookmark.dart';
import 'package:we_read/src/widgets/widget_lib.dart';

class TitlePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    BookLogic bookLogic = Provider.of<BookLogic>(context, listen: false);
    StyleLogic styleLogic = Provider.of<StyleLogic>(context, listen: false);

    return WeReadScaffold(
      body: Stack(
        children: <Widget>[
          StreamBuilder<double>(
              stream: bookLogic.fadeStream,
              builder: (context, snapshot) {
                double opacity = 1.0;
                if (snapshot.hasData) {
                  opacity = snapshot.data;
                  if (opacity > 1.0) opacity = 1.0;
                  if (opacity < 0) opacity = 0;
                }
                return Opacity(
                  opacity: opacity,
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        BookTitle(
                          bookLogic.book.title,
                        ),
                        Image.asset(bookLogic.book.image, width: 220.0, height: 300.0),
                        Subtitle(bookLogic.book.author, bookLogic.book.year)
                      ],
                    ),
                  ),
                );
              }),
          Center(
            child: SingleChildScrollView(
              controller: bookLogic.titleScrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                      VerticalSpace(MediaQuery.of(context).size.height * .9),
                    ] +
                    List<Widget>.from(
                      bookLogic.book.chapters.map(
                        (chapter) => WeReadButton(
                          text: chapter.title,
                          onPressed: () {
                            if (styleLogic.paragraphModeEnabled) {
                              bookLogic.goToParagraph(chapter.index, 0);
                            } else {
                              bookLogic.goToChapter(chapter.index);
                            }
                          },
                        ),
                      ),
                    ) +
                    <Widget>[
                      WeReadButton(
                        text: 'Comments',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CommentPage(
                              styleLogic: styleLogic,
                              authLogic: Provider.of<AuthLogic>(context),
                              mainLogic: Provider.of<MainLogic>(context),
                              getComments: Repo.instance.getComments(bookLogic.book.title, -1, -1, styleLogic.showRecentComments, 10),
                              title: '${bookLogic.book.title} Comments',
                            ),
                          ),
                        ).then((value) {
                          if(value is Bookmark){
                            bookLogic.goToParagraph(value.chapter, value.paragraph);
                          }
                        }),
                      ),
                      WeReadButton(
                        text: 'Home',
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * .05),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  StreamBuilder<Bookmark>(
                    stream: bookLogic.bookmarkStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return WeReadIconButton(
                          icon: 'bookmark',
                          onPressed: bookLogic.goToBookmark,
                        );
                      }
                      return Container(
                        height: 0.0,
                      );
                    },
                  ),
                  SettingsWidget(),
                  WeReadIconButton(
                    icon: 'home',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
