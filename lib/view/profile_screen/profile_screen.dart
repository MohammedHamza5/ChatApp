import 'package:chat_appp/view_model/cubits/auth_cubit.dart';
import 'package:chat_appp/view_model/utils/navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../model/user_model.dart';
import '../get_name_class/get_name_firebase.dart';
import '../signin_screen/signin_screen.dart';

class ProfileScreen extends StatelessWidget {
  final UserModel? user;
  final User? credential =
      FirebaseAuth.instance.currentUser; // Use User type here

  ProfileScreen({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
        ),
        backgroundColor: const Color(0xFF3a2144),
      ),
      body: SingleChildScrollView(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 30.h),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.grey[800],
                      backgroundImage: AuthCubit.get(context).imgPath != null
                          ? FileImage(AuthCubit.get(context).imgPath!)
                          : AuthCubit.get(context).currentUser?.profilePic !=
                                  null
                              ? NetworkImage(AuthCubit.get(context)
                                  .currentUser!
                                  .profilePic!)
                              : null,
                      child: AuthCubit.get(context).imgPath == null &&
                              AuthCubit.get(context).currentUser?.profilePic ==
                                  null
                          ? Icon(
                              Icons.person,
                              size: 50.sp,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.grey[800],
                        radius: 18,
                        child: IconButton(
                          icon: Icon(
                            Icons.edit,
                            size: 18.sp,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            await AuthCubit.get(context).pickImage();
                            if (AuthCubit.get(context).imgPath != null) {
                              await AuthCubit.get(context)
                                  .uploadImageToFireStore();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GetUserName(documentId: credential?.uid ?? ''),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Confirm deletion action with user
                    final confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Deletion'),
                        content: const Text(
                            'Are you sure you want to delete your account?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirm) {
                      await credential?.delete();
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(credential?.uid)
                          .delete();
                      AppNavigation.navigateAndRemoveUntil(
                          context, const SignInScreen());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                  ),
                  child: const Text(
                    'Delete Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
