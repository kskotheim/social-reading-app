import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_read/src/components/auth/auth_logic.dart';
import 'package:we_read/src/components/auth/user.dart';
import 'package:we_read/src/components/commentPage/comment_page.dart';
import 'package:we_read/src/components/currencyIndicator/currency_indicator.dart';
import 'package:we_read/src/components/profile/profile_logic.dart';
import 'package:we_read/src/components/reports/report_dialog.dart';
import 'package:we_read/src/data/repo.dart';
import 'package:we_read/src/logic/main_logic.dart';
import 'package:we_read/src/logic/style_logic.dart';
import 'package:we_read/src/models/notification.dart';
import 'package:we_read/src/widgets/widget_lib.dart';

class UserProfilePage extends StatelessWidget {
  final String token;
  final bool ownProfile;

  UserProfilePage({this.token, this.ownProfile = false})
      : assert(token != null);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ProfileLogic>(
          create: (_) => ProfileLogic(token, ownProfile: ownProfile),
          dispose: (_, logic) => logic.dispose(),
        ),
      ],
      child: _ProvidedProfilePage(),
    );
  }
}

class _ProvidedProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ProfileLogic profileLogic = Provider.of<ProfileLogic>(context);
    return StreamBuilder<ProfileState>(
        stream: profileLogic.profileStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data is ProfileLoading) {
            return CircularProgressIndicator();
          }
          if (snapshot.data is ProfileLoaded) {
            ProfileLoaded event = snapshot.data;
            User currentUser = event.user;

            List<Widget> profilePageChildren = <Widget>[];

            if (profileLogic.ownProfile) {
              if (currentUser.userName == null) {
                profilePageChildren.add(EnterUsernameWidget());
              } else {
                profilePageChildren.add(
                  ChapterTitle('${currentUser.userName}\'s Profile'),
                );
                profilePageChildren.add(Paragraph(currentUser.permissionLevel));
                
                if(Provider.of<AuthLogic>(context, listen: false).userIsPro){
                  profilePageChildren.add(Paragraph('* Pro *'));
                  profilePageChildren.add(Paragraph('Max 6 & per day'));
                }

                if (currentUser.permissionLevel == User.PERMISSION_ONE) {
                  if ((currentUser.postsApproved ?? 0) < 8) {
                    profilePageChildren.add(Paragraph(
                        'Approved Comments: ${currentUser.postsApproved} / 8\n\nAfter 8 comments have been approved you can become a moderator. As a moderator you will be able to help new users and your own comments will be approved automatically'));
                  } else {
                    profilePageChildren.add(WeReadButton(
                      text: 'Become Moderator',
                      onPressed: profileLogic.promoteSelf,
                    ));
                  }
                }

                profilePageChildren.add(StreamBuilder<List<UserNotification>>(
                  stream: profileLogic.notificationList,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return Paragraph('Loading Notifications ...');
                    if (snapshot.data.length == 0)
                      return Paragraph('No Notifications');
                    // otherwise show the notifications:
                    return WeReadCard(
                      child: ListView(
                        shrinkWrap: true,
                        children: List<Widget>.from(
                          snapshot.data.map(
                            (notification) => ListTile(
                              title: Paragraph(notification.notification),
                              leading: WeReadIconButton(
                                onPressed: () => profileLogic
                                    .deleteNotification(notification.id),
                                icon: 'check',
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ));

                profilePageChildren.add(
                  AboutAmpersandButton(),
                );

                profilePageChildren.add(
                  WeReadButton(
                    onPressed: () => Navigator.pop(context),
                    text: 'Back',
                  ),
                );
                profilePageChildren.add(
                  WeReadButton(
                    onPressed: Provider.of<AuthLogic>(context).loggedOut,
                    text: 'Logout',
                  ),
                );
              }
            } else {
              // other user profile:
              profilePageChildren.add(
                ChapterTitle('${currentUser.userName}\'s Profile'),
              );

              profilePageChildren.add(Paragraph(currentUser.permissionLevel));

              profilePageChildren.add(
                WeReadButton(
                    onPressed: () => showDialog(
                          context: context,
                          builder: (_) => ReportDialog(
                            reportedUser: currentUser,
                            authLogic: Provider.of<AuthLogic>(context),
                            styleLogic: Provider.of<StyleLogic>(context),
                          ),
                        ),
                    text: 'Report User'),
              );

              profilePageChildren.add(
                WeReadButton(
                  onPressed: () => Navigator.pop(context),
                  text: 'Back',
                ),
              );

              if (Provider.of<AuthLogic>(context).userIsArbiter) {
                // arbiter actions
                profilePageChildren.add(Divider());
                profilePageChildren.add(MediumText('Arbiter Actions'));
                // reset username
                profilePageChildren.add(
                  WeReadButton(
                    text: 'Reset Username',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: Text(
                                'Are you sure you want to reset this username? \n\n ${currentUser.userName}'),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('Yes'),
                                onPressed: () => Navigator.pop(context, true),
                              ),
                              FlatButton(
                                child: Text('Cancel'),
                                onPressed: () => Navigator.pop(context, false),
                              )
                            ],
                          );
                        },
                      ).then(
                        (result) {
                          if (result ?? false) {
                            profileLogic.resetUsername();
                          }
                        },
                      );
                    },
                  ),
                );
                // demote to initiate
                profilePageChildren.add(
                  WeReadButton(
                    text: 'Demote to Initiate',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: Text(
                                'Are you sure you want to demote this user to Initiate and reset approved comments count? \n\n ${currentUser.userName}'),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('Yes'),
                                onPressed: () => Navigator.pop(context, true),
                              ),
                              FlatButton(
                                child: Text('Cancel'),
                                onPressed: () => Navigator.pop(context, false),
                              )
                            ],
                          );
                        },
                      ).then(
                        (result) {
                          if (result ?? false) {
                            profileLogic.demoteUser();
                          }
                        },
                      );
                    },
                  ),
                );

                // nuclear option - remove user and all their posts
                // profilePageChildren.add(
                //   WeReadButton(
                //     text: 'Block User And Remove All Posts',
                //     onPressed: () {
                //       showDialog(
                //         context: context,
                //         builder: (_) {
                //           return AlertDialog(
                //             title: Text(
                //                 'Are you sure you want to permanently delete this user and all their posts? \n\n ${currentUser.userName}'),
                //             actions: <Widget>[
                //               FlatButton(
                //                 child: Text('Yes'),
                //                 onPressed: () => Navigator.pop(context, true),
                //               ),
                //               FlatButton(
                //                 child: Text('Cancel'),
                //                 onPressed: () => Navigator.pop(context, false),
                //               )
                //             ],
                //           );
                //         },
                //       ).then(
                //         (result) {
                //           if (result ?? false) {
                //             profileLogic.nukeUser();
                //           }
                //         },
                //       );
                //     },
                //   ),
                // );

                // list of this user's comments
                profilePageChildren.add(Divider());
              }
            }

            profilePageChildren.add(
              WeReadButton(
                text: 'Comments',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CommentPage(
                      styleLogic: Provider.of<StyleLogic>(context),
                      authLogic: Provider.of<AuthLogic>(context),
                      mainLogic: Provider.of<MainLogic>(context),
                      getComments:
                          Repo.instance.userComments(currentUser.userId),
                      title: '${currentUser.userName}\'s Comments',
                      popToUser: true,
                    ),
                  ),
                ),
              ),
            );

            // // debug
            // profilePageChildren.add(
            //   WeReadButton(
            //     onPressed: profileLogic.addTenAmpersandsToUser,
            //     text: 'Add &',
            //   ),
            // );

            return Stack(
              children: <Widget>[
                Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: profilePageChildren,
                    ),
                  ),
                ),
                profileLogic.ownProfile ? CurrencyIndicator() : Container(),
              ],
            );
          }
        });
  }
}

class EnterUsernameWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ProfileLogic profileLogic = Provider.of<ProfileLogic>(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ChapterTitle('Enter Username:'),
        Container(
          width: 200.0,
          child: StreamTextField(
            stream: profileLogic.usernameField,
            onChanged: profileLogic.changedUsernameField,
          ),
        ),
        WeReadButton(
          text: 'Submit',
          onPressed: profileLogic.submitUsername,
        ),
      ],
    );
  }
}
