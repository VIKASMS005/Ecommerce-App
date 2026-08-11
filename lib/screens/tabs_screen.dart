import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/manage_screen.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';

class TabsScreen extends StatefulWidget {
  final int selectedPageIndex;
  const TabsScreen({super.key, this.selectedPageIndex = 0});
  static const routeName = '/tabs';

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  late int selectedPageIndex;
  @override
  void initState() {
    super.initState();
    selectedPageIndex = widget.selectedPageIndex;
  }

  @override
  Widget build(BuildContext context) {
    List pages = [
      {'page': HomeScreen(), 'title': 'Home'},
      {'page': CartScreen(), 'title': 'Cart'},
      {'page': ManageScreen(), 'title': 'Manage'},
    ];
    void selectPage(int index) {
      setState(() {
        selectedPageIndex = index;
      });
    }

    return Scaffold(
      //appBar: AppBar(title: Text(pages[selectedPageIndex]['title'] as String)),
      body: pages[selectedPageIndex]['page'] as Widget,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).primaryColor,
        onTap: selectPage,
        currentIndex: selectedPageIndex,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Colors.white,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Consumer<Cart>(
              builder:
                  (_, cart, ch) =>
                      Badge(label: Text(cart.itemCount.toString()), child: ch),
              child: Icon(Icons.shopping_cart, size: 30),
            ),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts, size: 30),
            label: 'You',
          ),
        ],
      ),
    );
  }
}
