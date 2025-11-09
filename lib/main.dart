import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goturey_marketplace/constants/enums/account_type.dart';
import 'package:goturey_marketplace/controllers/route_manager.dart';
import 'package:goturey_marketplace/providers/cart.dart';
import 'package:goturey_marketplace/providers/category.dart';
import 'package:goturey_marketplace/providers/order.dart';
import 'package:goturey_marketplace/providers/product.dart';
import 'package:goturey_marketplace/resources/theme_manager.dart';
import 'package:goturey_marketplace/views/auth/customer/customer_auth.dart';
import 'package:goturey_marketplace/views/customer/main_screen.dart';
import 'package:goturey_marketplace/views/vendor/entry_screen.dart';
import 'constants/color.dart';
import 'controllers/configs.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Config.fetchApiKeys(); // fetching api keys

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: accentColor,
        statusBarBrightness: Brightness.dark,
      ),
    );

    EasyLoading.instance
      ..backgroundColor = primaryColor
      ..progressColor = Colors.white
      ..loadingStyle = EasyLoadingStyle.light;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ProductData(),
        ),
        ChangeNotifierProvider(
          create: (context) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => OrderProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => CategoryData(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (BuildContext context, Widget? child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: getLightTheme(),
            title: 'Goturey Marketplace',
            home: child,
            routes: routes,
            builder: EasyLoading.init(),
          );
        },
        child: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.exists) {
                final accountType = snapshot.data!['accountType'];
                if (accountType == AccountType.customer.toString()) {
                  return const CustomerMainScreen(index: 0);
                } else {
                  return const VendorEntryScreen();
                }
              } else {
                return const CustomerAuthScreen();
              }
            },
          );
        } else {
          return const CustomerAuthScreen();
        }
      },
    );
  }
}