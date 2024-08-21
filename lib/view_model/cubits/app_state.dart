part of 'app_cubit.dart';

sealed class AppState {}

final class AppInitial extends AppState {}
final class AppSearch extends AppState {}
final class AppStateChanged extends AppState {}
