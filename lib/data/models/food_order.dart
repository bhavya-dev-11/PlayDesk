/// A food/drink item ordered on a bill.
class FoodOrder {
  final String itemName;
  final int qty;
  final int unitPrice; // in rupees
  final DateTime orderedAt;

  const FoodOrder({
    required this.itemName,
    required this.qty,
    required this.unitPrice,
    required this.orderedAt,
  });

  factory FoodOrder.fromJson(Map<String, dynamic> json) => FoodOrder(
        itemName: json['itemName'] as String,
        qty: json['qty'] as int,
        unitPrice: json['unitPrice'] as int,
        orderedAt: DateTime.parse(json['orderedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'itemName': itemName,
        'qty': qty,
        'unitPrice': unitPrice,
        'orderedAt': orderedAt.toIso8601String(),
      };

  /// Line total for this item (qty * unitPrice).
  int get lineTotal => qty * unitPrice;

  @override
  String toString() => 'FoodOrder($itemName x$qty @ ₹$unitPrice)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodOrder &&
          runtimeType == other.runtimeType &&
          itemName == other.itemName &&
          qty == other.qty &&
          unitPrice == other.unitPrice &&
          orderedAt == other.orderedAt;

  @override
  int get hashCode => Object.hash(itemName, qty, unitPrice, orderedAt);
}