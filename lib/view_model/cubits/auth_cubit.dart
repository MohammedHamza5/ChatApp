import 'dart:io';
import 'dart:math';

import 'package:chat_appp/model/user_model.dart';
import 'package:chat_appp/view_model/utils/shared_prefrance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' show basename;
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  static AuthCubit get(context) => BlocProvider.of(context);
  List<UserModel> searchResults = [];
  UserModel userModel = UserModel();
  final ImagePicker picker = ImagePicker();
  XFile? image;
  String? imgName;
  File? imgPath;
  String? downloadUrl;
  UserModel? currentUser;
  UserCredential? credential;
  bool search = false;
  bool isHidPass = true;

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  TextEditingController editNameController = TextEditingController();
  TextEditingController resetPasswordController = TextEditingController();

  void hidePassword() {
    isHidPass = !isHidPass;
    emit(AppPasswordVisibilityChanged());
  }
  Future<UserModel?> getUserFromPreferences() async {
    try {
      String? uid = await SharedPreferenceHelper.getUserId();
      String? email = await SharedPreferenceHelper.getUserEmail();
      String? name = await SharedPreferenceHelper.getUserName();
      String? profilePic = await SharedPreferenceHelper.getUserPic();
      if (uid != null && email != null && name != null) {
        return UserModel(
          uid: uid,
          email: email,
          name: name,
          profilePic: profilePic,
        );
      }
      return null;
    } catch (e) {
      emit(AuthFailed(errorMassage: 'Failed to get user data: $e'));
      return null;
    }
  }
  Future<void> registerFromFirebase() async {
    emit(RegisterLoading());
    try {
      final UserCredential credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      DateTime? createdAt = credential.user?.metadata.creationTime;
      emit(RegisterSuccess());
      await sendEmailVerification();
      userModel = UserModel(
        uid: credential.user?.uid,
        email: credential.user?.email,
        name: nameController.text,
        nameLowerCase: nameController.text.toLowerCase(),
        createdAt: credential.user?.metadata.creationTime,
      );
      await saveUser(userModel);
      await saveUserDataToPreferences(userModel);
      currentUser = userModel;
      await checkEmailVerification();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        emit(
            RegisterFailed(errorMassage: 'The password provided is too weak.'));
      } else if (e.code == 'email-already-in-use') {
        emit(RegisterFailed(
            errorMassage: 'The account already exists for that email.'));
      } else {
        emit(RegisterFailed(
            errorMassage: 'An error occurred. Please try again.'));
      }
    } catch (e) {
      emit(RegisterFailed(errorMassage: 'Something went wrong on Register.'));
    }
  }
  Future<void> sendEmailVerification() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        emit(EmailVerificationSent());
      } else if (user != null && user.emailVerified) {
        emit(EmailAlreadyVerified());
      } else {
        emit(EmailVerificationFailed("No user is signed in"));
      }
    } catch (e) {
      emit(EmailVerificationFailed("Failed to send verification email: $e"));
    }
  }
  Future<void> checkEmailVerification() async {
    emit(VerificationLoading());
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      if (user != null && user.emailVerified) {
        emit(LoginSuccess());
      } else {
        emit(EmailNotVerified(
            errorMassage: "Please verify your email before continuing."));
      }
    } catch (e) {
      emit(VerificationFailed(errorMassage: "Failed to verify email: $e"));
    }
  }
  Future<void> saveUser(UserModel user) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(user.toMap());
      emit(RegisterSuccess());
    } catch (e) {
      emit(RegisterFailed(errorMassage: 'Failed to save user: $e'));
    }
  }
  Future<void> searchUsersByName(String name) async {
    try {
      String lowerCaseName = name.toLowerCase();
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name_lowercase', isGreaterThanOrEqualTo: lowerCaseName)
          .where('name_lowercase', isLessThanOrEqualTo: '$lowerCaseName\uf8ff')
          .get();

      searchResults = snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      emit(SearchSuccess());
    } catch (e) {
      emit(SearchFailed(errorMassage: 'Failed to search users: $e'));
    }
  }
  Future<void> sendMessage(UserModel receiver, String message) async {
    try {
      String chatId =
          getChatId(FirebaseAuth.instance.currentUser!.uid, receiver.uid!);
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': FirebaseAuth.instance.currentUser!.uid,
        'receiverId': receiver.uid,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
      await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
        'lastMessage': message,
        'timestamp': FieldValue.serverTimestamp(),
        'users': [FirebaseAuth.instance.currentUser!.uid, receiver.uid],
      }, SetOptions(merge: true));
      emit(MessageSentSuccess());
    } catch (e) {
      emit(MessageSentFailed(errorMassage: 'Failed to send message: $e'));
    }
  }
  Stream<QuerySnapshot> getMessages(UserModel receiver) {
    String chatId =
        getChatId(FirebaseAuth.instance.currentUser!.uid, receiver.uid!);
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
  String getChatId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode ? '$uid1\_$uid2' : '$uid2\_$uid1';
  }
  Future<void> saveUserDataToPreferences(UserModel user) async {
    await SharedPreferenceHelper.saveUserId(user.uid!);
    await SharedPreferenceHelper.saveUserEmail(user.email!);
    await SharedPreferenceHelper.saveUserName(user.name!);
  }
  Future<void> signInFromFirebase() async {
    emit(LoginLoading());
    try {
      final UserCredential credential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      emit(LoginSuccess());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        emit(LoginFailed(errorMassage: 'User Not Found'));
      } else if (e.code == 'wrong-password') {
        emit(LoginFailed(errorMassage: 'Wrong Password'));
      } else {
        emit(LoginFailed(errorMassage: 'Something went wrong on Login'));
      }
    } catch (e) {
      emit(LoginFailed(errorMassage: 'An unexpected error occurred'));
    }
  }
  void clearSearchResults() {
    searchResults.clear();
    emit(SearchResultsCleared());
  }
  void toggleSearch() {
    search = !search;
    if (!search) {
      searchController.clear();
      searchResults.clear();
    }
    emit(SearchToggledState());
  }
 Future<void> signOutFromFirebase() async {
  emit(LogoutLoading());
  try {
    GoogleSignIn googleSignIn = GoogleSignIn();
    // تسجيل الخروج من حساب Google إذا كان المستخدم قد سجل الدخول باستخدام Google
    await googleSignIn.signOut();
    // تسجيل الخروج من Firebase
    await FirebaseAuth.instance.signOut();
    emit(LogoutSuccess());
  } catch (e) {
    emit(LogoutFailed(errorMassage: 'Sign out failed: ${e.toString()}'));
  }
}

  Future<void> addUserToFirestore(UserModel user) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore.collection('users').doc(user.uid).set(user.toMap());
  }
  Future<UserModel> getUserFromFirestore(String uid) async {
    final DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return UserModel.fromJson(doc.data() as Map<String, dynamic>);
  }
  Future<void> updateUserInFirestore(UserModel user) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore.collection('users').doc(user.uid).update(user.toMap());
  }
  Future<void> pickImage() async {
    try {
      final XFile? image =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
      if (image != null) {
        imgPath = File(image.path);
        String imageName = basename(image.path);
        int random = Random().nextInt(99999);
        imgName = '$imageName$random';
        emit(PickImageState(imgPath!));
      }
    } catch (e) {
      emit(ImageUploadedError("Failed to pick image"));
    }
  }
  Future<void> uploadImageToFireStore() async {
    if (imgPath != null && imgName != null) {
      try {
        emit(ImageUploading());
        final storageRef =
            FirebaseStorage.instance.ref().child('images/users/$imgName');
        final uploadTask = storageRef.putFile(imgPath!);
        // إضافة نقاط تحقق هنا
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          print(
              'Upload progress: ${snapshot.bytesTransferred / snapshot.totalBytes * 100}%');
        });
        await uploadTask;
        downloadUrl = await storageRef.getDownloadURL();
        final credential = FirebaseAuth.instance.currentUser;
        if (credential != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(credential.uid)
              .update({
            "profilePic": downloadUrl,
          });
          await SharedPreferenceHelper.saveUserPic(downloadUrl!);
          emit(ImageUploaded(downloadUrl!));
        }
      } catch (e) {
        print('Upload error: $e'); // طباعة الأخطاء
        emit(ImageUploadedError("Failed to upload image"));
      }
    } else {
      emit(ImageUploadedError("No image selected"));
    }
  }
  void sendPasswordResetEmail() async {
    try {
      emit(ResetPasswordLoading());
      final email = resetPasswordController.text;
      final signInMethods =
      await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (signInMethods.isEmpty) {
        emit(ResetPasswordError("Email is not registered"));
        return;
      }
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      emit(ResetPasswordEmailSent());
    } catch (e) {
      emit(ResetPasswordError(e.toString()));
    }
  }
  Future<void> signInWithGoogle() async {
    emit(LoginLoading()); // تغيير الحالة إلى تحميل عند بدء عملية تسجيل الدخول
    try {
      // بدء عملية المصادقة باستخدام Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        emit(LoginFailed(errorMassage: "Google sign-in was cancelled."));
        return; // إذا ألغى المستخدم عملية تسجيل الدخول
      }
      // الحصول على تفاصيل المصادقة من الطلب
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      // إنشاء بيانات الاعتماد باستخدام تفاصيل Google
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      // تسجيل الدخول باستخدام بيانات الاعتماد
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      // بعد نجاح تسجيل الدخول
      userModel = UserModel(
        uid: userCredential.user?.uid,
        email: userCredential.user?.email,
        name: userCredential.user?.displayName,
        profilePic: userCredential.user?.photoURL,
        nameLowerCase: userCredential.user?.displayName?.toLowerCase(),
        createdAt: userCredential.user?.metadata.creationTime,
      );
      // حفظ بيانات المستخدم في Firestore و SharedPreferences
      await saveUser(userModel);
      await saveUserDataToPreferences(userModel);
      currentUser = userModel;
      emit(LoginSuccess()); // تغيير الحالة إلى نجاح عند اكتمال العملية بنجاح
    } catch (e) {
      emit(LoginFailed(
          errorMassage:
              "Google sign-in failed: $e")); // تغيير الحالة إلى فشل عند حدوث خطأ
    }
  }
}
