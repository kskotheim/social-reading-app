
class Book {
  final String title;
  final String author;
  final String image;
  final List<Chapter> chapters;
  final int year;
  const Book({this.title, this.chapters, this.author, this.year, this.image});
}

class Chapter {
  final String title;
  final List<String> paragraphs;
  final int index;
  const Chapter({this.title, this.paragraphs, this.index});

}

class Section {
  final String title;
  final int index;
  final List<Chapter> chapters;
  const Section({this.title, this.chapters, this.index});
}