import 'package:cloud_firestore/cloud_firestore.dart';

class Rules {
  final int nomralUser;
  final int oneStarUser;
  final int twoStarUser;
  final int threeStarUser;
  final int fourStarUser;
  final int fiveStarUser;
  final int nomralUserPostDeduction;
  final int oneStarUserPostDeduction;
  final int twoStarUserPostDeduction;
  final int threeStarUserPostDeduction;
  final int fourStarUserPostDeduction;
  final int fiveStarUserPostDeduction;
  final String applyType;
  final int gameoutCommission;
  final int mulificationpercentage;
  final int multificationFactor;
  final int postexpiryHours;

  Rules(
      {this.nomralUser,
      this.oneStarUser,
      this.twoStarUser,
      this.threeStarUser,
      this.fourStarUser,
      this.fiveStarUser,
      this.nomralUserPostDeduction,
      this.oneStarUserPostDeduction,
      this.twoStarUserPostDeduction,
      this.threeStarUserPostDeduction,
      this.fourStarUserPostDeduction,
      this.fiveStarUserPostDeduction,
      this.applyType,
      this.gameoutCommission,
      this.mulificationpercentage,
      this.multificationFactor,
      this.postexpiryHours});

  factory Rules.fromDocument(DocumentSnapshot doc) {
    return Rules(
        nomralUser: doc['nomralUser'],
        oneStarUser: doc['oneStarUser'],
        twoStarUser: doc['twoStarUser'],
        threeStarUser: doc['threeStarUser'],
        fourStarUser: doc['fourStarUser'],
        fiveStarUser: doc['fiveStarUser'],
        nomralUserPostDeduction: doc['nomralUserPostDeduction'],
        oneStarUserPostDeduction: doc['oneStarUserPostDeduction'],
        twoStarUserPostDeduction: doc['twoStarUserPostDeduction'],
        threeStarUserPostDeduction: doc['threeStarUserPostDeduction'],
        fourStarUserPostDeduction: doc['fourStarUserPostDeduction'],
        fiveStarUserPostDeduction: doc['fiveStarUserPostDeduction'],
        applyType: doc['applyType'],
        gameoutCommission: doc['gameoutCommission'],
        mulificationpercentage: doc['mulificationpercentage'],
        multificationFactor: doc['multificationFactor'],
        postexpiryHours: doc['postexpiryHours']);
  }
}
