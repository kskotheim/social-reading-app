import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:we_read/src/components/auth/auth_repo.dart';
import 'package:we_read/src/components/auth/user.dart';
import 'package:we_read/src/components/store/store_logic.dart';
import 'package:we_read/src/data/repo.dart';
import 'package:we_read/src/logic/bloc_base.dart';
import 'package:we_read/src/logic/reward_tracker.dart';

// This class is used to interface with the auth repository. It logs the user in or out.
// This bloc is listened to by the root widget to determine whether to show the login page

class AuthLogic implements BlocBase {
  final AuthRepository authRepo = AuthRepository();
  String token;
  final RewardTracker tracker;
  final RepositoryManager dbRepo = Repo.instance;
  StoreLogic storeLogic;
  
  User _currentUser;
  bool get userHasAmpersands => _currentUser != null && _currentUser.ampersands >= 1.0;
  bool get userIsModerator => _currentUser != null && _currentUser.permissionLevel != User.PERMISSION_ONE;
  bool get userIsArbiter => _currentUser != null && _currentUser.permissionLevel == User.PERMISSION_THREE;
  int get usersApprovedPosts => _currentUser?.postsApproved ?? 0;
  String get username => _currentUser.userName;
  bool get userIsPro => _currentUser.isPro;
  void setUserAsPro(){
    _currentUser.isPro = true;
    tracker.setUserAsPro();
  }


  // input stream
  StreamController<AuthEvent> _eventController = StreamController<AuthEvent>();
  void appStarted() => _eventController.sink.add(AppStarted());
  void loggedIn(String token) => _eventController.sink.add(LoggedIn(token: token)); 
  void loggedOut() => _eventController.sink.add(LoggedOut());

  // output stream
  BehaviorSubject<AuthState> _stateController = BehaviorSubject<AuthState>();
  Stream<AuthState> get authenticationStateStream => _stateController.stream;

  void _userAuthenticated() async {
    _stateController.sink.add(AuthStateLoading());
    _currentUser = await dbRepo.getSingleUser(token);
    dbRepo.getUser(token).listen((user) {
      _stateController.sink.add(AuthStateAuthenticated(token));
      _currentUser = user;
    });
    tracker.setUserId(token);
    storeLogic = StoreLogic(authLogic: this);
    _stateController.sink.add(AuthStateAuthenticated(token));
  }
  void _userNotAuthenticated(){
    if(storeLogic != null){
      storeLogic.dispose();
    }
    _stateController.sink.add(AuthStateNotAuthenticated());
  }

  AuthLogic({this.tracker}) {
    appStarted();
    _eventController.stream.listen(_mapEventToState);
  }

  void _mapEventToState(AuthEvent event) async {
    if(event is LoggedIn){
      token = event.token;
      _userAuthenticated();
    }
    if(event is LoggedOut){
      authRepo.signOut();
      token = null;
      _userNotAuthenticated();
    }
    if(event is AppStarted){
      token = await authRepo.getCurrentUser();
      if(token != null){
        _userAuthenticated();
      } else {
        _userNotAuthenticated();
      }
    }
  }

  @override
  void dispose() {
    _eventController.close();
    _stateController.close();
    storeLogic?.dispose();
  }
}

//Authorization State - Bloc output
class AuthState  {}

class AuthStateNotAuthenticated extends AuthState {}

class AuthStateAuthenticated extends AuthState {
  final String token;
  final int authTime = DateTime.now().millisecondsSinceEpoch;
  AuthStateAuthenticated(this.token) : assert(token != null);
}

class AuthStateUninitialized extends AuthState {}

class AuthStateLoading extends AuthState {}

//Authorization Event - Bloc Input
class AuthEvent {
  const AuthEvent();
}

class AppStarted extends AuthEvent {}

class LoggedIn extends AuthEvent {
  final String token;
  const LoggedIn({this.token}) : assert(token != null);

  @override
  String toString() => 'Logged in {token: $token}';
}

class LoggedOut extends AuthEvent {}
