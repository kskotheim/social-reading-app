import 'dart:async';

import 'package:we_read/src/data/repo.dart';
import 'package:we_read/src/logic/bloc_base.dart';
import 'package:we_read/src/models/comment.dart';

class CommentPageLogic implements BlocBase {
  final Future<List<Comment>> getComments;
  final RepositoryManager repo = Repo.instance;

  // input stream
  StreamController<CommentPageEvent> _inputController = StreamController<CommentPageEvent>();
  void deleteComment(String commentId) => _inputController.sink.add(DeleteComment(commentId));

  // output stream
  StreamController<List<Comment>> _commentController = StreamController<List<Comment>>();
  Stream<List<Comment>> get comments => _commentController.stream;

  CommentPageLogic({this.getComments}) {
    assert(getComments != null);
    // repo.getUserComments(userId).map(_commentStream.sink.add);
    getComments.then(_commentController.sink.add);
    _inputController.stream.listen(_mapEventToState);
  }

  void _mapEventToState(CommentPageEvent event){
    if(event is DeleteComment){
      repo.deleteComment(event.commentId);
    }
  }


  @override
  void dispose() {
    _commentController.close();
    _inputController.close();
  }
}

class CommentPageEvent {}

class DeleteComment extends CommentPageEvent {
  final String commentId;
  DeleteComment(this.commentId) : assert(commentId != null);
}