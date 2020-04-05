import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_read/src/components/auth/auth_logic.dart';
import 'package:we_read/src/logic/main_logic.dart';
import 'package:we_read/src/logic/style_logic.dart';
import 'package:we_read/src/models/books/book_list.dart';
import 'package:we_read/src/ui/book.dart';
import 'package:we_read/src/widgets/scaffold.dart';
import 'package:we_read/src/widgets/text_widgets.dart';

class FavoritesPage extends StatelessWidget {
  final StyleLogic styleLogic;
  final MainLogic mainLogic;
  final AuthLogic authLogic;

  FavoritesPage({this.styleLogic, this.mainLogic, this.authLogic})
      : assert(styleLogic != null, mainLogic != null);

  @override
  Widget build(BuildContext context) {
    return Provider<StyleLogic>(
      create: (_) => styleLogic,
      child: WeReadScaffold(
        body: Center(
          child: Column(
            children: <Widget>[
              BookTitle('Favorites'),
              Expanded(
                child: ListView(
                  children: mainLogic.favorites
                      .map((favorite) => ListTile(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => BookPage(
                                  book: books.singleWhere((book) => book.title == favorite.bookTitle),
                                  bookmark: favorite,
                                  styleLogic: styleLogic,
                                  authLogic: authLogic,
                                  mainLogic: mainLogic,
                                ),
                              ),
                            ),
                            title: Paragraph(
                                '${favorite.bookTitle}, ${favorite.chapter}-${favorite.paragraph}'),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
