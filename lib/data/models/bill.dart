import 'food_order.dart';

/// Payment method for bills.
enum PaymentMethod { upi, cash }

/// A payment record on a bill.
class Payment {
  final PaymentMethod method;
  final int amount; // in rupees
  final DateTime paidAt;

  const Payment({
    required this.method,
    required this.amount,
    required this.paidAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        method: PaymentMethod.values.byName(json['method'] as String),
        amount: json['amount'] as int,
        paidAt: DateTime.parse(json['paidAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'method': method.name,
        'amount': amount,
        'paidAt': paidAt.toIso8601String(),
      };

  @override
  String toString() => 'Payment(${method.name}, ₹$amount)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Payment &&
          runtimeType == other.runtimeType &&
          method == other.method &&
          amount == other.amount &&
          paidAt == other.paidAt;

  @override
  int get hashCode => Object.hash(method, amount, paidAt);
}

/// A bill for a session (gaming + food).
class Bill {
  final String id;
  final String sessionId;
  final String playerId;
  final int gamingAmount; // in rupees
  final List<FoodOrder> items; // food/drink items
  final int total; // gamingAmount + sum of items
  final int paidAmount; // sum of payments
  final List<Payment> payments;
  final DateTime? closedAt; // null = open
  final String? closedBy; // staff member who closed it

  const Bill({
    required this.id,
    required this.sessionId,
    required this.playerId,
    required this.gamingAmount,
    this.items = const [],
    required this.total,
    this.paidAmount = 0,
    this.payments = const [],
    this.closedAt,
    this.closedBy,
  });

  factory Bill.fromJson(Map<String, dynamic> json) => Bill(
        id: json['id'] as String,
        sessionId: json['sessionId'] as String,
        playerId: json['playerId'] as String,
        gamingAmount: json['gamingAmount'] as int,
        items: (json['items'] as List? ?? [])
            .map((e) => FoodOrder.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: json['total'] as int,
        paidAmount: json['paidAmount'] as int? ?? 0,
        payments: (json['payments'] as List? ?? [])
            .map((e) => Payment.fromJson(e as Map<String, dynamic>))
            .toList(),
        closedAt: json['closedAt'] != null
            ? DateTime.parse(json['closedAt'] as String)
            : null,
        closedBy: json['closedBy'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sessionId': sessionId,
        'playerId': playerId,
        'gamingAmount': gamingAmount,
        'items': items.map((e) => e.toJson()).toList(),
        'total': total,
        'paidAmount': paidAmount,
        'payments': payments.map((e) => e.toJson()).toList(),
        'closedAt': closedAt?.toIso8601String(),
        'closedBy': closedBy,
      };

  /// Whether the bill is fully paid.
  bool get isPaid => paidAmount >= total;

  /// Whether the bill is closed (completed session).
  bool get isClosed => closedAt != null;

  /// Outstanding amount (unpaid).
  int get outstanding => (total - paidAmount).clamp(0, total);

  /// Total food amount on this bill.
  int get foodAmount => items.fold(0, (sum, item) => sum + item.lineTotal);

  /// Whether this bill has any food items.
  bool get hasFood => items.isNotEmpty;

  @override
  String toString() => 'Bill($id, session: $sessionId, total: ₹$total, paid: ₹$paidAmount)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bill && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}