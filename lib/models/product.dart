import 'package:flutter/material.dart';

class Product {
  final String title, description, imageUrl;
  final double price;
  final bool isFavourite;
  final String userEmail;
  final String userId;

  Product(
      {@required this.title,
      @required this.description,
      @required this.price,
      @required this.imageUrl,
      @required this.userEmail,
      @required this.userId,
      this.isFavourite = false});
}
