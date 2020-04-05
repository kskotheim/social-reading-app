import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_read/src/logic/bloc_base.dart';

class StyleLogic implements BlocBase{
  static const FONT_STYLES = <String>[
    'Times',
    'PTSerif',
    'Baskerville',
    'Cabin',
    'CrimsonText',
    'Lora',
    'Cairo',
    'CourierPrime',
    'Comfortaa',
    'Raleway',
    'JosefinSans',
    'Montserrat',
    'OpenSans',
    'Quicksand',
    'Lacquer',
    'IndieFlower',
    'DancingScript',
    'Caveat',
    'Satisfy',
    'GreatVibes',
    'Galada',
    'PermanentMarker',
  ];

  SharedPreferences prefs;

  static const lightColor = Colors.white70;
  static const darkColor = Colors.black87;

  static const fadedLightColor = Colors.white54;
  static const fadedDarkColor = Colors.black54;

  double _baseFontSize = 12.0;
  bool _darkMode = false;
  bool _paragraphMode = false;
  bool _recentComments = true;
  String _font = 'Times';
  String get fontString => _font;
  bool get darkModeEnabled => _darkMode;
  bool get paragraphModeEnabled => _paragraphMode;
  bool get showRecentComments => _recentComments;
  Color get backgroundColor => darkModeEnabled ? Colors.black38 : Colors.white;

  // input stream
  StreamController<StyleInputEvent> _setStyleController = StreamController<StyleInputEvent>();
  void setFontSize(double size) => _setStyleController.sink.add(SetSizeEvent(size: size));
  void setFontStyle(String style) => _setStyleController.sink.add(SetFontEvent(font: style));
  void setDarkMode(bool darkMode) => _setStyleController.sink.add(SetDarkModeEvent(darkModeEnabled: darkMode));
  void setParagraphMode(bool paragraphMode) => _setStyleController.sink.add(SetParagraphModeEvent(paragraphModeEnabled: paragraphMode));
  void setRecentComments(bool recent) => _setStyleController.sink.add(SetCommentTypeEvent(showRecentComments: recent ?? true));

  // output stream
  BehaviorSubject<TextStyle> _testStyleController = BehaviorSubject<TextStyle>();
  Stream<TextStyle> get testStyle => _testStyleController.stream;
  void _setTestStyle() {
    _testStyleController.sink.add(paragraphStyle);
  }

  // output stream to notify changes between book mode / paragraph mode
  BehaviorSubject<bool> _paragraphModeController = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get paragraphModeEnabledStream => _paragraphModeController.stream;

  StyleLogic(){
    _setStyleController.stream.listen(_mapEventToState);
    _setTestStyle();
    _getPreferences();
  }

  Future<void> _getPreferences() async {
    prefs = await SharedPreferences.getInstance();
    String styleStr = prefs.getString('Style');
    if(styleStr != null){
      _loadStyleFromString(styleStr);
    }
  }

  void _mapEventToState(StyleInputEvent event){
    if(event is SetFontEvent){
      _font = event.font;
    }
    if(event is SetSizeEvent){
      _baseFontSize = event.size;
    }
    if(event is SetDarkModeEvent){
      _darkMode = event.darkModeEnabled;
    }
    if(event is SetParagraphModeEvent){
      _paragraphMode = event.paragraphModeEnabled;
      _paragraphModeController.sink.add(_paragraphMode);
    }
    if(event is SetCommentTypeEvent){
      _recentComments = event.showRecentComments;
    }
    _setTestStyle();
    prefs.setString('Style', _styleToString);
  }


  TextStyle get titleStyle => TextStyle(
      color: _darkMode ? lightColor : darkColor,
      fontSize: _baseFontSize + 10.0,
      fontFamily: _font
  );

  TextStyle get paragraphStyle => TextStyle(
      color: _darkMode ? lightColor : darkColor,
      fontSize: _baseFontSize,
      fontFamily: _font
  );

  TextStyle get fadedParagraphStyle => TextStyle(
      color: _darkMode ? fadedLightColor : fadedDarkColor,
      fontSize: _baseFontSize,
      fontFamily: _font
  );

  TextStyle get buttonStyle => TextStyle(
      color: _darkMode ? lightColor : darkColor,
      fontSize: _baseFontSize + 4.0,
      fontFamily: _font,
  );

  TextStyle get underlinedMediumStyle => TextStyle(
      color: _darkMode ? lightColor : darkColor,
      fontSize: _baseFontSize + 4.0,
      fontFamily: _font,
      decoration: TextDecoration.underline,
  );

  TextStyle buttonStyleSpecificFont(String font) => TextStyle(
      color: 
      // _darkMode ? lightColor : 
      darkColor,
      fontSize: _baseFontSize + 4.0,
      fontFamily: font
  );

  TextStyle get infoStyle => TextStyle(color: _darkMode ? lightColor : darkColor,
      fontSize: _baseFontSize - 2.0,
      fontFamily: 'Times'
  );

  String get _styleToString => jsonEncode({'Size': _baseFontSize, 'Font': _font, 'Dark': _darkMode, 'Paragraph': _paragraphMode, 'Recent': _recentComments});
  
  void _loadStyleFromString(String style){
    var vals = jsonDecode(style);
    setFontSize(vals['Size']);
    setFontStyle(vals['Font']);
    setDarkMode(vals['Dark']);
    setRecentComments(vals['Recent']);
    setParagraphMode(vals['Paragraph']);
  }

  @override
  void dispose() {
    _setStyleController.close();
    _testStyleController.close();
    _paragraphModeController.close();
  }
}


class StyleInputEvent {}

class SetFontEvent extends StyleInputEvent {
  final String font;
  SetFontEvent({this.font}) : assert(font != null);
}

class SetSizeEvent extends StyleInputEvent {
  final double size;
  SetSizeEvent({this.size}) : assert(size != null);
}

class SetDarkModeEvent extends StyleInputEvent {
  final bool darkModeEnabled;
  SetDarkModeEvent({this.darkModeEnabled}) : assert(darkModeEnabled != null);
}

class SetParagraphModeEvent extends StyleInputEvent {
  final bool paragraphModeEnabled;
  SetParagraphModeEvent({this.paragraphModeEnabled}) : assert(paragraphModeEnabled != null);
}

class SetCommentTypeEvent extends StyleInputEvent {
  final bool showRecentComments;
  SetCommentTypeEvent({this.showRecentComments}) : assert(showRecentComments != null);
}