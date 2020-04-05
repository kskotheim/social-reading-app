import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_read/src/logic/style_logic.dart';
import 'package:we_read/src/models/comment.dart';

class Paragraph extends StatelessWidget {
  final String text;
  final bool faded;

  Paragraph(this.text, {this.faded = false}) : assert(text != null);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 6.0),
      child: Text(
        text,
        style: faded
            ? Provider.of<StyleLogic>(context).fadedParagraphStyle
            : Provider.of<StyleLogic>(context).paragraphStyle,
      ),
    );
  }
}

class MediumText extends StatelessWidget {
  final String text;

  MediumText(this.text) : assert(text != null);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Text(
        text,
        style: Provider.of<StyleLogic>(context).buttonStyle,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class ChapterTitle extends StatelessWidget {
  final String text;

  ChapterTitle(this.text) : assert(text != null);

  @override
  build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        text,
        style: Provider.of<StyleLogic>(context).titleStyle,
      ),
    );
  }
}

class BookTitle extends StatelessWidget {
  final String text;

  BookTitle(this.text) : assert(text != null);

  @override
  build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.fromLTRB(20.0, height * .13, 20.0, height * .1),
      child: Text(
        text,
        style: Provider.of<StyleLogic>(context).titleStyle,
      ),
    );
  }
}

class InfoText extends StatelessWidget {
  final String text;

  InfoText(this.text) : assert(text != null);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Text(
        text,
        style: Provider.of<StyleLogic>(context).infoStyle,
      ),
    );
  }
}

class FontSelectionText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color backgroundColor;

  FontSelectionText(this.text,
      {this.style, this.backgroundColor = Colors.blueGrey})
      : assert(text != null);

  @override
  Widget build(BuildContext context) {
    return
        // Container(
        //   color: backgroundColor,
        //     child:
        Text(
      text,
      style: style,
      // ),
    );
  }
}

class Subtitle extends StatelessWidget {
  final String author;
  final int year;

  Subtitle(this.author, this.year);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'By',
            style: Provider.of<StyleLogic>(context).buttonStyle,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            author,
            style: Provider.of<StyleLogic>(context).buttonStyle,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            year > 0 ? '$year' : '${year.abs()} BCE',
            style: Provider.of<StyleLogic>(context).buttonStyle,
          ),
        ),
      ],
    );
  }
}
