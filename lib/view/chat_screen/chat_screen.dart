import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../model/user_model.dart';
import '../../view_model/cubits/auth_cubit.dart';
import '../../view_model/utils/navigation.dart';
import '../home_screen/home.dart';
import '../message_bubble/message_bubble.dart';

class ChatScreen extends StatelessWidget {
  final UserModel? user;

  const ChatScreen({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF553370),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      AppNavigation.navigateAndRemoveUntil(
                          context, const Home());
                    },
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white),
                  ),
                  SizedBox(width: 90.w),
                  Text(
                    user?.name ?? "Chat",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: context.read<AuthCubit>().getMessages(user!),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          var messages = snapshot.data!.docs;
                          List<Widget> messageWidgets = [];
                          for (var message in messages) {
                            var messageData =
                                message.data() as Map<String, dynamic>;
                            var messageWidget = MessageBubble(
                              sender: messageData['senderId'],
                              text: messageData['message'],
                              isMe: FirebaseAuth.instance.currentUser!.uid ==
                                  messageData['senderId'],
                            );
                            messageWidgets.add(messageWidget);
                          }

                          return ListView(
                            reverse: true,
                            children: messageWidgets,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Material(
                              borderRadius: BorderRadius.circular(20),
                              elevation: 5,
                              child: TextField(
                                controller:
                                    context.read<AuthCubit>().messageController,
                                decoration: InputDecoration(
                                  hintText: 'Type a message',
                                  hintStyle:
                                      const TextStyle(color: Colors.black54),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                ),
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          CircleAvatar(
                            backgroundColor: Colors.blue,
                            radius: 24,
                            child: IconButton(
                              icon: const Icon(Icons.send, color: Colors.white),
                              iconSize: 25,
                              onPressed: () {
                                context.read<AuthCubit>().sendMessage(
                                    user!,
                                    context
                                        .read<AuthCubit>()
                                        .messageController
                                        .text);
                                context
                                    .read<AuthCubit>()
                                    .messageController
                                    .clear();
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
          ],
        ),
      ),
    );
  }
}
