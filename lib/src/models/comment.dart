import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:we_read/src/data/db.dart';

class Comment {
  final String id;
  final String userId;
  final String book;
  final int chapter;
  final int paragraph;
  final String text;
  final List<String> tags;
  final int votes;
  final int createdAt;
  String moderatorId;
  String username;


  Comment({
    this.id,
    this.userId,
    this.username,
    this.book,
    this.chapter,
    this.paragraph,
    this.tags,
    this.text,
    this.votes,
    this.moderatorId,
    this.createdAt,
  });

  Map<String, dynamic> toJSON() => {
        DB.CREATED_BY: userId,
        DB.BOOK: book,
        DB.CHAPTER: chapter,
        DB.PARAGRAPH: paragraph,
        DB.TEXT: text,
        DB.TAGS: tags,
        DB.MODERATOR: moderatorId,
        DB.VOTES: votes
      };

  static Comment fromDocumentSnapshot(DocumentSnapshot document)=> Comment(
      userId: document.data[DB.CREATED_BY],
      book: document.data[DB.BOOK],
      chapter: document.data[DB.CHAPTER],
      paragraph: document.data[DB.PARAGRAPH],
      text: document.data[DB.TEXT],
      tags: List<String>.from(document.data[DB.TAGS]),
      moderatorId: document.data[DB.MODERATOR],
      votes: document.data[DB.VOTES] ?? 0,
      id: document.documentID,
      createdAt: document.data[DB.CREATED_AT]);
}
