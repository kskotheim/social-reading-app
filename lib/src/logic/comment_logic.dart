import 'dart:async';

import 'package:we_read/src/components/auth/auth_logic.dart';
import 'package:we_read/src/data/repo.dart';
import 'package:we_read/src/logic/bloc_base.dart';
import 'package:we_read/src/logic/book_logic.dart';
import 'package:we_read/src/models/comment.dart';
import 'package:we_read/src/models/notification.dart';

class CommentLogic implements BlocBase {
  final BookLogic bookLogic;
  final AuthLogic authLogic;

  final RepositoryManager repo = Repo.instance;

  // input stream
  StreamController<CommentEvent> _eventController =
      StreamController<CommentEvent>();
  void upvoteComment(Comment comment) =>
      _eventController.sink.add(UpvoteComment(comment: comment));


  // book logic can be null, as when you are viewing a single user's comments
  CommentLogic({this.bookLogic, this.authLogic}) {
    assert(authLogic != null);
    _eventController.stream.listen(_mapEventToState);
  }

  void _mapEventToState(CommentEvent event) async {
    if (event is UpvoteComment) {
      if (authLogic.userHasAmpersands) {
        await repo.incrementAmpersands(authLogic.token, -1);
        await repo.upvoteComment(event.comment.id);
        if (authLogic.token != event.comment.userId) {
          await repo.incrementAmpersands(event.comment.userId, .5);
          await repo.notifyUser(
            event.comment.userId,
            UserNotification(
                notification:
                    '${authLogic.username} upvoted your comment: ${event.comment.text}',
                fromUserId: authLogic.token),
          );
        }
      }


      if(bookLogic != null) bookLogic.getComments();
    }
  }

  @override
  void dispose() {
    _eventController.close();
  }
}

class CommentEvent {}

class UpvoteComment extends CommentEvent {
  final Comment comment;
  UpvoteComment({this.comment}) : assert(comment != null);
}

class CommentState {}
