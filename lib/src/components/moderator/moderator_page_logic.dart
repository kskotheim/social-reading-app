
import 'dart:async';

import 'package:we_read/src/components/auth/auth_logic.dart';
import 'package:we_read/src/components/auth/user.dart';
import 'package:we_read/src/data/db.dart';
import 'package:we_read/src/data/repo.dart';
import 'package:we_read/src/logic/bloc_base.dart';
import 'package:we_read/src/models/comment.dart';
import 'package:we_read/src/models/notification.dart';
import 'package:we_read/src/models/report.dart';

class ModeratorPageLogic implements BlocBase {
  
  final AuthLogic authLogic;
  final RepositoryManager repo = Repo.instance;

  Comment _commentToBeModerated;
  String _commenterUsername;
  String get commenterUsername => _commenterUsername;

  
  // input stream
  StreamController<ModeratorPageEvent> _inputController = StreamController<ModeratorPageEvent>();
  void approvePost() => _inputController.sink.add(PostApproved());
  void disapprovePost() => _inputController.sink.add(PostDisapproved());
  void disapproveAndReportUsername() => _inputController.sink.add(PostDisapprovedAndReportUsername());
  void disapproveAndReportComment() => _inputController.sink.add(PostDisapprovedAndReportComment());
  void pageClosed() => _inputController.sink.add(ModeratorPageClosed());

  // output stream
  StreamController<ModeratorPageState> _outputController = StreamController<ModeratorPageState>();
  Stream<ModeratorPageState> get pageStateStream => _outputController.stream;
  void _loadingPost() => _outputController.sink.add(LoadingPost());
  void _noPostsToModerate() => _outputController.sink.add(NoPostsToModerate());
  void _postRetrieved(Comment comment) => _outputController.sink.add(PostRetrieved(comment: comment));

  ModeratorPageLogic({this.authLogic}){
    assert(authLogic != null);
    _inputController.stream.listen(_mapEventToState);
    _loadingPost();
    _checkForComments();
  }

  void _checkForComments(){
    repo.getPostToBeApproved().then((comment) async {
      if(comment == null){
        _noPostsToModerate();
        _commentToBeModerated = null;
      } else {
        _commenterUsername = await repo.getSingleUser(comment.userId).then((user) => user.userName);
        _postRetrieved(comment);
        _commentToBeModerated = comment;
      }
    });
  }
  
  void _mapEventToState(ModeratorPageEvent event) async {
    if(event is PostApproved){
      // create comment, delete comment-to-be-approved, notify poster, reward moderator, load new comment-to-be-approved
      _commentToBeModerated.moderatorId = authLogic.token;
      User commenter = await repo.getSingleUser(_commentToBeModerated.userId);
      repo.updateUser(_commentToBeModerated.userId, {DB.POSTS_APPROVED: commenter.postsApproved + 1});
      repo.notifyUser(_commentToBeModerated.userId, UserNotification(notification: 'The following comment was approved: ${_commentToBeModerated.text}', fromUserId: authLogic.token));
      await repo.approveComment(_commentToBeModerated);
      _checkForComments();
    }
    if(event is PostDisapproved){
      // delete comment-to-be-approved, notify poster, reward moderator, load new comment-to-be-approved
      repo.notifyUser(_commentToBeModerated.userId, UserNotification(notification: 'The following comment was not approved: ${_commentToBeModerated.text}', fromUserId: authLogic.token));
      await repo.disapproveComment(_commentToBeModerated.id);
      _checkForComments();
    }
    if(event is PostDisapprovedAndReportUsername){
      // delete comment-to-be-approved, notify poster, reward moderator, create report ticket
      repo.createReport(Report(userId: _commentToBeModerated.userId, reportingUserId: authLogic.token, reportedContent: 'Reported Username: ${_commentToBeModerated.username}', reportedUsername: _commentToBeModerated.username, reportingUsername: authLogic.username));
      repo.notifyUser(_commentToBeModerated.userId, UserNotification(notification: 'Content you submitted has been deemed inappropriate: $commenterUsername', fromUserId: authLogic.token));
      await repo.disapproveComment(_commentToBeModerated.id);
      // generate report for username
      _checkForComments();
    }
    if(event is PostDisapprovedAndReportComment){
      // delete comment to be approved, notify poster, reward moderator, create report ticket
      repo.createReport(Report(userId: _commentToBeModerated.userId, reportingUserId: authLogic.token, reportedContent: 'Reported Comment: ${_commentToBeModerated.text}', reportedUsername: _commentToBeModerated.username, reportingUsername: authLogic.username));
      repo.notifyUser(_commentToBeModerated.userId, UserNotification(notification: 'Content you submitted has been deemed inappropriate: ${_commentToBeModerated.text}', fromUserId: authLogic.token));
      await repo.disapproveComment(_commentToBeModerated.id);
      _checkForComments();
    }
    if(event is ModeratorPageClosed){
      // if comment is loaded, update it so that it is no longer under review
      print('resetting comment review status');
      if(_commentToBeModerated != null){
        repo.updateCommentReviewStatus(_commentToBeModerated.id, false);
      }
    }
  }

  
  
  @override
  void dispose() {
    _inputController.close();
    _outputController.close();
  }

}



class ModeratorPageState {}

class NoPostsToModerate extends ModeratorPageState {}

class PostRetrieved extends ModeratorPageState {
  final Comment comment;
  PostRetrieved({this.comment}) : assert(comment != null);
}

class LoadingPost extends ModeratorPageState {}


class ModeratorPageEvent {}

class PostApproved extends ModeratorPageEvent {}

class PostDisapproved extends ModeratorPageEvent {}

class PostDisapprovedAndReportUsername extends ModeratorPageEvent {}

class PostDisapprovedAndReportComment extends ModeratorPageEvent {}

class ModeratorPageClosed extends ModeratorPageEvent {}

