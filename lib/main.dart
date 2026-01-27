import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:lestar_user/common/widgets/cookies_view_widget.dart';
import 'package:lestar_user/features/auth/controllers/auth_controller.dart';
import 'package:lestar_user/features/cart/controllers/cart_controller.dart';
import 'package:lestar_user/features/favourite/controllers/favourite_controller.dart';
import 'package:lestar_user/features/language/controllers/localization_controller.dart';
import 'package:lestar_user/features/notification/domain/models/notification_body_model.dart';
import 'package:lestar_user/features/splash/controllers/splash_controller.dart';
import 'package:lestar_user/features/splash/controllers/theme_controller.dart';
import 'package:lestar_user/features/splash/domain/models/deep_link_body.dart';
import 'package:lestar_user/helper/notification_helper.dart';
import 'package:lestar_user/helper/responsive_helper.dart';
import 'package:lestar_user/helper/route_helper.dart';
import 'package:lestar_user/theme/dark_theme.dart';
import 'package:lestar_user/theme/light_theme.dart';
import 'package:lestar_user/util/app_constants.dart';
import 'package:lestar_user/util/messages.dart';
import 'package:meta_seo/meta_seo.dart';
import 'package:url_strategy/url_strategy.dart';

import 'helper/get_di.dart' as di;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  if (ResponsiveHelper.isMobilePhone()) {
    HttpOverrides.global = MyHttpOverrides();
  }
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  // // Pass all uncaught "fatal" errors from the framework to Crashlytics
  // FlutterError.onError = (errorDetails) {
  //   FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  // };
  // // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //   return true;
  // };

  DeepLinkBody? linkBody;

  if (GetPlatform.isWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyCe9lGU5ipFZqBXHED3VDoTmr4NkurOnSI',
        appId: '1:825010792860:web:56b9bc25291894162d0059',
        messagingSenderId: '825010792860',
        projectId: 'id-lestari-project',
        authDomain: 'id-lestari-project.firebaseapp.com',
        storageBucket: 'id-lestari-project.firebasestorage.app',
      ),
    );
    MetaSEO().config();
  } else if (GetPlatform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyBCYEiAddYw8VXhfjyhicxO3Qi0jYOuJnM',
        appId: '1:825010792860:android:e990b667b0e7b9972d0059',
        messagingSenderId: '825010792860',
        projectId: 'id-lestari-project',
        storageBucket: 'id-lestari-project.firebasestorage.app',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  Map<String, Map<String, String>> languages = await di.init();

  NotificationBodyModel? body;
  try {
    if (GetPlatform.isMobile) {
      final RemoteMessage? remoteMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (remoteMessage != null) {
        body = NotificationHelper.convertNotification(remoteMessage.data);
      }
      await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    }
  } catch (_) {}

  if (ResponsiveHelper.isWeb()) {
    await FacebookAuth.instance.webAndDesktopInitialize(
      appId: "452131619626499",
      cookie: true,
      xfbml: true,
      version: "v13.0",
    );
  }
  runApp(MyApp(languages: languages, body: body, linkBody: linkBody));
}

class MyApp extends StatefulWidget {
  final Map<String, Map<String, String>>? languages;
  final NotificationBodyModel? body;
  final DeepLinkBody? linkBody;
  const MyApp({
    super.key,
    required this.languages,
    required this.body,
    required this.linkBody,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    _route();
  }

  Future<void> _route() async {
    if (GetPlatform.isWeb) {
      Get.find<SplashController>().initSharedData();
      if (!Get.find<AuthController>().isLoggedIn() &&
          !Get.find<AuthController>()
              .isGuestLoggedIn() /*&& !ResponsiveHelper.isDesktop(Get.context!)*/ ) {
        await Get.find<AuthController>().guestLogin();
      }
      if (Get.find<AuthController>().isLoggedIn() ||
          Get.find<AuthController>().isGuestLoggedIn()) {
        Get.find<CartController>().getCartDataOnline();
      }
      Get.find<SplashController>().getConfigData(fromMainFunction: true);
      if (Get.find<AuthController>().isLoggedIn()) {
        Get.find<AuthController>().updateToken();
        await Get.find<FavouriteController>().getFavouriteList();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return GetBuilder<LocalizationController>(
          builder: (localizeController) {
            return GetBuilder<SplashController>(
              builder: (splashController) {
                return (GetPlatform.isWeb &&
                        splashController.configModel == null)
                    ? const SizedBox()
                    : GetMaterialApp(
                        title: AppConstants.appName,
                        debugShowCheckedModeBanner: false,
                        navigatorKey: Get.key,
                        scrollBehavior: const MaterialScrollBehavior().copyWith(
                          dragDevices: {
                            PointerDeviceKind.mouse,
                            PointerDeviceKind.touch,
                          },
                        ),
                        theme: themeController.darkTheme ? dark : light,
                        locale: localizeController.locale,
                        translations: Messages(languages: widget.languages),
                        fallbackLocale: Locale(
                          AppConstants.languages[0].languageCode!,
                          AppConstants.languages[0].countryCode,
                        ),
                        initialRoute: GetPlatform.isWeb
                            ? RouteHelper.getInitialRoute()
                            : RouteHelper.getSplashRoute(
                                widget.body,
                                widget.linkBody,
                              ),
                        getPages: RouteHelper.routes,
                        defaultTransition: Transition.topLevel,
                        transitionDuration: const Duration(milliseconds: 500),
                        builder: (BuildContext context, widget) {
                          return MediaQuery(
                            data: MediaQuery.of(
                              context,
                            ).copyWith(textScaler: const TextScaler.linear(1)),
                            child: Material(
                              child: SafeArea(
                                top: false,
                                bottom: GetPlatform.isAndroid,
                                child: Stack(
                                  children: [
                                    widget!,
                                    GetBuilder<SplashController>(
                                      builder: (splashController) {
                                        if (!splashController
                                                .savedCookiesData ||
                                            !splashController
                                                .getAcceptCookiesStatus(
                                                  splashController
                                                          .configModel
                                                          ?.cookiesText ??
                                                      "",
                                                )) {
                                          return ResponsiveHelper.isWeb()
                                              ? const Align(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: CookiesViewWidget(),
                                                )
                                              : const SizedBox();
                                        } else {
                                          return const SizedBox();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
              },
            );
          },
        );
      },
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
