import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_read/src/components/legal/privacy_policy.dart';
import 'package:we_read/src/components/legal/terms_and_conditions.dart';
import 'package:we_read/src/logic/style_logic.dart';
import 'package:we_read/src/widgets/widget_lib.dart';

class SettingsPage extends StatelessWidget {
  final StyleLogic styleLogic;

  SettingsPage(this.styleLogic) : assert(styleLogic != null);

  @override
  Widget build(BuildContext context) {
    return Provider<StyleLogic>(
      create: (context) => styleLogic,
      child: _ProvidedSettings(),
    );
  }
}

class _ProvidedSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    StyleLogic styleLogic = Provider.of<StyleLogic>(context);
    return StreamBuilder<TextStyle>(
      stream: styleLogic.testStyle,
      builder: (context, snapshot) {
        TextStyle testStyle;
        if (!snapshot.hasData) {
          testStyle = TextStyle(fontSize: 12.0);
        } else {
          testStyle = snapshot.data;
        }

        return Scaffold(
          backgroundColor: styleLogic.backgroundColor,
          body: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ChapterTitle(
                    'Size',
                  ),
                  Slider(
                    value: testStyle.fontSize,
                    min: 10.0,
                    max: 30.0,
                    onChanged: styleLogic.setFontSize,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * .2,
                    child: SingleChildScrollView(
                      child: Paragraph(
                          'WeRead was created in Humboldt County, California.\n\nWe appreciate your feedback or suggestions! Get in touch with us at info@snapdragonapps.com'),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                      child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ChapterTitle(
                          'Font',
                        ),

                        WeReadDropDown<String>(
                          items: StyleLogic.FONT_STYLES.map((style) => DropdownMenuItem(
                            
                            value: style,
                            child: FontSelectionText(style, style: styleLogic.buttonStyleSpecificFont(style),),
                            
                          )).toList(),
                          value: styleLogic.fontString,
                          onChanged: styleLogic.setFontStyle,
                        ),
                      ],
                    ),
                  ),
                  
                    // GridView.count(
                    //   crossAxisCount: 3,
                    //   shrinkWrap: true,
                    //   children: List<Widget>.from(
                    //     StyleLogic.FONT_STYLES.map(
                    //       (font) =>  WeReadButton(
                    //         text: font,
                    //         font: font,
                    //         selected: styleLogic.fontString == font,
                    //         onPressed: () => styleLogic.setFontStyle(font),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ChapterTitle(
                        'Dark Mode',
                      ),
                      Switch(
                        value: styleLogic.darkModeEnabled,
                        onChanged: styleLogic.setDarkMode,
                      )
                    ],
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ChapterTitle(
                          'Paragraph Mode',
                        ),
                        Switch(
                          value: styleLogic.paragraphModeEnabled,
                          onChanged: styleLogic.setParagraphMode,
                        )
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ChapterTitle(
                        styleLogic.showRecentComments ? 'Recent Comments' : 'Top Comments',
                      ),
                      Switch(
                        value: styleLogic.showRecentComments,
                        onChanged: styleLogic.setRecentComments,
                      )
                    ],
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        WeReadButton(
                          text: 'Privacy Policy',
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PrivacyPolicyPage(styleLogic: styleLogic))),
                        ),
                        WeReadButton(
                          text: 'Terms and Conditions',
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TermsAndConditionsPage(styleLogic: styleLogic))),
                        )
                      ],
                    ),
                  ),
                  const VerticalSpace(30.0),
                  WeReadButton(
                    text: 'Back',
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
