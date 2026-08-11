import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/widgets/product_item.dart';
import '../providers/products_provider.dart';

class Products extends StatefulWidget {
  final bool showFavs;

  const Products(this.showFavs, {super.key});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductsProvider>(context);
    final deviceWidth = MediaQuery.of(context).size.width;
    final crossAxisCount =
        deviceWidth > 900
            ? 4
            : deviceWidth > 600
            ? 3
            : 2;
    final loadedProducts =
        widget.showFavs ? productsData.favoriteItems : productsData.items;
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: loadedProducts.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemBuilder:
                (ctx, index) => ChangeNotifierProvider.value(
                  value: loadedProducts[index],
                  child: ProductItem(
                    // loadedProducts[index].id,
                    // loadedProducts[index].title,
                    // loadedProducts[index].imageUrl,
                  ),
                ),
          ),
        ),
      ],
    );
  }
}
