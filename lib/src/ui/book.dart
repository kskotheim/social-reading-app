import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:we_read/src/components/auth/auth_logic.dart';
import 'package:we_read/src/logic/main_logic.dart';
import 'package:we_read/src/models/book.dart';
import 'package:we_read/src/logic/book_logic.dart';
import 'package:we_read/src/logic/style_logic.dart';
import 'package:we_read/src/models/bookmark.dart';
import 'package:we_read/src/ui/chapter.dart';
import 'package:we_read/src/ui/paragraph.dart';
import 'package:we_read/src/ui/title.dart';
import 'package:we_read/src/widgets/widget_lib.dart';

class BookPage extends StatelessWidget {
  final Book book;
  final Bookmark bookmark;
  final StyleLogic styleLogic;
  final AuthLogic authLogic;
  final MainLogic mainLogic;

  BookPage(
      {this.book,
      this.styleLogic,
      this.authLogic,
      this.mainLogic,
      this.bookmark})
      : assert(book != null, styleLogic != null),
        assert(authLogic != null, mainLogic != null);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthLogic>(
          create: (_) => authLogic,
        ),
        Provider<MainLogic>(
          create: (_) => mainLogic,
        ),
        Provider<StyleLogic>(
          create: (_) => styleLogic,
        ),
        Provider<BookLogic>(
          create: (_) => BookLogic(
              book: book, style: styleLogic, initiateAtBookmark: bookmark),
          dispose: (context, logic) => logic.dispose(),
        ),
      ],
      child: _ProvidedBook(),
    );
  }
}

class _ProvidedBook extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    BookLogic bookLogic = Provider.of<BookLogic>(context);

    return WillPopScope(
      onWillPop: () async {
        if (bookLogic.currentChapter != -1) {
          bookLogic.goToTitle();
          await Future.delayed(Duration(seconds: 0));
          return false;
        }
        await Future.delayed(Duration(seconds: 0));
        return true;
      },
      child: StreamBuilder<TextStyle>(
        stream: Provider.of<StyleLogic>(context).testStyle,
        builder: (context, snapshot) {
          return StreamBuilder<BookState>(
            stream: bookLogic.bookState,
            builder: (context, snapshot) {
              SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);

              if (!snapshot.hasData) return LoadingPage();
              if (snapshot.data is BookStateTitle) {
                return TitlePage();
              }
              if (snapshot.data is BookStateChapter) {
                BookStateChapter state = snapshot.data;
                return ChapterPage(bookLogic.book.chapters[state.chapter]);
              }
              if (snapshot.data is BookStateParagraph) {
                return ParagraphPage();
              }
            },
          );
        },
      ),
    );
  }
}
