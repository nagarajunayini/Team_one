import 'package:cloud_firestore/cloud_firestore.dart';

class Wallet {
  final String userId;
  final int amount;
  final String transactionType;
  final String reason;

  Wallet({
    this.userId,
    this.amount,
    this.transactionType,
    this.reason
  });

  factory Wallet.fromDocument(DocumentSnapshot doc) {
    return Wallet(
        userId: doc['userId'], 
        amount: doc['amount'],
        transactionType: doc['transactionType'],
        reason:doc['reason']
        );
  }
}