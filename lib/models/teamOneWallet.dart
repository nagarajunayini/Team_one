import 'package:cloud_firestore/cloud_firestore.dart';

class TeamOneWallet {
  final String userId;
  final int walletAmount;

  TeamOneWallet({
    this.userId,
    this.walletAmount,
  });

  factory TeamOneWallet.fromDocument(DocumentSnapshot doc) {
    return TeamOneWallet(
        userId: doc['userId'], walletAmount: doc['walletAmount']);
  }
}
