import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pubg/bloc/navigation/bloc.dart';
import 'package:pubg/data_source/model/available_event.dart';
import 'package:pubg/home_screen/bloc/bloc.dart';
import 'package:pubg/util/notification_util.dart';
import 'package:pubg/util/widget_util.dart';

import 'no_internet_Screen.dart';
import 'slot_selection_dialog.dart';

class AvailableEventWidget extends StatefulWidget {
  @override
  _AvailableEventWidgetState createState() => _AvailableEventWidgetState();
}

class _AvailableEventWidgetState extends State<AvailableEventWidget> {
  static List<String> queryParam = [
    "gaming",
    "call of duty",
    "xbox",
    "game",
    "video game"
  ];
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    _initializeFirebaseMessaging();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeScreenBloc, HomeScreenState>(
      buildWhen: (HomeScreenState previous, HomeScreenState current) {
        if ((current is AvailableEventsLoading) ||
            (current is AvailableEventsFailure) ||
            (current is AvailableEventsSuccess)) {
          return true;
        } else {
          return false;
        }
      },
      builder: (context, state) {
        if (state is AvailableEventsSuccess) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Center(
                  child: Text(
                    "Available Events",
                    style: TextStyle(
                        fontFamily: FontAwesomeIcons.font.fontFamily,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w500,
                        fontSize: 16),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: state.availableEvents.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, position) {
                      return GestureDetector(
                        child:
                        _getEventCard(state.availableEvents[position]),
                        onTap: () {
                          BlocProvider.of<HomeScreenBloc>(context).add(EventSelected(
                              eventID:
                              state.availableEvents[position].eventID));
                        },
                      );
                    }),
              ),
            ],
          );
        } else if (state is AvailableEventsLoading) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Center(
            child: NoInternetWidget(),
          );
        }
      },
      listener: (listenerContext, state) {
        if (state is MissingUserDetails) {
          BlocProvider.of<NavigationBloc>(listenerContext)
              .add(UserProfileNavigateEvent());
        } else if (state is ShowSlotDialog) {
          showModalBottomSheet(
              context: context,
              builder: (buildContext) {
                return SlotSelectionDialog(
                  homeScreenBloc: BlocProvider.of<HomeScreenBloc>(context),
                  eventId: state.eventID,
                );
              });
        } else if (state is EventRegistrationSuccess) {
          Navigator.of(listenerContext).pop();
        }
      },
    );
  }

  Widget _getEventCard(AvailableEvent event) {
    return SizedBox.fromSize(
      size: Size(MediaQuery.of(context).size.width, 200),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Stack(
          children: <Widget>[
            Card(
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                          "https://source.unsplash.com/featured/?${queryParam[Random.secure().nextInt(queryParam.length - 1)]},${queryParam[Random.secure().nextInt(queryParam.length - 1)]}",
                        ),
                        colorFilter:
                        ColorFilter.mode(Colors.grey, BlendMode.overlay))),
              ),
            ),
            Positioned(
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          event.eventName,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w400),
                        ),
                        Text(
                          event.eventDescription,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 2,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              bottom: -20,
              left: 10,
            ),
            Positioned(
              child: Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
              right: 30,
              bottom: 10,
            )
          ],
          overflow: Overflow.visible,
        ),
      ),
    );
  }

  _initializeFirebaseMessaging() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        handleNotificationEvent(message);
        Scaffold.of(context).showSnackBar(buildSnackBar("New Event Details Received"));
      },
      onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        handleNotificationEvent(message);
        BlocProvider.of<NavigationBloc>(context).add(EventNotificationsNavigationEvent());
      },
      onResume: (Map<String, dynamic> message) async {
        handleNotificationEvent(message);
        BlocProvider.of<NavigationBloc>(context).add(EventNotificationsNavigationEvent());
      },
    );
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      BlocProvider.of<HomeScreenBloc>(context).add(UpdateFcmCode(fcmCode: token));
    });
  }

  handleNotificationEvent(Map<String, dynamic> message) {
    if (message['data'] != null) {
      BlocProvider.of<HomeScreenBloc>(context).add(EventNotificationReceived(
          roomId: message['data']['room_id'] as String,
          roomPassword: message['data']['room_password'] as String,
          eventId: message['data']['event_id'] as String));
    }
  }
}