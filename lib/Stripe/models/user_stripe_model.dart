import 'package:cloud_firestore/cloud_firestore.dart';

class UserStripeModel {
  String? name;
  String? email;
  String? stripeAccountId;
  bool verified;
  double? totalEarnings;
  String? uid;
  String? balance;
  DocumentReference? ref;
  UserStripeModel(
      {this.name,
      this.email,
      this.stripeAccountId,
      this.verified = false,
      this.totalEarnings,
      this.uid,
      this.balance,
      this.ref});

  factory UserStripeModel.fromMap(
      Map<String, dynamic> map, DocumentReference? docRef) {
    return UserStripeModel(
      name: map['name'],
      email: map['email'],
      stripeAccountId: map['stripeAccountId'],
      totalEarnings: map['totalEarnings'],
      verified: map['verified'] ?? false,
      uid: map['uid'],
      balance: map['balance'],
      ref: docRef,
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['stripeConnectId'] = this.stripeAccountId;
    data['totalEarnings'] = this.totalEarnings;
    data['uid'] = this.uid;
    data['balance'] = this.balance;
    return data;
  }
}
