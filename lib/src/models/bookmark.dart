import 'dart:convert';

class Bookmark {
  final String bookTitle;
  final int chapter;
  final int paragraph;

  static const String _BOOK_TITLE = 'Title';
  static const String _CHAPTER = 'Chapter';
  static const String _PARAGRAPH = 'Paragraph';

  Bookmark({
    this.bookTitle,
    this.chapter,
    this.paragraph,
  })  : assert(bookTitle != null),
        assert(chapter != null),
        assert(paragraph != null);


  @override
  String toString(){
    return jsonEncode(toJSON());
  }
  
  Map<String, dynamic> toJSON() => {_BOOK_TITLE:bookTitle, _CHAPTER:chapter, _PARAGRAPH:paragraph};

  static Bookmark fromJson(String json){
    var data = jsonDecode(json);
    return Bookmark(bookTitle: data[_BOOK_TITLE], chapter: data[_CHAPTER], paragraph: data[_PARAGRAPH]);
  }


  bool operator ==(bm) => bm is Bookmark && bm.bookTitle == bookTitle && bm.chapter == chapter && bm.paragraph == paragraph;
  int get hashCode => bookTitle.hashCode + chapter.hashCode + paragraph.hashCode;
}
