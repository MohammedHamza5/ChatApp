import 'package:chat_appp/view/home_screen/home.dart';
import 'package:chat_appp/view/signin_screen/signin_screen.dart';
import 'package:chat_appp/view_model/cubits/app_cubit.dart';
import 'package:chat_appp/view_model/cubits/auth_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => AuthCubit(),
            ),
            BlocProvider(
              create: (context) => AppCubit(),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Text("Loading..."),
                  );
                } else if (snapshot.hasError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Something went wrong"),
                    ),
                  );
                  return const SizedBox();
                } else if (snapshot.hasData) {
                  return const Home();
                } else {
                  return const SignInScreen();
                }
              },
            ),
          ),
        );
      },
    );
  }
}
