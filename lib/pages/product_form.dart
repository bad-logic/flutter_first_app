import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './../widgets/helpers/ensure_visible.dart';
import './../models/product.dart';
import 'package:scoped_model/scoped_model.dart';
import './../scoped-models/main.dart';

class ProductFormPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProductFormPageState();
  }
}

class _ProductFormPageState extends State<ProductFormPage> {
  final Map<String, dynamic> _product = {'imageUrl': 'assets/food.jpg'};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final titleFocusNode = FocusNode();
  final descriptionFocusNode = FocusNode();
  final priceFocusNode = FocusNode();

  Widget _buildTitleTextFormField({String title}) {
    return EnsureVisibleWhenFocused(
      focusNode: titleFocusNode,
      child: TextFormField(
        focusNode: titleFocusNode, // also tell we are using our own focusNode
        decoration: InputDecoration(labelText: 'Product Title'),
        initialValue: title == null ? '' : title,
        validator: (String value) {
          if (value.isEmpty || value.length < 5) {
            return 'Title is Required and contain at least five characters'; // error message
          }
          return null; // validation succeeded
        },
        onSaved: (String value) {
          // no need to call setState because we don't need to re-render the component
          _product['title'] = value;
        },
      ),
    );
  }

  Widget _buildPriceTextFormField({double price}) {
    return EnsureVisibleWhenFocused(
      focusNode: priceFocusNode,
      child: TextFormField(
        focusNode: priceFocusNode,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: 'Product Price'),
        initialValue: price == null ? '' : price.toString(),
        validator: (String value) {
          if (value.isEmpty ||
              !RegExp(r'^(?:[1-9]\d*|0)?(?:[.,]\d+)?$').hasMatch(value)) {
            //also allows 9,99 numbers
            return 'Price is Required and must be a number'; // error message
          }
          return null; // validation succeeded
        },
        onSaved: (String value) {
          _product['price'] =
              double.parse(value.replaceFirst(RegExp(r','), '.'));
        },
      ),
    );
  }

  Widget _buildDescriptionTextFormField({String description}) {
    return EnsureVisibleWhenFocused(
      focusNode: descriptionFocusNode,
      child: TextFormField(
        maxLines: 5,
        focusNode: descriptionFocusNode,
        decoration: InputDecoration(labelText: 'Product Description'),
        initialValue: description == null ? '' : description,
        validator: (String value) {
          if (value.isEmpty || value.length < 5) {
            return 'Description is Required and contain at least five characters'; // error message
          }
          return null; // validation succeeded
        },
        onSaved: (String value) {
          _product['description'] = value;
        },
      ),
    );
  }

  void _formSubmit(
      {Function saveProduct, Product product, Function unselectProduct}) {
    if (!_formKey.currentState.validate()) {
      //validator function runs at this point and then only shows error
      return; // in case of false donot run below code
    }
    _formKey.currentState
        .save(); // when we call the save method on the state returned by the global key,
    // the onSaved() methods are fired on each Form Fields
    saveProduct(_product['title'], _product['price'], _product['description'],
        _product['imageUrl']);
    Navigator.pushReplacementNamed(
            context, // pressing back button will not navigate to this page
            '/products')
        .then((value) => unselectProduct()); // incase the producted is selected eg: while updating product
    // also error in case of adding product if we don't pass the unselectProduct function to this build method
    // no harm in setting selectedProductIndex to null in case of adding product since it is already null beforehand
  }

  Widget _buildPageContent(
      {Product product, Function saveProduct, Function unselectProduct}) {
    final double deviceWidth =
        MediaQuery.of(context).size.width; // getting the device current width

    final double finalDeviceWidth =
        deviceWidth > 768.0 ? 450.0 : deviceWidth * 0.95;
    final double finalPadding = deviceWidth - finalDeviceWidth;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: ListView(
            // listview items always take the full available space by default
            padding: EdgeInsets.symmetric(
              horizontal: finalPadding / 2,
            ),
            // adding padding restricts the listView from using full width
            children: <Widget>[
              _buildTitleTextFormField(
                  title: product == null ? null : product.title),
              _buildDescriptionTextFormField(
                  description: product == null ? null : product.description),
              _buildPriceTextFormField(
                  price: product == null ? null : product.price),
              SizedBox(
                height: 10.0,
              ), // doesnot render anything just occupies space
              RaisedButton(
                child: Text('Save'),
                textColor: Colors.white,
                onPressed: () {
                  _formSubmit(
                      saveProduct: saveProduct,
                      product: product,
                      unselectProduct: unselectProduct);
                },
              ),
//          Center(
//            child: GestureDetector(
//              onTap: (){
//                widget.addProduct(_product);
//              Navigator.pushReplacementNamed(context, '/products');
//              },
//              child: Container(
//                color: Colors.green,
//                padding: EdgeInsets.all(10.0),
//                child: Text('Save'),
//              ),
//            ),
//          ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        int index = model.selectedProductIndex;
        return model.selectedProductIndex == null // case while adding product
            ? _buildPageContent(
                saveProduct: model.addProduct,
                unselectProduct: model.unselectProduct)
            : Scaffold(
                // for editing product we need to return scaffold because adding product is inside the tab that already
                // is inside page but while editing we push to the new page but that page won't have body only the form fields
                // which won't load because it has no body. so return it inside the scaffold. so we are just reusing the form part
                appBar: AppBar(
                  title: Text('Edit Product'),
                ),
                body: _buildPageContent(
                    saveProduct: model.updateProduct,
                    product: model.products[index],
                    unselectProduct:
                        model.unselectProduct), // for editing product
              );
      },
    );
  }
}
