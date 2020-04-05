import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_read/src/logic/style_logic.dart';

class StreamTextField<K> extends StatelessWidget {
  final Stream<K> stream;
  final Function(String) onChanged;
  final bool obscureText;
  final GlobalKey fieldKey = GlobalKey();
  final String hint;

  StreamTextField({this.stream, this.onChanged, this.obscureText = false, this.hint})
      : assert(stream != null, onChanged != null);

  @override
  Widget build(BuildContext context) {
    bool darkMode = Provider.of<StyleLogic>(context).darkModeEnabled;
    return StreamBuilder<K>(
      stream: stream,
      builder: (context, snapshot) {
        return TextField(
          
          key: fieldKey,
          style: Provider.of<StyleLogic>(context).buttonStyle,
          onChanged: onChanged,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            enabledBorder: UnderlineInputBorder(      
                      borderSide: BorderSide(color: darkMode ? Colors.white70 : Colors.black87),   
                      ),  
              focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: darkMode ? Colors.blue.shade200 : Colors.blue.shade800),
                   ),
          ),
          // decoration: InputDecoration(
          //   fillColor: darkMode ? Colors.purple.shade900 : Colors.purple.shade100,
          //   errorText: snapshot.error,
          //   border: OutlineInputBorder(
          //     borderSide: BorderSide(
          //         color: darkMode ? Colors.white : Colors.deepPurple),
          //   ),
          //   disabledBorder: OutlineInputBorder(
          //     borderSide:
          //         BorderSide(color: darkMode ? Colors.white : Colors.orange),
          //   ),
          // ),
        );
      },
    );
  }
}



class CommentField extends StatelessWidget {
  final Stream<String> stream;
  final Function(String) onChanged;
  final GlobalKey fieldKey = GlobalKey();

  CommentField({this.stream, this.onChanged})
      : assert(stream != null, onChanged != null);

  @override
  Widget build(BuildContext context) {
    bool darkMode = Provider.of<StyleLogic>(context).darkModeEnabled;
    return StreamBuilder<String>(
      stream: stream,
      builder: (context, snapshot) {
        return TextField(
          minLines: 3,
          maxLines: 8,
          key: fieldKey,
          style: Provider.of<StyleLogic>(context).buttonStyle,
          onChanged: onChanged,
        );
      },
    );
  }
}
