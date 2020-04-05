import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:rxdart/subjects.dart';
import 'package:we_read/src/components/auth/user.dart';
import 'package:we_read/src/data/db.dart';
import 'package:we_read/src/data/repo.dart';
import 'package:we_read/src/logic/bloc_base.dart';
import 'package:we_read/src/models/notification.dart';


class ProfileLogic implements BlocBase {

  final String token;
  final bool ownProfile;
  String _username;
  List<UserNotification> _notifications;
  RepositoryManager repo = Repo.instance;

  // input stream
  StreamController<ProfileEvent> _profileEventController = StreamController<ProfileEvent>();
  void submitUsername() => _profileEventController.sink.add(SubmitUsernameEvent());
  void deleteNotification(String notificationId) => _profileEventController.sink.add(DeleteNotificationEvent(notificationId));
  void _usernameUpdated(User user){ 
    if(!_profileEventController.isClosed) _profileEventController.sink.add(UsernameUpdatedEvent(user: user));
  }
  void promoteSelf() => _profileEventController.sink.add(PromoteSelfEvent());
  void resetUsername() => _profileEventController.sink.add(ResetUsernameEvent());
  void demoteUser() => _profileEventController.sink.add(DemoteUserEvent());
  // void nukeUser() => _profileEventController.sink.add(NukeUser());

  // output stream
  BehaviorSubject<ProfileState> _profileStateController = BehaviorSubject<ProfileState>();
  Stream<ProfileState> get profileStream => _profileStateController.stream;
  void _profileLoaded(User user) => _profileStateController.sink.add(ProfileLoaded(user: user));
  void _profileLoading() => _profileStateController.sink.add(ProfileLoading());

  // output stream 2 - user notifications
  BehaviorSubject<List<UserNotification>> _notificationListController = BehaviorSubject<List<UserNotification>>();
  Stream<List<UserNotification>> get notificationList => _notificationListController.stream;
  Function(List<UserNotification>) get _addNotifications => _notificationListController.sink.add;

  // stream for username field
  StreamController<String> _usernameController = StreamController<String>();
  void changedUsernameField(String name){
    _username = name;
    _usernameController.sink.add(name);
  }
  Stream<String> get usernameField => _usernameController.stream;
  

  ProfileLogic(this.token, {this.ownProfile = false}){
    assert(token != null);
    _profileLoading();
    // listen for changes to user and update profile page
    repo.getUser(token).listen(_usernameUpdated);
    if(ownProfile){
      repo.userNotificationStream(token).listen(_addNotifications);
    }
    _profileEventController.stream.listen(_mapEventToState);
  }

  void _mapEventToState(ProfileEvent event){
    if(event is SubmitUsernameEvent){
      // set username in db ...
      repo.updateUser(token, {DB.NAME: _username});
    }
    if(event is UsernameUpdatedEvent){
      _profileLoaded(event.user);
    }
    if(event is PromoteSelfEvent){
      repo.updateUser(token, {DB.PERMISSION: User.PERMISSION_TWO});
    }
    if(event is DemoteUserEvent){
      repo.updateUser(token, {DB.PERMISSION: User.PERMISSION_ONE, DB.POSTS_APPROVED: 0});
    }
    if(event is DeleteNotificationEvent){
      repo.deleteUserNotification(token, event.notificationId);
    }
    if(event is ResetUsernameEvent){
      repo.resetUsername(token);
    }
    // if(event is NukeUser){
    //   repo.nukeUser(token);
    // }
  }

  // debug button
  void addTenAmpersandsToUser(){
    repo.incrementAmpersands(token, 10);
  }

  void dispose() {
    _profileEventController.close();
    _profileStateController.close();
    _usernameController.close();
    _notificationListController.close();
  }

}

// input events
class ProfileEvent{}

class SubmitUsernameEvent extends ProfileEvent{}

class UsernameUpdatedEvent extends ProfileEvent {
  User user;
  UsernameUpdatedEvent({this.user});
}

class DeleteNotificationEvent extends ProfileEvent {
  final String notificationId;
  DeleteNotificationEvent(this.notificationId) : assert(notificationId != null);
}

class PromoteSelfEvent extends ProfileEvent {}

class ResetUsernameEvent extends ProfileEvent {}

class DemoteUserEvent extends ProfileEvent {}

// class NukeUser extends ProfileEvent {}

// output states
class ProfileState{}

class ProfileLoading extends ProfileState{}

class ProfileLoaded extends ProfileState{
  final User user;
  ProfileLoaded({this.user}) : assert(user != null);
}