import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_read/src/data/repo.dart';
import 'package:we_read/src/logic/style_logic.dart';
import 'package:we_read/src/models/book.dart';
import 'package:we_read/src/models/bookmark.dart';
import 'package:we_read/src/models/comment.dart';
import 'bloc_base.dart';

class BookLogic implements BlocBase {

  final Book book;
  final StyleLogic style;
  final Bookmark initiateAtBookmark;
  Bookmark bookmark;
  int currentChapter;
  int currentParagraph;
  bool get currentPageIsBookmark => bookmark != null && bookmark.chapter == currentChapter && (bookmark.paragraph == currentParagraph || !style.paragraphModeEnabled) ? true : false;
  bool get currentParagraphIsBookmark => bookmark != null && bookmark.chapter == currentChapter && bookmark.paragraph == currentParagraph ? true : false;
  Bookmark get currentSpotAsBookmark => Bookmark(bookTitle: book.title, chapter: currentChapter, paragraph: currentParagraph);

  ScrollController scrollController = ScrollController(initialScrollOffset: 0.0);
  ScrollController titleScrollController = ScrollController(initialScrollOffset: 0.0);

  SharedPreferences prefs;
  String get _bookmarkPrefsKey => 'BOOKMARK-${book.title}';
  RepositoryManager repo = Repo.instance;
  

  String get currentParagraphText => currentParagraph > -1 ? book.chapters[currentChapter].paragraphs[currentParagraph] : book.chapters[currentChapter].title;

  // input stream
  StreamController<BookEvent> _bookEventController = StreamController<BookEvent>();
  void nextChapter() => _bookEventController.sink.add(NextChapterEvent());
  void previousChapter() => _bookEventController.sink.add(PreviousChapterEvent());
  void goToTitle() => _bookEventController.sink.add(NavigateToTitleEvent());
  void goToChapter(int chapter, {int paragraph = -1}) => _bookEventController.sink.add(NavigateToChapterEvent(chapter, paragraph: paragraph)); 
  void showParagraphDetails(int paragraph) => _bookEventController.sink.add(NavigateToParagraphInCurrentChapterEvent(paragraph: paragraph));
  void goToParagraph(int chapter, int paragraph) => _bookEventController.sink.add(NavigateToParagraphEvent(chapter: chapter, paragraph: paragraph));
  void nextParagraph() => goToParagraph(currentChapter, currentParagraph + 1);
  void previousParagraph() => goToParagraph(currentChapter, currentParagraph - 1);
  void setBookmark(int chapter, int paragraph) => _bookEventController.sink.add(SetBookmarkEvent(chapter: chapter, paragraph: paragraph));
  void setBookmarkCurrentParagraph() => setBookmark(currentChapter, currentParagraph);
  void goToBookmark() => _bookEventController.sink.add(NavigateToBookmarkEvent());

  // output stream
  StreamController<BookState> _bookStateController = StreamController<BookState>();
  Stream<BookState> get bookState => _bookStateController.stream;
  void _goToCurrentChapter() => _bookStateController.sink.add(BookStateChapter(currentChapter));
  void _goToTitle() => _bookStateController.sink.add(BookStateTitle());
  void _goToCurrentParagraph() {
    getComments();
    _bookStateController.sink.add(BookStateParagraph(chapter: currentChapter, paragraph: currentParagraph));
  }

  void getComments() {
    repo.getComments(book.title, currentChapter, currentParagraph, style.showRecentComments, 3).then((comments) => _commentController.sink.add(comments));
  }

  // output stream 2 - current bookmark
  BehaviorSubject<Bookmark> _bookmarkController = BehaviorSubject<Bookmark>();
  Stream<Bookmark> get bookmarkStream => _bookmarkController.stream;
  void _setBookmark(Bookmark bookmark) => _bookmarkController.sink.add(bookmark);
  void _removeBookmark() => _bookmarkController.sink.add(null);

  // output stream 3 - title fade
  StreamController<double> _titleFadeController = StreamController<double>.broadcast();
  Stream<double> get fadeStream => _titleFadeController.stream;
  void _setTitleFade(double fade) => _titleFadeController.sink.add(fade);

  // output stream 4 - comments stream
  StreamController<List<Comment>> _commentController = StreamController<List<Comment>>.broadcast();
  Stream<List<Comment>> get currentParagraphComments => _commentController.stream;

  BookLogic({this.book, this.style, this.initiateAtBookmark}){
    assert(style != null);
    assert(book != null);
    _bookEventController.stream.listen(mapEventToState);
    currentChapter = -1;
    currentParagraph = -1;
    _getPrefs();
    titleScrollController.addListener(_fadeTitle);
  }

  void _fadeTitle(){
    double fade = 1 - (titleScrollController.offset / 400);
    if(fade < 0) fade = 0;
    _setTitleFade(fade);
  }

  Future<void> _getPrefs() async {
    prefs = await SharedPreferences.getInstance();
    if(initiateAtBookmark != null){
      currentChapter = initiateAtBookmark.chapter;
      currentParagraph = initiateAtBookmark.paragraph;
      _goToCurrentParagraph();
    } else if(prefs.getKeys().contains(_bookmarkPrefsKey)){
      bookmark = Bookmark.fromJson(prefs.getString(_bookmarkPrefsKey));
      
      _setBookmark(bookmark);
      goToBookmark();
      
    } else {
      goToTitle();
    }
  }

  void resetScrollController(){
    if(scrollController.hasClients){
      scrollController.jumpTo(0.0);
    }
  }


  void mapEventToState(BookEvent event) async {
    if(event is NextChapterEvent){
      currentParagraph = -1;
      if(currentChapter < book.chapters.length){
        resetScrollController();
        currentChapter = currentChapter + 1;
      }
      _goToCurrentChapter();
    }
    if(event is PreviousChapterEvent){
      currentParagraph = -1;
      if(currentChapter > 0) {
        resetScrollController();
        currentChapter = currentChapter - 1;
      }
      _goToCurrentChapter();
    }
    if(event is NavigateToTitleEvent){
      currentChapter = -1;
      _goToTitle();
    }
    if(event is NavigateToChapterEvent){
      resetScrollController();
      currentChapter = event.chapter;
      currentParagraph = event.paragraph;
      _goToCurrentChapter();
    }
    if(event is NavigateToParagraphInCurrentChapterEvent){
      currentParagraph = event.paragraph;
      getComments();
      _goToCurrentChapter();
    }
    if(event is NavigateToParagraphEvent){
      resetScrollController();
      if(event.chapter >=0 && 
          event.chapter < book.chapters.length && 
          event.paragraph >= -1 && 
          event.paragraph < book.chapters[event.chapter].paragraphs.length){
        currentChapter = event.chapter;
        currentParagraph = event.paragraph;
        _goToCurrentParagraph();
      } else if(event.paragraph >= book.chapters[event.chapter].paragraphs.length && event.chapter < book.chapters.length -1) {
        //go to next chapter
        currentChapter = event.chapter + 1;
        currentParagraph = -1;
        _goToCurrentParagraph();
      } else if(event.paragraph < -1 && event.chapter > 0){
        currentChapter = event.chapter -1;
        currentParagraph = book.chapters[currentChapter].paragraphs.length -1;
        _goToCurrentParagraph();
      } else {
        _goToTitle();
      }
    }
    if(event is SetBookmarkEvent){
      Bookmark newBookmark = Bookmark(bookTitle: book.title, chapter: event.chapter, paragraph: event.paragraph);
      if(bookmark == null || bookmark.chapter != newBookmark.chapter || bookmark.paragraph != newBookmark.paragraph){
        var result = await prefs.setString(_bookmarkPrefsKey, newBookmark.toString());
        bookmark = newBookmark;
        _setBookmark(bookmark);
      }
      else{
        var result = await prefs.remove(_bookmarkPrefsKey);
        bookmark = null;
        _removeBookmark();
      }
    }
    if(event is NavigateToBookmarkEvent){
      if(style.paragraphModeEnabled){
        goToParagraph(bookmark.chapter, bookmark.paragraph);
      } else {
        goToChapter(bookmark.chapter, paragraph: bookmark.paragraph);
        getComments();
      }
    }
  }





  @override
  void dispose() {
    _bookEventController.close();
    _bookStateController.close();
    _bookmarkController.close();
    _titleFadeController.close();
    _commentController.close();
  }

}

// book events

class BookEvent {}

class NextChapterEvent extends BookEvent{}

class PreviousChapterEvent extends BookEvent{}

class NavigateToTitleEvent extends BookEvent{}

class NavigateToBookmarkEvent extends BookEvent{}

class NavigateToChapterEvent extends BookEvent {
  final int chapter;
  final int paragraph;
  final double scrollPct;
  NavigateToChapterEvent(this.chapter, {this.paragraph = -1, this.scrollPct = 0}) : assert(chapter != null);
}

class NavigateToParagraphEvent extends BookEvent {
  final int chapter;
  final int paragraph;
  NavigateToParagraphEvent({this.chapter, this.paragraph}) : assert(chapter != null, paragraph != null);
}

class NavigateToParagraphInCurrentChapterEvent extends BookEvent {
  final int paragraph;
  NavigateToParagraphInCurrentChapterEvent({this.paragraph}) : assert(paragraph != null);
}


class SetBookmarkEvent extends BookEvent {
  final int chapter;
  final int paragraph;
  SetBookmarkEvent({this.chapter, this.paragraph}) : assert(chapter != null, paragraph != null);
}

// book state

class BookState {}

class BookStateTitle extends BookState{}

class BookStateChapter extends BookState{
  final int chapter;
  final double scrollPct;
  BookStateChapter(this.chapter, {this.scrollPct = 0}) : assert(chapter != null);
}

class BookStateParagraph extends BookState{
  final int chapter;
  final int paragraph;
  BookStateParagraph({this.chapter, this.paragraph}) : assert(chapter != null, paragraph != null);
}