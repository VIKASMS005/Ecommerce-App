import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shopping_app/helpers/custom_route.dart';
import 'package:shopping_app/providers/places.dart';
import 'package:shopping_app/screens/manage_screen.dart';
import 'package:shopping_app/screens/manage_screens/account_info_screen.dart';
import 'package:shopping_app/screens/manage_screens/address_screen/add_place_screen.dart';
import 'package:shopping_app/screens/manage_screens/address_screen/place_list.dart';
import 'package:shopping_app/screens/order_success_screen.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart';
import './screens/auth_screen.dart';
import 'screens/manage_screens/edit_products_screen.dart';
import 'screens/manage_screens/orders_screen.dart';
import 'screens/manage_screens/user_products_screen.dart';
import './screens/product_details_screen.dart';
import './providers/products_provider.dart';
import './providers/cart.dart';
import './screens/cart_screen.dart';
import './providers/auth.dart';
import './screens/tabs_screen.dart';
import './providers/profile_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => Auth()),
        ChangeNotifierProvider(create: (ctx) => ProductsProvider()),
        ChangeNotifierProvider(create: (ctx) => Cart()),

        ChangeNotifierProvider(create: (ctx) => Orders()),
        ChangeNotifierProvider(create: (ctx) => Places()),
        ChangeNotifierProvider(create: (ctx) => ProfileProvider()),
      ],

      child: MaterialApp(
        title: 'ShopEzee',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.indigo,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: Colors.amber,
          ),
          useMaterial3: true,
          fontFamily: 'Lato',
          appBarTheme: AppBarTheme(
            titleTextStyle: TextStyle(
              fontFamily: 'Lato',
              fontSize: 25,
              //fontWeight: FontWeight.bold,
            ),
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
          pageTransitionsTheme: PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CustomPageTransitionBuilder(),
              TargetPlatform.iOS: CustomPageTransitionBuilder(),
            },
          ),
          textTheme: TextTheme(
            titleMedium: TextStyle(
              fontFamily: 'Lato',
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            titleSmall: TextStyle(
              fontFamily: 'Lato',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            displaySmall: TextStyle(fontFamily: 'Lato', fontSize: 15),
          ),
        ),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            if (snapshot.hasData) {
              return TabsScreen();
            }
            return AuthScreen();
          },
        ),
        routes: {
          ProductDetailsScreen.routeName: (ctx) => ProductDetailsScreen(),
          CartScreen.routeName: (ctx) => CartScreen(),
          OrdersScreen.routeName: (ctx) => OrdersScreen(),
          UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
          EditProductsScreen.routeName: (ctx) => EditProductsScreen(),
          TabsScreen.routeName: (ctx) => TabsScreen(),
          ManageScreen.routeName: (ctx) => ManageScreen(),
          AccountInfoScreen.routeName: (ctx) => AccountInfoScreen(),
          AddPlaceScreen.routeName: (ctx) => AddPlaceScreen(),
          PlaceList.routeName: (ctx) => PlaceList(),
          OrderSuccessScreen.routeName: (ctx) => OrderSuccessScreen(),
        },
      ),
    );
  }
}
