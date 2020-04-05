import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_read/src/components/auth/auth_logic.dart';
import 'package:we_read/src/components/auth/auth_home.dart';
import 'package:we_read/src/components/currencyIndicator/currency_indicator.dart';
import 'package:we_read/src/logic/book_logic.dart';
import 'package:we_read/src/logic/main_logic.dart';
import 'package:we_read/src/logic/style_logic.dart';
import 'package:we_read/src/models/bookmark.dart';
import 'package:we_read/src/ui/commentDialog.dart';
import 'package:we_read/src/ui/commentSection.dart';
import 'package:we_read/src/widgets/widget_lib.dart';

class ParagraphPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    BookLogic bookLogic = Provider.of<BookLogic>(context);
    MainLogic mainLogic = Provider.of<MainLogic>(context);
    AuthLogic authLogic = Provider.of<AuthLogic>(context);
    StyleLogic styleLogic = Provider.of<StyleLogic>(context);

    Executor fxRepo = Executor();

    return WeReadScaffold(
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: BorderContainer(
                  child: InfoText(
                      'ch. ${bookLogic.currentChapter + 1}/${bookLogic.book.chapters.length}, p. ${bookLogic.currentParagraph + 1}/${bookLogic.book.chapters[bookLogic.currentChapter].paragraphs.length}'),
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    controller: bookLogic.scrollController,
                    scrollDirection: Axis.vertical,
                    child: Paragraph(bookLogic.currentParagraphText),
                  ),
                ),
              ),
              CommentSection(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  WeReadIconButton(
                    icon: 'back',
                    onPressed: bookLogic.previousParagraph,
                  ),
                  WeReadIconButton(
                    icon: 'title',
                    onPressed: bookLogic.goToTitle,
                  ),
                  StreamBuilder<Bookmark>(
                    stream: bookLogic.bookmarkStream,
                    builder: (context, snapshot) {
                      return WeReadIconButton(
                        icon: bookLogic.currentPageIsBookmark
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
                        icon: mainLogic.favorites
                                .contains(bookLogic.currentSpotAsBookmark)
                            ? 'currentFavorite'
                            : 'favorite',
                        onPressed: () => mainLogic
                            .setFavorite(bookLogic.currentSpotAsBookmark),
                      );
                    },
                  ),
                  WeReadIconButton(
                    icon: 'comment',
                    onPressed:
                        (authLogic.token == null || authLogic.userHasAmpersands)
                            ? () => authLogic.token != null
                                ? showDialog(
                                    context: context,
                                    child: CommentDialog(
                                      authLogic: authLogic,
                                      styleLogic: styleLogic,
                                      bookLogic: bookLogic,
                                    ),
                                  ).whenComplete(fxRepo.runFunctions)
                                : Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AuthHome(
                                        authLogic: authLogic,
                                        styleLogic: styleLogic,
                                        mainLogic: mainLogic,
                                      ),
                                    ),
                                  )
                            : null,
                  ),
                  WeReadIconButton(
                    icon: 'next',
                    onPressed: bookLogic.nextParagraph,
                  ),
                ],
              )
            ],
          ),
          authLogic.token != null ? CurrencyIndicator(executor: fxRepo,) : Container(),
          GestureDetector(
            onDoubleTap: () {
              bookLogic.nextParagraph();
            },
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity > 0) {
                // navigate back a paragraph
                bookLogic.previousParagraph();
              }
              if (details.primaryVelocity < 0) {
                //navigate forward a paragraph
                bookLogic.nextParagraph();
              }
            },
          )
        ],
      ),
    );
  }
}
