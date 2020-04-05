import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_read/src/data/repo.dart';

class RewardTracker {

  final RepositoryManager repo = Repo.instance;
  SharedPreferences prefs;
  
  void setUserId(String token) => _userId = token;
  void start() => _setTimer();

  Timer _timer;
  String _userId;

  int _rewardsToday;
  String _lastRewardDate;
  static const String _REWARD_DATE = 'Reward Date';
  static const String _REWARD_COUNTER = 'Reward Counter';

  bool _userIsPro = false;
  void setUserAsPro() => _userIsPro = true;


  RewardTracker(){
    _getPrefs();
  }

  void _getPrefs() async {
    prefs = await SharedPreferences.getInstance();
    _lastRewardDate = prefs.getString(_REWARD_DATE);
    if(_lastRewardDate != _todaysDateAsString()){
      _rewardsToday = 0;
    } else {
      _rewardsToday = prefs.getInt(_REWARD_COUNTER);
    }
  }

  void _setTimer(){
    _timer = Timer(Duration(minutes: 5), _callThis);
  }

  void _callThis(){
    if(_userId != null && (_rewardsToday < 3 || (_userIsPro && _rewardsToday < 6))){
      repo.incrementAmpersands(_userId, 1.0);
      _rewardsToday ++;
      prefs.setString(_REWARD_DATE, _todaysDateAsString());
      prefs.setInt(_REWARD_COUNTER, _rewardsToday);
    }
    _setTimer();
  }

  void dispose(){
    _timer?.cancel();
  }

  String _todaysDateAsString() {
    DateTime now = DateTime.now();
    return "${now.day}-${now.month}-${now.year}";
  }

}