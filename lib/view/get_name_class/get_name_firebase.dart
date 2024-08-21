import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../view_model/cubits/auth_cubit.dart';
import '../../view_model/utils/navigation.dart';
import '../../view_model/utils/shared_prefrance.dart';

class GetUserName extends StatelessWidget {
  final String documentId;

  const GetUserName({required this.documentId, super.key});

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    final authCubit = context.read<AuthCubit>();
    final credential = FirebaseAuth.instance.currentUser;

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(documentId).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return const Text("Document does not exist");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;

          return Column(
            children: [
              SizedBox(height: 30.h),
              const Divider(),
              ListTile(
                trailing: IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11.r)),
                          child: Container(
                            padding: EdgeInsets.all(22.r),
                            height: 200.h,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextField(
                                  controller: authCubit.editNameController,
                                  maxLength: 20,
                                  decoration: InputDecoration(
                                    hintText: "${data['name']}",
                                  ),
                                ),
                                SizedBox(height: 22.h),
                                TextButton(
                                  onPressed: () {
                                    if (credential != null) {
                                      users.doc(credential.uid).update({
                                        "name":
                                            authCubit.editNameController.text,
                                      });
                                      AppNavigation.navigateBack(context);
                                    }
                                  },
                                  child: Text(
                                    "Edit",
                                    style: TextStyle(fontSize: 22.sp),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.edit_rounded),
                  color: Colors.black,
                ),
                leading: const Icon(Icons.person),
                title: Text("Name : ${data['name']}"),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: Text("Email : ${data['email']}"),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: FutureBuilder<DateTime?>(
                  future: SharedPreferenceHelper.getUserCreatedAt(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text("Loading...");
                    } else if (snapshot.hasData && snapshot.data != null) {
                      final DateTime createdAt = snapshot.data!;
                      final String formattedDate =
                          DateFormat("MMMM d, y").format(createdAt);
                      return Text("Account created: $formattedDate");
                    } else {
                      return const Text("Account creation date not available");
                    }
                  },
                ),
              ),
            ],
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
