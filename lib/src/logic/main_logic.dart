import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_read/src/data/repo.dart';
import 'package:we_read/src/logic/bloc_base.dart';
import 'package:we_read/src/models/book.dart';
import 'package:we_read/src/models/bookmark.dart';

class MainLogic implements BlocBase {

  static const String _FAVORITES = 'Favorites';
  static const String _SHELF = 'Shelf';
  SharedPreferences _prefs;
  RepositoryManager repo = Repo.instance;
  List<Bookmark> favorites = [];
  List<String> shelf = [];

  // input stream
  StreamController<MainEvent> _eventController = StreamController<MainEvent>();
  void setFavorite(Bookmark bookmark) => _eventController.sink.add(SetFavorite(bookmark));
  void addRemoveFromShelf(String book) => _eventController.sink.add(AddOrRemoveBookFromShelf(book));
  void deleteComment(String commentId) => _eventController.sink.add(DeleteComment(commentId));

  // output stream 1 - favorites
  StreamController<List<Bookmark>> _favoritesController = StreamController<List<Bookmark>>.broadcast();
  void _updateFavorites() => _favoritesController.sink.add(favorites ?? []);
  Stream<List<Bookmark>> get favoritesStream => _favoritesController.stream;

  // output stream 2 - bookshelf
  StreamController<List<String>> _shelfController = StreamController<List<String>>.broadcast();
  void _updateShelf() => _shelfController.sink.add(shelf ?? []);
  Stream<List<String>> get shelfStream => _shelfController.stream;

  MainLogic(){
    _getPrefs();
    _eventController.stream.listen(_mapEventToState);
  }

  void _mapEventToState(MainEvent event) async {
    if(event is SetFavorite){
      if(favorites.contains(event.bookmark)){
        favorites.removeWhere((fav) => fav == event.bookmark);
      } else {
        favorites = (favorites ?? <Bookmark>[]) + <Bookmark>[event.bookmark];
      }
      await _prefs.setStringList(_FAVORITES, favorites.map((fav) => fav.toString()).toList());
      _updateFavorites();
    }

    if(event is AddOrRemoveBookFromShelf){
      if(shelf.contains(event.book)){
        shelf.remove(event.book);
      } else {
        shelf.add(event.book);
      }
      await _prefs.setStringList(_SHELF, shelf);
      _updateShelf();
    }

    if(event is DeleteComment){
      repo.deleteComment(event.commentId);
    }
  }
  
  Future<void> _getPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    List<String> favoritesPrefs = _prefs.getStringList(_FAVORITES);
    if(favoritesPrefs != null){
      favorites = favoritesPrefs.map(Bookmark.fromJson).toList();
      _updateFavorites();
    }
    List<String> shelfPrefs = _prefs.getStringList(_SHELF);
    if(shelfPrefs != null){
      shelf = shelfPrefs;
      _updateShelf();
    }
  }


  @override
  void dispose() {
    _eventController.close();
    _favoritesController.close();
    _shelfController.close();
  }

}

// events

class MainEvent{}


class SetFavorite extends MainEvent {
  final Bookmark bookmark;
  SetFavorite(this.bookmark) : assert(bookmark != null);
}

class AddOrRemoveBookFromShelf extends MainEvent {
  final String book;
  AddOrRemoveBookFromShelf(this.book) : assert(book != null);
}

class DeleteComment extends MainEvent{
  final String commentId;
  DeleteComment(this.commentId) : assert(commentId != null);
}

// states


