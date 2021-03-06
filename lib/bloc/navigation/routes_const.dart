import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pubg/SplashScreen.dart';
import 'package:pubg/about/ui/about_screen.dart';
import 'package:pubg/about/ui/third_party_screen.dart';
import 'package:pubg/data_source/event_repository.dart';
import 'package:pubg/data_source/login_repository.dart';
import 'package:pubg/data_source/user_repository.dart';
import 'package:pubg/event_notification/bloc/bloc.dart';
import 'package:pubg/event_notification/bloc/event_notification_bloc.dart';
import 'package:pubg/event_notification/ui/EventNotificationScreen.dart';
import 'package:pubg/home_screen/bloc/bloc.dart';
import 'package:pubg/home_screen/bloc/home_screen_bloc.dart';
import 'package:pubg/home_screen/ui/home_screen.dart';
import 'package:pubg/login/bloc/bloc.dart';
import 'package:pubg/login/ui/login_screen.dart';
import 'package:pubg/register/bloc/bloc.dart';
import 'package:pubg/register/ui/register_screen.dart';
import 'package:pubg/team_detail/bloc/bloc.dart';
import 'package:pubg/team_detail/ui/team_detail_screen.dart';
import 'package:pubg/user_detail/bloc/bloc.dart';
import 'package:pubg/user_detail/ui/profile_update_screen.dart';

class ScreenRoutes {
  static const String SPLASH_SCREEN_ROUTE = "/splash";
  static const String LOGIN_SCREEN_ROUTE = "/login";
  static const String REGISTER_SCREEN_ROUTE = "/register";
  static const String USER_PROFILE_SCREEN_ROUTE = "/user_profile";
  static const String TEAM_CREATION_SCREEN_ROUTE = "/create_team";
  static const String JOIN_TEAM_ROUTE = "/join_team";
  static const String HOME_SCREEN_ROUTE = "/home_Screen";
  static const String TEAM_DETAIL_SCREEN_ROUTE = "/team_detail";
  static const String SLOT_SELECTION_SCREEN_ROUTE = "/slot_selection";
  static const String ABOUT_SCREEN_ROUTE = "/about";
  static const String EVENT_NOTIFICATION_SCREEN_ROUTE = "/notification_screen";
  static const String THIRD_PARTY_SCREEN_ROUTE = "/third_party";
}

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case ScreenRoutes.SPLASH_SCREEN_ROUTE:
      return MaterialPageRoute(builder: (context) => SplashScreen());

    case ScreenRoutes.LOGIN_SCREEN_ROUTE:
      return MaterialPageRoute(
          builder: (context) => BlocProvider(
              create: (context) => LoginBloc(
                  loginRepository:
                      RepositoryProvider.of<LoginRepository>(context)),
              child: LoginScreen()));

    case ScreenRoutes.REGISTER_SCREEN_ROUTE:
      return MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => RegisterBloc(
              loginRepository: RepositoryProvider.of<LoginRepository>(context)),
          child: RegisterScreen(),
        ),
      );

    case ScreenRoutes.HOME_SCREEN_ROUTE:
      return MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => HomeScreenBloc(
              userRepository: RepositoryProvider.of<UserRepository>(context),
              eventRepository: EventRepository()),
          child: HomeScreen(),
        ),
      );

    case ScreenRoutes.USER_PROFILE_SCREEN_ROUTE:
      return MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => UserProfileBloc(
            userRepository: RepositoryProvider.of<UserRepository>(context),
          )..add(ProfileScreenInitialized()),
          child: UserProfileScreen(),
        ),
      );

    case ScreenRoutes.TEAM_DETAIL_SCREEN_ROUTE:
      return MaterialPageRoute(builder: (context) {
        return BlocProvider<TeamDetailBloc>(
            create: (context) => TeamDetailBloc(
                userRepository: RepositoryProvider.of<UserRepository>(context)),
            child: TeamDetailScreen(
              isFormEditable: (settings.arguments as bool),
            ));
      });

    case ScreenRoutes.ABOUT_SCREEN_ROUTE:
      return MaterialPageRoute(builder: (context) {
        return AboutScreen();
      });

    case ScreenRoutes.EVENT_NOTIFICATION_SCREEN_ROUTE:
      return MaterialPageRoute(builder: (context) {
        return BlocProvider<EventNotificationBloc>(
          create: (context) => EventNotificationBloc(
            repository: EventRepository(),
            userRepository: RepositoryProvider.of<UserRepository>(context),
          )..add(LoadEventNotifications()),
          child: EventNotificationScreen(),
        );
      });

    case ScreenRoutes.THIRD_PARTY_SCREEN_ROUTE:
      return MaterialPageRoute(builder: (context) => ThirdPartyScreen());

    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ));
  }
}
