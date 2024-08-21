import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../view_model/cubits/auth_cubit.dart';
import '../../view_model/utils/navigation.dart';
import '../signin_screen/signin_screen.dart';

class SignUp extends StatelessWidget {
  SignUp({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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
                    'SignUp',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 24.sp),
                  ),
                  Text(
                    'Create a new account',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18.sp,
                      color: const Color(0xFFbbb0ff),
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
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
                        height: 450.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Form(
                          key: _formKey,
                          child: BlocConsumer<AuthCubit, AuthState>(
                            listener: (context, state) {
                              if (state is RegisterFailed) {
                                final snackBar = SnackBar(
                                  content: Text(state.errorMassage),
                                  backgroundColor: Colors.red,
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              } else if (state is RegisterSuccess) {
                                // Navigate to another screen or show success message
                                AppNavigation.navigateTo(
                                    context, const SignInScreen());
                              } else if (state is EmailNotVerified) {
                                final snackBar = SnackBar(
                                  content: Text(state.errorMassage),
                                  backgroundColor: Colors.orange,
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
                            },
                            builder: (context, state) {
                              return SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text(
                                        textAlign: TextAlign.start,
                                        'Name',
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
                                          AuthCubit.get(context).nameController,
                                      keyboardType: TextInputType.text,
                                      style:
                                          const TextStyle(color: Colors.black),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.person_outlined,
                                          color: Color(0xFF7f30fe),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your name';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(
                                      height: 18.h,
                                    ),
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
                                      controller: AuthCubit.get(context)
                                          .emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      style:
                                          const TextStyle(color: Colors.black),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.mail_outline,
                                          color: Color(0xFF7f30fe),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your email';
                                        }
                                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                            .hasMatch(value)) {
                                          return 'Please enter a valid email address';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(
                                      height: 18.h,
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
                                      style:
                                          const TextStyle(color: Colors.black),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.password,
                                          color: Color(0xFF7f30fe),
                                        ),
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            AuthCubit.get(context).hidePassword();
                                          },
                                          icon:
                                           Icon(AuthCubit.get(context).isHidPass ? Icons.visibility_off : Icons.visibility),
                                        ),
                                      ),
                                      // autovalidateMode: AutovalidateMode.onUserInteraction,
                                      onTapOutside: (_) {
                                        FocusManager.instance.primaryFocus!.unfocus();
                                      },
                                      obscuringCharacter: '*',
                                      obscureText: AuthCubit.get(context).isHidPass,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your password';
                                        }
                                        if (value.length < 8) {
                                          return 'Password must be at least 8 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(
                                      height: 18.h,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text(
                                        textAlign: TextAlign.start,
                                        'Confirm Password',
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
                                          .confirmPasswordController,
                                      keyboardType: TextInputType.text,
                                      style:
                                          const TextStyle(color: Colors.black),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.password,
                                          color: Color(0xFF7f30fe),
                                        ),
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            AuthCubit.get(context).hidePassword();
                                          },
                                          icon:
                                          Icon(AuthCubit.get(context).isHidPass ? Icons.visibility_off : Icons.visibility),
                                        ),
                                      ),
                                      obscureText: AuthCubit.get(context).isHidPass ? false : true,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please confirm your password';
                                        }
                                        if (value !=
                                            AuthCubit.get(context)
                                                .passwordController
                                                .text) {
                                          return 'Passwords do not match';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(
                                      height: 50.h,
                                    ),
                                    Center(
                                      child: Material(
                                        elevation: 5,
                                        borderRadius: BorderRadius.circular(12),
                                        child: state is RegisterLoading ||
                                                state is VerificationLoading
                                            ? const CircularProgressIndicator()
                                            : ElevatedButton(
                                                onPressed: () async {
                                                  if (_formKey.currentState!
                                                      .validate()) {
                                                    await AuthCubit.get(context)
                                                        .registerFromFirebase();
                                                    await AuthCubit.get(context)
                                                        .checkEmailVerification();
                                                  } else {
                                                    const snackBar = SnackBar(
                                                      content: Text(
                                                          'Please verify your email before continuing.'),
                                                      backgroundColor:
                                                          Colors.orange,
                                                    );
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(snackBar);
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  backgroundColor:
                                                      const Color(0xFF7f30fe),
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 11.h,
                                                    horizontal: 80.w,
                                                  ),
                                                ),
                                                child: Text(
                                                  'SIGN UP',
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
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have account?",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          fontSize: 16.sp,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          AppNavigation.navigateAndRemoveUntil(
                              context, const SignInScreen());
                        },
                        child: Text(
                          "SignIn",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 17.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
