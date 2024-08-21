import 'package:chat_appp/view/home_screen/home.dart';
import 'package:chat_appp/view/reset_password_screen/reset_pass_screen.dart';
import 'package:chat_appp/view_model/cubits/auth_cubit.dart';
import 'package:chat_appp/view_model/utils/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../signup_screen/signup.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: 200.h,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7f30fe), Colors.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.elliptical(
                    100.w,
                    60.h,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Column(
                children: [
                  Text(
                    'SignIn',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 24.sp),
                  ),
                  Text(
                    'Login to your account',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18.sp,
                      color: const Color(0xFFbbb0ff),
                    ),
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                  Container(
                    margin:
                        EdgeInsets.symmetric(vertical: 20.w, horizontal: 20.h),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      elevation: 5,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            vertical: 20.h, horizontal: 20.w),
                        height: 350.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Form(
                          key: formKey,
                          child: BlocConsumer<AuthCubit, AuthState>(
                            listener: (context, state) {
                              if (state is LoginFailed) {
                                // عرض رسالة الخطأ في حال فشل تسجيل الدخول
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(state.errorMassage),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            builder: (context, state) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      textAlign: TextAlign.start,
                                      'Email',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8.h,
                                  ),
                                  TextFormField(
                                    controller:
                                        AuthCubit.get(context).emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(color: Colors.black),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.mail_outline,
                                        color: Color(0xFF7f30fe),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                          .hasMatch(value)) {
                                        return 'Please enter a valid email address';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: 30.h,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      'Password',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8.h,
                                  ),
                                  TextFormField(
                                    controller: AuthCubit.get(context)
                                        .passwordController,
                                    style: const TextStyle(color: Colors.black),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.password,
                                        color: Color(0xFF7f30fe),
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          AuthCubit.get(context).hidePassword();

                                        },
                                        icon: Icon(
                                          AuthCubit.get(context).isHidPass
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                      ),
                                    ),
                                    obscureText:
                                        AuthCubit.get(context).isHidPass,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 8.h),
                                  Container(
                                    alignment: Alignment.bottomRight,
                                    child: TextButton(
                                      onPressed: () {
                                        AppNavigation.navigateTo(
                                            context, const ResetPassword());
                                      },
                                      child: Text(
                                        'Forgot Password?',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.blue,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 60.h,
                                  ),
                                  Center(
                                    child: Material(
                                      elevation: 5,
                                      borderRadius: BorderRadius.circular(12),
                                      child: state is LoginLoading
                                          ? const CircularProgressIndicator()
                                          : ElevatedButton(
                                              onPressed: () async {
                                                if (formKey.currentState!
                                                    .validate()) {
                                                  await AuthCubit.get(context)
                                                      .signInFromFirebase();

                                                  if (context
                                                      .read<AuthCubit>()
                                                      .state is LoginSuccess) {
                                                    final user = FirebaseAuth
                                                        .instance.currentUser;

                                                    if (user != null &&
                                                        user.emailVerified) {
                                                      AppNavigation
                                                          .navigateAndRemoveUntil(
                                                              context,
                                                              const Home());
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'Please verify your email before logging in.'),
                                                          backgroundColor:
                                                              Colors.red,
                                                        ),
                                                      );
                                                    }
                                                  }
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12), // Border radius
                                                ),
                                                backgroundColor:
                                                    const Color(0xFF7f30fe),
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 11.h,
                                                  horizontal: 80.w,
                                                ),
                                              ),
                                              child: Text(
                                                'SignIn',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18.sp,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          fontSize: 16.sp,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          AppNavigation.navigateTo(context, SignUp());
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 17.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // SizedBox(height: 30.h),
                      //! Google Sign-In Button      
                  // SizedBox(
                  //   width: 200.w,
                  //   child: ElevatedButton.icon(
                  //     onPressed: () async {
                  //       // هنا تقوم بإضافة منطق تسجيل الدخول باستخدام Google
                  //       await AuthCubit.get(context).signInWithGoogle();
                  //       if (FirebaseAuth.instance.currentUser != null) {
                  //         AppNavigation.navigateAndRemoveUntil(
                  //             context, const Home());
                  //       }
                  //     },
                  //     icon: Image.asset(
                  //       'assets/icons/google_icon.png',
                  //       height: 24.h,
                  //       width: 24.w,
                  //     ),
                  //     label: Text(
                  //       'Sign in with Google',
                  //       style: TextStyle(
                  //         fontWeight: FontWeight.bold,
                  //         fontSize: 16.sp,
                  //       ),
                  //     ),
                  //     style: ElevatedButton.styleFrom(
                  //       foregroundColor: Colors.black,
                  //       backgroundColor: const Color.fromARGB(255, 221, 5, 5),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(12),
                  //       ),
                  //       padding: EdgeInsets.symmetric(vertical: 12.h),
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: 20.sp,
                  // ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
