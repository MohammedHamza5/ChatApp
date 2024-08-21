part of 'auth_cubit.dart';

sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AppPasswordVisibilityChanged extends AuthState {}

final class LoginLoading extends AuthState {}

final class LoginSuccess extends AuthState {}

final class LoginFailed extends AuthState {
  final errorMassage;

  LoginFailed({required this.errorMassage});
}

final class LogoutSuccess extends AuthState {}

final class RegisterLoading extends AuthState {}

final class RegisterSuccess extends AuthState {}

final class RegisterFailed extends AuthState {
  final String errorMassage;

  RegisterFailed({required this.errorMassage});
}

final class SearchSuccess extends AuthState {}

final class SearchLoading extends AuthState {}

final class SearchFailed extends AuthState {
  final String errorMassage;

  SearchFailed({required this.errorMassage});
}

final class MessageSentSuccess extends AuthState {}

final class MessageSentFailed extends AuthState {
  final String errorMassage;

  MessageSentFailed({required this.errorMassage});
}

final class LogoutLoading extends AuthState {}

final class LogoutFailed extends AuthState {
  final String errorMassage;

  LogoutFailed({required this.errorMassage});
}

final class AuthFailed extends AuthState {
  final String errorMassage;

  AuthFailed({required this.errorMassage});
}

class PickImageState extends AuthState {
  final File imagePath;

  PickImageState(this.imagePath);
}

class ImageUploading extends AuthState {}

class SearchToggledState extends AuthState {}

class SearchResultsCleared extends AuthState {}

class ResetPasswordEmailSent extends AuthState {}

class ImageUploaded extends AuthState {
  final String imageUrl;

  ImageUploaded(this.imageUrl);
}

class ImageUploadedError extends AuthState {
  final String message;

  ImageUploadedError(this.message);
}

class ResetPasswordError extends AuthState {
  final String message;

  ResetPasswordError(this.message);
}
class ResetPasswordLoading extends AuthState {}
class EmailVerificationSent extends AuthState {}

class EmailAlreadyVerified extends AuthState {}

class EmailVerificationFailed extends AuthState {
  final String errorMassage;
  EmailVerificationFailed(this.errorMassage);
}

class VerificationLoading extends AuthState {}

class EmailNotVerified extends AuthState {
  final String errorMassage;
  EmailNotVerified({required this.errorMassage});
}

class VerificationFailed extends AuthState {
  final String errorMassage;
  VerificationFailed({required this.errorMassage});
}
