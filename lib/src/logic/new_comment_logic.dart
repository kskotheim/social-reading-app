import 'dart:async';

import 'package:we_read/src/components/auth/auth_logic.dart';
import 'package:we_read/src/data/repo.dart';
import 'package:we_read/src/logic/bloc_base.dart';
import 'package:we_read/src/logic/book_logic.dart';
import 'package:we_read/src/models/comment.dart';

class NewCommentLogic implements BlocBase {
  final AuthLogic authLogic;
  final BookLogic bookLogic;
  RepositoryManager repo = Repo.instance;
  String comment = '';

  NewCommentLogic({this.authLogic, this.bookLogic}) {
    assert(authLogic != null, bookLogic != null);
    _eventStreamController.stream.listen(_mapEventToState);
    _stateStreamController.add(CommentStateInitial());
  }

  StreamController<String> _commentTextController = StreamController<String>();
  Stream<String> get commentText => _commentTextController.stream;
  void onChanged(String text) {
    comment = text;
    _commentTextController.sink.add(text);
  }

  // input stream
  StreamController<CommentEvent> _eventStreamController =
      StreamController<CommentEvent>();
  void submitComment() => _eventStreamController.sink.add(CreateComment());

  // output stream
  StreamController<CommentState> _stateStreamController =
      StreamController<CommentState>.broadcast();
  Stream<CommentState> get commentState => _stateStreamController.stream;

  void _mapEventToState(CommentEvent event) async {
    if (event is CreateComment) {
      _stateStreamController.sink.add(CommentStateLoading());
      if (comment != null && comment.isNotEmpty) {
        await repo.createComment(
            Comment(
              userId: authLogic.token,
              book: bookLogic.book.title,
              chapter: bookLogic.currentChapter,
              paragraph: bookLogic.currentParagraph,
              text: comment,
              tags: [],
              moderatorId: authLogic.userIsModerator ? authLogic.token : null,
            ),
            !authLogic.userIsModerator);
        await repo.incrementAmpersands(authLogic.token, -1);
      }
      bookLogic.getComments();
      _stateStreamController.sink.add(CommentStateSubmitted());
    }
  }

  @override
  void dispose() {
    _eventStreamController.close();
    _stateStreamController.close();
    _commentTextController.close();
  }
}

// input types
class CommentEvent {}

class CreateComment extends CommentEvent {}

// output types

class CommentState {}

class CommentStateInitial extends CommentState {}

class CommentStateLoading extends CommentState {}

class CommentStateSubmitted extends CommentState {}
