import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? uid;
  String? name;
  String? email;
  String? profilePic;
  String? nameLowerCase;
  DateTime? createdAt;

  UserModel({
    this.createdAt,
    this.nameLowerCase,
    this.profilePic,
    this.uid,
    this.email,
    this.name,
  });

  // تحويل كائن UserModel إلى صيغة يمكن إرسالها إلى Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'profilePic': profilePic,
      'name_lowercase': name?.toLowerCase(),
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }

  // تحويل بيانات Firestore إلى كائن UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
      name: json['name'],
      profilePic: json['profilePic'],
      nameLowerCase: json['name_lowercase'],
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
