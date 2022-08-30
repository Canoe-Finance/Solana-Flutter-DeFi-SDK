import 'package:dating_app/helpers/app_localizations.dart';
import 'package:dating_app/models/app_model.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:dating_app/widgets/my_circular_progress.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:scoped_model/scoped_model.dart';

class StoreProducts extends StatefulWidget {
  final Widget icon;
  final Color priceColor;

  const StoreProducts({Key? key, required this.icon, required this.priceColor}) : super(key: key);

  @override
  _StoreProductsState createState() => _StoreProductsState();
}

class _StoreProductsState extends State<StoreProducts> {
  // Variables
  bool _storeIsAvailable = false;
  List<ProductDetails>? _products;
  late AppLocalizations _i18n;

  @override
  void initState() {
    super.initState();

    // Check google play services
    InAppPurchaseConnection.instance.isAvailable().then((result) {
      if (mounted) {
        setState(() {
          _storeIsAvailable =
              result; // if false the store can not be reached or accessed
        });
      }
    });

    // Get product subscriptions from google play store / apple store
    InAppPurchaseConnection.instance
        .queryProductDetails(AppModel().appInfo.subscriptionIds.toSet())
        .then((ProductDetailsResponse response) {

      /// Update UI
      if (mounted) {
        setState(() {
        // Get product list
        _products = response.productDetails;
        // Check result
        if (_products!.isNotEmpty) {
          // Order price by ASC
          _products!.sort((a, b) {
            // Get int prices to be ordered
            final priceA =
                int.parse(a.price.replaceAll(RegExp(r'[^0-9]'), ''));
            final priceB =
                int.parse(b.price.replaceAll(RegExp(r'[^0-9]'), ''));
            // ASC order
            return priceA.compareTo(priceB);
          });
        }
      });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Init
    _i18n = AppLocalizations.of(context);

    return _storeIsAvailable ? _showProducts() : _storeNotAvailable();
  }

  Widget _showProducts() {
    if (_products == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const MyCircularProgress(),
              const SizedBox(height: 5),
              Text(_i18n.translate("processing"),
                  style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
              Text(_i18n.translate("please_wait"),
                  style: const TextStyle(fontSize: 18), textAlign: TextAlign.center)
            ],
          ),
        ),
      );
    } else if (_products!.isNotEmpty) {
      // Show Subscriptions
      return ScopedModelDescendant<UserModel>(
          builder: (context, child, userModel) {
        return Column(
            children: _products!.map<Widget>((item) {
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              enabled: userModel.activeVipId == item.id ? false : true,
              leading: widget.icon,
              title: Text(
                // Android only - remove the app name from title
                item.title.replaceAll(RegExp(r"\([^]*\)", caseSensitive: false), ''),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text(item.price,
                  style: TextStyle(
                      fontSize: 19,
                      color: widget.priceColor,
                      fontWeight: FontWeight.bold)),
              trailing: ElevatedButton(
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          const EdgeInsets.all(8)),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          userModel.activeVipId == item.id
                              ? Colors.grey
                              : widget.priceColor),
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ))),
                  child: userModel.activeVipId == item.id
                      ? Text(_i18n.translate("ACTIVE"),
                          style: const TextStyle(color: Colors.white))
                      : Text(_i18n.translate("SUBSCRIBE"),
                          style: const TextStyle(color: Colors.white)),
                  onPressed: userModel.activeVipId == item.id
                      ? null
                      : () async {
                          // Purchase parameters
                          final pParam = PurchaseParam(
                            productDetails: item,
                          );

                          /// Subscribe
                          InAppPurchaseConnection.instance
                              .buyNonConsumable(purchaseParam: pParam);
                        }),
            ),
          );
        }).toList());
      });
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.search,
                  size: 80, color: Theme.of(context).primaryColor),
              Text(_i18n.translate("no_products_or_subscriptions"),
                  style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
  }

  Widget _storeNotAvailable() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.error_outline,
              size: 80, color: Theme.of(context).primaryColor),
          Text(_i18n.translate("oops_an_error_has_occurred"),
              style: const TextStyle(fontSize: 18.0), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
