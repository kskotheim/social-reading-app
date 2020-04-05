import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_read/src/components/auth/auth_logic.dart';
import 'package:we_read/src/components/currencyIndicator/currency_indicator.dart';

import 'package:we_read/src/logic/book_logic.dart';
import 'package:we_read/src/logic/style_logic.dart';
import 'package:we_read/src/models/book.dart';
import 'package:we_read/src/models/bookmark.dart';
import 'package:we_read/src/ui/commentSection.dart';
import 'package:we_read/src/widgets/widget_lib.dart';

class ChapterPage extends StatelessWidget {
  final Chapter chapter;

  ChapterPage(this.chapter) : assert(chapter != null);

  @override
  Widget build(BuildContext context) {
    BookLogic bookLogic = Provider.of<BookLogic>(context, listen: false);
    StyleLogic styleLogic = Provider.of<StyleLogic>(context, listen: false);

    List<Widget> paragraphWidgets = [];
    int i = 0;
    chapter.paragraphs.forEach((paragraph) {
      paragraphWidgets.add(ChapterParagraph(
        text: paragraph,
        index: i,
      ));
      i++;
    });

    Executor executor = Executor();

    return Provider<Executor>(
      create: (context) => executor,
      child: WeReadScaffold(
        body: SingleChildScrollView(
          controller: bookLogic.scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                  Provider.of<AuthLogic>(context).token != null
                      ? CurrencyIndicator(
                          executor: executor,
                        )
                      : Container(),
                  Row(
                    children: <Widget>[
                      bookLogic.currentChapter != 0
                          ? WeReadIconButton(
                              icon: 'back',
                              onPressed: bookLogic.previousChapter)
                          : Container(),
                      Expanded(
                        child: ChapterTitle(chapter.title),
                      ),
                      StreamBuilder<Bookmark>(
                          stream: bookLogic.bookmarkStream,
                          builder: (context, snapshot) {
                            return WeReadIconButton(
                              icon: snapshot.hasData &&
                                      snapshot.data.chapter == chapter.index
                                  ? 'bookmark'
                                  : 'bookmarkOutline',
                              onPressed: () => bookLogic.setBookmark(
                                  bookLogic.currentChapter, 0),
                            );
                          }),
                      WeReadIconButton(
                        icon: 'title',
                        onPressed: bookLogic.goToTitle,
                      ),
                      bookLogic.currentChapter <
                              bookLogic.book.chapters.length - 1
                          ? WeReadIconButton(
                              icon: 'next', onPressed: bookLogic.nextChapter)
                          : Container(),
                    ],
                  ),
                ] +
                paragraphWidgets +
                <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      WeReadButton(
                        text: 'Title',
                        onPressed: bookLogic.goToTitle,
                      ),
                      bookLogic.book.chapters.length - 1 > chapter.index
                          ? WeReadButton(
                              text: 'Next Chapter',
                              onPressed: bookLogic.nextChapter,
                            )
                          : Container()
                    ],
                  )
                ],
          ),
        ),
      ),
    );
  }
}

class ChapterParagraph extends StatefulWidget {
  final String text;
  final int index;

  ChapterParagraph({this.text, this.index});

  @override
  _ChapterParagraphState createState() => _ChapterParagraphState();
}

class _ChapterParagraphState extends State<ChapterParagraph> {
  @override
  Widget build(BuildContext context) {
    BookLogic logic = Provider.of<BookLogic>(context, listen: false);
    return InkWell(
      onTap: () => setState(() {
        if (logic.currentParagraph == widget.index) {
          logic.showParagraphDetails(-1);
        } else {
          logic.showParagraphDetails(widget.index);
        }
      }),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Paragraph('\t\t' + widget.text),
          logic.currentParagraph == widget.index
              ? ChapterCommentSection()
              : Container()
        ],
      ),
    );
  }
}
