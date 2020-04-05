import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:we_read/src/logic/style_logic.dart';
import 'package:we_read/src/models/book.dart';
import 'package:we_read/src/ui/settings.dart';
import 'package:we_read/src/widgets/spacing_widgets.dart';
import 'package:we_read/src/widgets/text_widgets.dart';

class WeReadButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final String font;

  WeReadButton({this.text, this.onPressed, this.font}) : assert(text != null);

  @override
  Widget build(BuildContext context) {
    bool specificFont = false;
    if (font != null && StyleLogic.FONT_STYLES.contains(font)) {
      specificFont = true;
    }
    bool darkMode = Provider.of<StyleLogic>(context).darkModeEnabled;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: RaisedButton(
        color: darkMode ? Colors.blueGrey.shade900 : Colors.blueGrey.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
          side: BorderSide(
              color: darkMode
                  ? Colors.blueGrey.shade200
                  : Colors.blueGrey.shade400),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            text,
            style: specificFont
                ? Provider.of<StyleLogic>(context).buttonStyleSpecificFont(font)
                : Provider.of<StyleLogic>(context).buttonStyle,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class WeReadBookButton extends StatelessWidget {
  final Book book;
  final Function onPressed;

  WeReadBookButton({this.book, this.onPressed}) : assert(book != null);

  @override
  Widget build(BuildContext context) {
    // bool darkMode = Provider.of<StyleLogic>(context).darkModeEnabled;
    return Container(
      width: 200.0,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.asset(book.image, width: 220.0, height: 300.0),
                VerticalSpace(12.0),
                Text(
                  book.title,
                  textAlign: TextAlign.center,
                  style: Provider.of<StyleLogic>(context).buttonStyle,
                ),
                VerticalSpace(12.0),
                Text(
                  book.author,
                  textAlign: TextAlign.center,
                  style: Provider.of<StyleLogic>(context).buttonStyle,
                ),
              ],
            ),
          ),
          onTap: onPressed,
        ),
      ),
    );
  }
}

class WeReadIconButton extends StatelessWidget {
  final String icon;
  final Function onPressed;

  WeReadIconButton({this.icon, this.onPressed})
      : assert(icon != null, onPressed != null);

  @override
  Widget build(BuildContext context) {
    bool darkMode = Provider.of<StyleLogic>(context).darkModeEnabled;
    Color iconColor = darkMode ? StyleLogic.lightColor : StyleLogic.darkColor;
    Color iconBg = darkMode ? Colors.blueGrey : Colors.blueGrey.shade100;
    Icon theIcon = Icon(Icons.device_unknown);
    if (icon == 'back') {
      theIcon = Icon(Icons.arrow_back, color: iconColor);
    }
    if (icon == 'next') {
      theIcon = Icon(Icons.arrow_forward, color: iconColor);
    }
    if (icon == 'settings') {
      theIcon = Icon(
        Icons.settings,
        color: iconColor,
      );
    }
    if (icon == 'title') {
      theIcon = Icon(Entypo.book, color: iconColor);
    }
    if (icon == 'home') {
      theIcon = Icon(
        Icons.home,
        color: iconColor,
      );
    }
    if (icon == 'bookmark') {
      theIcon = Icon(
        Icons.bookmark,
        color: iconColor,
      );
    }
    if (icon == 'bookmarkOutline') {
      theIcon = Icon(
        Icons.bookmark_border,
        color: iconColor,
      );
    }
    if (icon == 'login') {
      theIcon = Icon(
        Icons.computer,
        color: iconColor,
      );
    }
    if (icon == 'favorite') {
      theIcon = Icon(
        Icons.star_border,
        color: iconColor,
      );
    }
    if (icon == 'currentFavorite') {
      theIcon = Icon(
        Icons.star,
        color: iconColor,
      );
    }
    if (icon == 'comment') {
      theIcon = Icon(
        Icons.mode_comment,
        color: iconColor,
      );
    }
    if (icon == 'up') {
      theIcon = Icon(
        Icons.arrow_drop_up,
        color: iconColor,
      );
    }
    if (icon == 'check') {
      theIcon = Icon(Icons.check, color: iconColor);
    }
    if (icon == 'delete') {
      theIcon = Icon(
        Icons.delete,
        color: iconColor,
      );
    }
    if (icon == 'user') {
      theIcon = Icon(
        Icons.account_circle,
        color: iconColor,
      );
    }
    if (icon == 'other_user') {
      theIcon = Icon(
        Icons.supervisor_account,
        color: iconColor,
      );
    }
    if (icon == 'list') {
      theIcon = Icon(
        Icons.list,
        color: iconColor,
      );
    }
    if (icon == 'text') {
      theIcon = Icon(
        Icons.text_fields,
        color: iconColor,
      );
    }
    if (icon == 'store') {
      theIcon = Icon(Icons.shopping_cart, color: iconColor);
    }
    if (icon == 'add') {
      theIcon = Icon(MaterialIcons.library_add);
    }
    if (icon == 'remove') {
      theIcon = Icon(FontAwesome.remove);
    }

    return IconButton(
      icon: theIcon,
      onPressed: onPressed,
      color: iconBg,
    );
  }
}

class WeReadDropDown<K> extends StatelessWidget {
  final List<DropdownMenuItem> items;
  final K value;
  final Function onChanged;

  WeReadDropDown({this.items, this.value, this.onChanged})
      : assert(items != null),
        assert(value != null),
        assert(onChanged != null);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white70,
      child: DropdownButton<K>(
        value: value,
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}

class SettingsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WeReadIconButton(
      icon: 'settings',
      onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (newContext) =>
                  SettingsPage(Provider.of<StyleLogic>(context)))),
    );
  }
}

class AboutAmpersandButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WeReadButton(
      text: 'About &',
      onPressed: () => showDialog(
        context: context,
        builder: (_) => Provider(
          create: (_) => Provider.of<StyleLogic>(context),
          child: SimpleDialog(
            backgroundColor: Provider.of<StyleLogic>(context).darkModeEnabled
                ? StyleLogic.darkColor
                : Colors.white,
            title: Center(child: MediumText('& is Currency')),
            children: <Widget>[
              Paragraph(
                'Once you are signed in, one & is awarded every five minutes you spend in the app uninterrupted. You can earn up to 3 & this way every day. \n\n&\'s are spent by commenting or upvoting comments. Each comment or upvote costs one &.\n\nEvery time someone upvotes one of your comments, you are awarded half of one &.\n\nIf you become a supporter, you can earn 6 & each day you log in and read for 30 minutes. You can also purchase a bundle of & in the store. \n\nWe appreciate your participation and support!',
              ),
              WeReadButton(
                text: 'Back',
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
        ),
      ),
    );
  }
}
