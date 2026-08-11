import 'package:flutter/material.dart';
import 'package:shopping_app/providers/profile_provider.dart';
import 'package:shopping_app/screens/manage_screens/address_screen/place_list.dart';
// import 'package:shopping_app/helpers/custom_route.dart';
import '../screens/manage_screens/account_info_screen.dart';
import '../screens/manage_screens/orders_screen.dart';
import 'manage_screens/user_products_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import '../providers/places.dart';
import '../widgets/profile_pic.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({super.key});
  static const routeName = '/managescreen';

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

Widget buildListTile(Icon icon, String text, Function onPressed) {
  return ListTile(
    leading: icon,
    titleAlignment: ListTileTitleAlignment.center,
    title: Text(text),
    onTap: () {
      onPressed();
    },
  );
}

Widget buildTextButton(String text, Function onPressed) {
  return TextButton(
    onPressed: () {
      onPressed();
    },
    child: Text(text),
  );
}

class _ManageScreenState extends State<ManageScreen> {
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      Provider.of<ProfileProvider>(context, listen: false).fetchAndSetPic();
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('You')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Center(child: ProfilePic()),
                SizedBox(height: 10),
                Card(
                  elevation: 10,
                  margin: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadowColor: Colors.black54,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        buildListTile(
                          Icon(Icons.person, size: 30),
                          'Account',
                          () {
                            Navigator.of(
                              context,
                            ).pushNamed(AccountInfoScreen.routeName);
                          },
                        ),
                        buildListTile(
                          Icon(Icons.receipt_long, size: 30),
                          'Orders',
                          () {
                            Navigator.of(
                              context,
                            ).pushNamed(OrdersScreen.routeName);
                          },
                        ),
                        buildListTile(
                          Icon(Icons.inventory, size: 30),
                          'Manage Products',
                          () {
                            Navigator.of(
                              context,
                            ).pushNamed(UserProductsScreen.routeName);
                          },
                        ),
                        buildListTile(
                          Icon(Icons.location_on_rounded, size: 30),
                          'Address',
                          () {
                            Navigator.of(
                              context,
                            ).pushNamed(PlaceList.routeName);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Card(
                  elevation: 10,
                  margin: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadowColor: Colors.black,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        buildListTile(
                          Icon(Icons.logout, size: 30),
                          'Logout',
                          () {
                            showDialog(
                              context: context,
                              builder:
                                  (ctx) => AlertDialog(
                                    title: Text(
                                      'Do you really want to Logout??',
                                    ),
                                    actions: [
                                      buildTextButton('Yes', () {
                                        Navigator.of(ctx).pop();
                                        Provider.of<Auth>(
                                          context,
                                          listen: false,
                                        ).logout();
                                      }),
                                      buildTextButton('No', () {
                                        Navigator.of(ctx).pop();
                                      }),
                                    ],
                                  ),
                            );
                          },
                        ),
                        buildListTile(
                          Icon(Icons.delete_forever, size: 30),
                          'Delete',
                          () {
                            showDialog(
                              context: context,
                              builder:
                                  (ctx) => AlertDialog(
                                    title: Text('Are you Sure??'),
                                    content: Text(
                                      'Account will be delete permanently.',
                                    ),
                                    actions: [
                                      buildTextButton('Yes', () {
                                        Navigator.of(ctx).pop();
                                        Provider.of<Auth>(
                                          context,
                                          listen: false,
                                        ).delete();
                                        Provider.of<ProfileProvider>(
                                          context,
                                          listen: false,
                                        ).clearProfile();
                                        Provider.of<Places>(
                                          context,
                                          listen: false,
                                        ).clearAllAddress();
                                      }),
                                      buildTextButton('No', () {
                                        Navigator.of(ctx).pop();
                                      }),
                                    ],
                                  ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
