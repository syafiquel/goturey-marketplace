class Cart {
  final String cartId;
  final String prodId;
  final String prodName;
  final String prodImg;
  int quantity;
  final String vendorId;
  final DateTime date;
  final String prodSize;
  final double price;

  Cart({
    required this.cartId,
    required this.prodId,
    required this.prodName,
    required this.prodImg,
    required this.vendorId,
    required this.quantity,
    required this.prodSize,
    required this.date,
    required this.price,
  });

  void increaseQuantity() => quantity++;

  void decreaseQuantity() => quantity--;

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      cartId: json['cartId'],
      prodId: json['prodId'],
      prodName: json['prodName'],
      prodImg: json['prodImg'],
      vendorId: json['vendorId'],
      quantity: json['quantity'],
      prodSize: json['prodSize'],
      date: DateTime.parse(json['date']),
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cartId': cartId,
      'prodId': prodId,
      'prodName': prodName,
      'prodImg': prodImg,
      'vendorId': vendorId,
      'quantity': quantity,
      'prodSize': prodSize,
      'date': date.toIso8601String(),
      'price': price,
    };
  }
}
