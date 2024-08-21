import 'package:chat_appp/view/profile_screen/profile_screen.dart';
import 'package:chat_appp/view/signin_screen/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../model/user_model.dart';
import '../../view_model/cubits/auth_cubit.dart';
import '../../view_model/cubits/app_cubit.dart';
import '../../view_model/utils/navigation.dart';
import '../chat_screen/chat_screen.dart';

class Home extends StatelessWidget {
  final UserModel? user;
  const Home({this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () async {
            if (AppCubit.get(context).search) {
              AppCubit.get(context).toggleSearch();
              return false;
            } else {
              return true;
            }
          },
          child: Scaffold(
            backgroundColor: const Color(0xFF553370),
            appBar: AppBar(
              backgroundColor: const Color(0xFF553370),
              elevation: 0,
              title: !AppCubit.get(context).search
                  ? const Text(
                      'ChatUp',
                      style: TextStyle(
                        color: Color(0xffc199cd),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : TextField(
                      controller: context.read<AuthCubit>().searchController,
                      decoration: InputDecoration(
                        hintText: 'Search User',
                        hintStyle: const TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 1.0,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                      ),
                      style: const TextStyle(color: Colors.black),
                      onChanged: (value) {
                        if (value.isEmpty) {
                          context.read<AuthCubit>().clearSearchResults();
                        } else {
                          context.read<AuthCubit>().searchUsersByName(value);
                        }
                      },
                    ),
              actions: [
                if (!AppCubit.get(context).search)
                  IconButton(
                    icon: const Icon(Icons.search, color: Color(0xffc199cd)),
                    onPressed: () {
                      AppCubit.get(context).toggleSearch();
                    },
                  ),
                PopupMenuButton<String>(
                  onSelected: (String result) async {
                    if (result == 'Profile') {
                      AppNavigation.navigateTo(
                        context,
                        ProfileScreen(user: user),
                      );
                    } else if (result == 'Logout') {
                      await AuthCubit.get(context).signOutFromFirebase();
                      AppNavigation.navigateAndRemoveUntil(
                          context, const SignInScreen());
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'Profile',
                      child: Text('Profile'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Logout',
                      child: Text('Logout'),
                    ),
                  ],
                  icon: Icon(
                    Icons.more_vert,
                    size: 26.sp,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            body: GestureDetector(
              onTap: () {
                if (AppCubit.get(context).search) {
                  AppCubit.get(context).toggleSearch();
                }
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: AppCubit.get(context).search
                          ? MediaQuery.of(context).size.height / 1.19
                          : MediaQuery.of(context).size.height / 1.15,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          if (AppCubit.get(context).search)
                            Expanded(
                              child: BlocBuilder<AuthCubit, AuthState>(
                                builder: (context, state) {
                                  if (state is SearchLoading) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (state is SearchFailed) {
                                    return Center(
                                      child: Text(state.errorMassage),
                                    );
                                  } else {
                                    return ListView.builder(
                                      itemCount: context
                                          .read<AuthCubit>()
                                          .searchResults
                                          .length,
                                      itemBuilder: (context, index) {
                                        UserModel user = context
                                            .read<AuthCubit>()
                                            .searchResults[index];
                                        return ListTile(
                                          leading: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                              user.profilePic ??
                                                  'https://www.pngall.com/wp-content/uploads/12/Avatar-Profile-PNG-HD-Image.png',
                                            ),
                                          ),
                                          title: Text(user.name ?? ''),
                                          onTap: () {
                                            AppNavigation.navigateTo(
                                              context,
                                              ChatScreen(user: user),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            )
                          else
                            Expanded(
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('chats')
                                    .where('users',
                                        arrayContains: FirebaseAuth
                                            .instance.currentUser?.uid)
                                    .orderBy('timestamp', descending: true)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  if (!snapshot.hasData ||
                                      snapshot.data!.docs.isEmpty) {
                                    return const Center(
                                      child: Text('No chats available'),
                                    );
                                  }
                                  var chatDocs = snapshot.data!.docs;
                                  return ListView.builder(
                                    itemCount: chatDocs.length,
                                    itemBuilder: (context, index) {
                                      var chat = chatDocs[index];
                                      var users =
                                          List<String>.from(chat['users']);
                                      var otherUserId = users.firstWhere(
                                          (userId) =>
                                              userId !=
                                              FirebaseAuth
                                                  .instance.currentUser?.uid,
                                          orElse: () => '');

                                      if (otherUserId.isEmpty) {
                                        return const Center(
                                          child: Text(
                                              'No other user in this chat'),
                                        );
                                      }

                                      return FutureBuilder<DocumentSnapshot>(
                                        future: FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(otherUserId)
                                            .get(),
                                        builder: (context, userSnapshot) {
                                          if (userSnapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          }
                                          if (!userSnapshot.hasData ||
                                              !userSnapshot.data!.exists) {
                                            return const Center(
                                              child:
                                                  Text('User data not found'),
                                            );
                                          }
                                          UserModel user = UserModel.fromJson(
                                              userSnapshot.data!.data()
                                                  as Map<String, dynamic>);
                                          return ListTile(
                                            leading: CircleAvatar(
                                              backgroundImage: NetworkImage(user
                                                      .profilePic ??
                                                  'assets/images.jpeg'), // عرض صورة افتراضية إذا لم تكن موجودة
                                            ),
                                            title: Text(user.name ?? ''),
                                            subtitle:
                                                Text(chat['lastMessage'] ?? ''),
                                            trailing: Text(
                                              DateFormat.Hm().format(
                                                (chat['timestamp'] as Timestamp)
                                                    .toDate()
                                                    .toLocal(),
                                              ),
                                            ),
                                            onTap: () {
                                              AppNavigation.navigateTo(
                                                context,
                                                ChatScreen(user: user),
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
