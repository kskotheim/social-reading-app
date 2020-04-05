import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_read/src/logic/style_logic.dart';
import 'package:we_read/src/widgets/widget_lib.dart';

class TermsAndConditionsPage extends StatelessWidget {
  final StyleLogic styleLogic;

  TermsAndConditionsPage({this.styleLogic}) : assert(styleLogic != null);

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => styleLogic,
      child: WeReadScaffold(
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              BookTitle('We Read Terms And Conditions'),
              Paragraph(''' 
Comments and User Interaction

By using this service you agree not to engage in any offensive or inappropriate behavior, including:

\t\tHarassment or abuse of other users
\t\tNegative or derogatory comments about religion, ethnicity, nationality, gender, disability, or any group of people
\t\tExplicit depictions of violence
\t\tPosting copyrighted or otherwise legally protected material
\t\tPosting personally identifying information of yourself or anyone else
\t\tAny comments that are meant to offend, intimidate, harass, or marginalize
\t\tOtherwise abusing the platform in such a way that negatively impacts other users’ experience

If you engage in offensive or inappropriate behavior in this app your account, username, and any or all posts you make may be permanently removed from the platform.

You also acknowledge that you may be exposed to inappropriate comments that other users have submitted which violate these rules. You are encouraged report any user who violates these rules, or comments you believe to be inappropriate. You can report a user through this platform by clicking on their username, and then ‘Report User’.


General Terms and Conditions

By downloading or using the app, these terms will automatically apply to you – you should make sure therefore that you read them carefully before using the app. You’re not allowed to copy, or modify the app, any part of the app, or our trademarks in any way. You’re not allowed to attempt to extract the source code of the app, or make derivative versions. The app itself, and all the trade marks, copyright, database rights and other intellectual property rights related to it, still belong to Snapdragon Development.

Snapdragon Development is committed to ensuring that the app is as useful and efficient as possible. For that reason, we reserve the right to make changes to the app or to charge for its services, at any time and for any reason. We will never charge you for the app or its services without making it very clear to you exactly what you’re paying for.

The We Read app stores and processes personal data that you have provided to us, in order to provide our Service. It’s your responsibility to keep your phone and access to the app secure. We therefore recommend that you do not jailbreak or root your phone, which is the process of removing software restrictions and limitations imposed by the official operating system of your device. It could make your phone vulnerable to malware/viruses/malicious programs, compromise your phone’s security features and it could mean that the We Read app won’t work properly or at all.

You should be aware that there are certain things that Snapdragon Development will not take responsibility for. Certain functions of the app, including viewing comments or logging in, will require the app to have an active internet connection. The connection can be Wi-Fi, or provided by your mobile network provider, but Snapdragon Development cannot take responsibility for the app not working at full functionality if you don’t have access to Wi-Fi, and you don’t have any of your data allowance left.

If you’re using the app outside of an area with Wi-Fi, you should remember that your terms of the agreement with your mobile network provider will still apply. As a result, you may be charged by your mobile provider for the cost of data for the duration of the connection while accessing the app, or other third party charges. In using the app, you’re accepting responsibility for any such charges, including roaming data charges if you use the app outside of your home territory (i.e. region or country) without turning off data roaming. If you are not the bill payer for the device on which you’re using the app, please be aware that we assume that you have received permission from the bill payer for using the app.

Along the same lines, Snapdragon Development cannot always take responsibility for the way you use the app i.e. You need to make sure that your device stays charged – if it runs out of battery and you can’t turn it on to avail the Service, Snapdragon Development cannot accept responsibility.

With respect to Snapdragon Development’s responsibility for your use of the app, when you’re using the app, it’s important to bear in mind that although we endeavour to ensure that it is updated and correct at all times, we do rely on third parties to provide information to us so that we can make it available to you. Snapdragon Development accepts no liability for any loss, direct or indirect, you experience as a result of relying wholly on this functionality of the app.

At some point, we may wish to update the app. The app is currently available on Android & iOS – the requirements for both systems (and for any additional systems we decide to extend the availability of the app to) may change, and you’ll need to download the updates if you want to keep using the app. Snapdragon Development does not promise that it will always update the app so that it is relevant to you and/or works with the Android & iOS version that you have installed on your device. However, you promise to always accept updates to the application when offered to you, We may also wish to stop providing the app, and may terminate use of it at any time without giving notice of termination to you. Unless we tell you otherwise, upon any termination, (a) the rights and licenses granted to you in these terms will end; (b) you must stop using the app, and (if needed) delete it from your device.


Changes to This Terms and Conditions

We may update our Terms and Conditions from time to time. Thus, you are advised to review this page periodically for any changes. We will notify you of any changes by posting the new Terms and Conditions on this page. These changes are effective immediately after they are posted on this page.


Contact Us

If you have any questions or suggestions about our Terms and Conditions, do not hesitate to contact us at info@snapdragonapps.com.

'''),
              WeReadButton(
                text: 'back',
                onPressed: () => Navigator.pop(context),
              ),
              VerticalSpace(100.0)
            ],
          ),
        ),
      ),
    );
  }
}
