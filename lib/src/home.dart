import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_read/src/components/arbiter/arbiter_page.dart';
import 'package:we_read/src/components/auth/auth_logic.dart';
import 'package:we_read/src/components/auth/auth_home.dart';
import 'package:we_read/src/components/favorites/favorites_page.dart';
import 'package:we_read/src/components/moderator/moderator_page.dart';
import 'package:we_read/src/components/store/store_page.dart';
import 'package:we_read/src/logic/main_logic.dart';
import 'package:we_read/src/logic/reward_tracker.dart';
import 'package:we_read/src/logic/style_logic.dart';
import 'package:we_read/src/models/books/book_list.dart';
import 'package:we_read/src/ui/book.dart';
import 'package:we_read/src/widgets/widget_lib.dart';

import 'models/book.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<StyleLogic>(
          create: (context) => StyleLogic(),
          dispose: (context, logic) => logic.dispose(),
        ),
        Provider<MainLogic>(
          create: (context) => MainLogic(),
          dispose: (context, logic) => logic.dispose(),
        ),
        Provider<AuthLogic>(
          create: (context) => AuthLogic(
              tracker: Provider.of<RewardTracker>(context, listen: false)),
          dispose: (context, logic) => logic.dispose(),
        ),
      ],
      child: _ProvidedHomePage(),
    );
  }
}

class _ProvidedHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    StyleLogic styleLogic = Provider.of<StyleLogic>(context);
    AuthLogic authLogic = Provider.of<AuthLogic>(context);
    MainLogic mainLogic = Provider.of<MainLogic>(context);

    return StreamBuilder<TextStyle>(
      stream: styleLogic.testStyle,
      builder: (context, snapshot) {
        return StreamBuilder<AuthState>(
          stream: authLogic.authenticationStateStream,
          builder: (context, snapshot) {
            return WeReadScaffold(
              body: Column(
                children: <Widget>[
                  // top-right icons
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        0,
                        MediaQuery.of(context).size.width * .05,
                        MediaQuery.of(context).size.width * .05,
                        0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        // favorites button
                        WeReadIconButton(
                          icon: 'favorite',
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => FavoritesPage(
                                styleLogic: styleLogic,
                                authLogic: authLogic,
                                mainLogic: mainLogic,
                              ),
                            ),
                          ),
                        ),

                        // store button
                        WeReadIconButton(
                          icon: 'store',
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => authLogic.token != null
                                  ? StorePage(
                                      authLogic: authLogic,
                                      styleLogic: styleLogic,
                                    )
                                  : AuthHome(
                                      authLogic: authLogic,
                                      styleLogic: styleLogic,
                                      mainLogic: mainLogic,
                                    ),
                            ),
                          ),
                        ),

                        // settings button
                        SettingsWidget(),

                        // Profile / authentication
                        WeReadIconButton(
                          icon: 'user',
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (newContext) => AuthHome(
                                authLogic: authLogic,
                                styleLogic: styleLogic,
                                mainLogic: mainLogic,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          BookTitle('We Read'),
                          authLogic.userIsModerator
                              ? WeReadButton(
                                  text: 'Posts To Moderate',
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ModeratorPage(
                                        authLogic: authLogic,
                                        styleLogic: styleLogic,
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                          authLogic.userIsArbiter
                              ? WeReadButton(
                                  text: 'Reports',
                                  onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => ArbiterPage(
                                                authLogic: authLogic,
                                                styleLogic: styleLogic,
                                                mainLogic: mainLogic,
                                              ))),
                                )
                              : Container(),
                          StreamBuilder<List<String>>(
                            stream: mainLogic.shelfStream,
                            builder: (context, snapshot) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  (snapshot.hasData && snapshot.data.length > 0)
                                      ? Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Divider(),
                                            Row(
                                              children: <Widget>[
                                                Paragraph('Your Bookshelf')
                                              ],
                                            ),
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                children: snapshot.data.map(
                                                  (title) {
                                                    Book book = books
                                                        .firstWhere((book) =>
                                                            book.title ==
                                                            title);
                                                    return WeReadBookButton(
                                                      book: book,
                                                      onPressed: () =>
                                                          Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              BookPage(
                                                            book: book,
                                                            styleLogic:
                                                                styleLogic,
                                                            authLogic:
                                                                authLogic,
                                                            mainLogic:
                                                                mainLogic,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).toList(),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container(),
                                  Divider(),
                                  Row(
                                    children: [
                                      Paragraph('All Books'),
                                    ],
                                  ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: books
                                          .map((book) => Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  WeReadBookButton(
                                                    book: book,
                                                    onPressed: () =>
                                                        Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            BookPage(
                                                          book: book,
                                                          styleLogic:
                                                              styleLogic,
                                                          authLogic: authLogic,
                                                          mainLogic: mainLogic,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  // button to add book to library
                                                  WeReadIconButton(
                                                    icon: (snapshot.hasData && snapshot.data.contains(book.title)) ? 'remove' : 'add',
                                                    onPressed: () => mainLogic
                                                        .addRemoveFromShelf(
                                                            book.title),
                                                  )
                                                ],
                                              ))
                                          .toList(),
                                    ),
                                  )
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
