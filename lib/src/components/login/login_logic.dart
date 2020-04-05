import 'dart:async';

import 'package:we_read/src/components/auth/auth_logic.dart';
import 'package:we_read/src/components/auth/auth_repo.dart';
import 'package:we_read/src/logic/bloc_base.dart';

class LoginLogic implements BlocBase{
  final AuthRepository repo = AuthRepository();
  final AuthLogic authLogic;

  static bool _currentUserNameOk = false;
  static bool _currentPasswordOk = false;
  static String _currentUserName = '';
  static String _currentPassword = '';


  // input stream
  StreamController<LoginEvent> _eventStreamController = StreamController<LoginEvent>();
  void loginPressed() => _eventStreamController.sink.add(LoginButtonPressed(username: _currentUserName, password: _currentPassword));
  void resetPasswordPressed() => _eventStreamController.sink.add(ResetPasswordPressed(username: _currentUserName));
  void createUserPressed() => _eventStreamController.sink.add(CreateUserPressed(username: _currentUserName, password: _currentPassword));

  // output stream
  StreamController<LoginState> _stateStreamController = StreamController<LoginState>.broadcast();
  Stream<LoginState> get loginState => _stateStreamController.stream;
  void _loginLoading() => _stateStreamController.sink.add(LoginLoading());
  void _loginInitial() => _stateStreamController.sink.add(LoginInitial()); 
  void _loginFailure(String error) => _stateStreamController.sink.add(LoginFailure(error: error));

  // name field controller
  StreamController<String> _emailFieldController = StreamController<String>.broadcast();
  Stream<String> get email => _emailFieldController.stream.transform(_emailValidator);
  Function get updateEmailField => _emailFieldController.sink.add;


  final _emailValidator = StreamTransformer<String, String>.fromHandlers(
    handleData: (email, sink) async {
      if(_isEmail(email)){
        _currentUserNameOk = true;
        _currentUserName = email;
        sink.add(email);
      }
      else{
        sink.addError('you@example.com');
        _currentUserNameOk = false;
      }
    }
  );

  static bool _isEmail(String email){
    Pattern pattern = r"""^(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])$""";
    RegExp regex = new RegExp(pattern);
    if (regex.hasMatch(email)) return true;
    else return false;
  }


  // password field controller
  StreamController<String> _passwordFieldController = StreamController<String>.broadcast();
  Stream<String> get password => _passwordFieldController.stream.transform(_passwordValidator);
  Function get updatePasswordField => _passwordFieldController.sink.add;

  final _passwordValidator = StreamTransformer<String, String>.fromHandlers(
    handleData: (password, sink){
      if(password.length > 5){
        _currentPasswordOk = true;
        _currentPassword = password;
        sink.add(password);
      }
      else{
        sink.addError('at least 6 characters');
        _currentPasswordOk = false;
      }
    }
  );
  

  LoginLogic({this.authLogic}){
    assert(authLogic != null);
    _eventStreamController.stream.listen(_mapEventToState);
  } 

void _mapEventToState(LoginEvent event) async {
    if (event is LoginButtonPressed) {
      if(_currentUserNameOk && _currentPasswordOk){
        _loginLoading();

        try {
          final String token = await repo.signInWithEmailAndPassword(
              event.username, event.password);
          authLogic.loggedIn(token);
          _loginInitial();
        } catch (error) {
          _loginFailure(error.message);
        }
      } else {
        if(!_currentUserNameOk){
          _loginFailure('must be valid email address');
        } else if( !_currentPasswordOk){
          _loginFailure('password must be at least 6 chars');
        }
      }
    }
    if (event is CreateUserPressed) {
      if(_currentUserNameOk && _currentPasswordOk){
        _loginLoading();

        try {
          final String token = await repo.createUserWithEmailAndPassword(
              event.username, event.password);
          authLogic.loggedIn(token);
          _loginInitial();
        } catch (error) {
          _loginFailure(error.message);
        }
      } else {
        if(!_currentUserNameOk){
          _loginFailure('must be valid email address');
        } else if( !_currentPasswordOk){
          _loginFailure('password must be at least 6 chars');
        }

      }

    }
    if(event is ResetPasswordPressed){
      _loginLoading();
      try {
        await repo.resetPassword(event.username);
        _loginInitial();
      } catch (error) {
        _loginFailure(error.message);
      }
    }
  }

  @override
  void dispose() {
    _eventStreamController.close();
    _stateStreamController.close();
    _emailFieldController.close();
    _passwordFieldController.close();
  }
}

//Login States

abstract class LoginState {
  const LoginState();
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginFailure extends LoginState {
  final String error;

  const LoginFailure({this.error});

  @override
  String toString() => 'LoginFailure { error: $error }';
}

// Login Events

abstract class LoginEvent{
  const LoginEvent();
}

class LoginButtonPressed extends LoginEvent {
  final String username;
  final String password;

  const LoginButtonPressed({
    this.username,
    this.password,
  });

  @override
  String toString() =>
      'LoginButtonPressed { username: $username, password: $password }';
}

class CreateUserPressed extends LoginEvent {
  final String username;
  final String password;

  const CreateUserPressed({
    this.username,
    this.password,
  });

  @override
  String toString() =>
      'CreateUserPressed { username: $username, password: $password }';
}

class ResetPasswordPressed extends LoginEvent {
  final String username;
  const ResetPasswordPressed({this.username});

  @override
  String toString() => 'ResetPasswordPressed { username: $username }';
}
