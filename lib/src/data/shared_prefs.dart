// import 'package:shared_preferences/shared_preferences.dart';

// abstract class SharedPrefsManager{

//   Future<void> saveStyle(String style);
//   String getStyle();

// }

// class SharedPrefs implements SharedPrefsManager {
//   static SharedPreferences _instance;
//   static const String _STYLE = 'Style';

//   SharedPrefs(){
//     if(_instance == null){
//       _getPrefs();
//     }
//   }

//   void _getPrefs() async {
//     _instance = await SharedPreferences.getInstance();
//   }

//   Future<void> saveStyle(String style){
//     return _instance.setString(_STYLE, style);
//   }

//   String getStyle(){
//     return _instance.getString(_STYLE);
//   }

// }