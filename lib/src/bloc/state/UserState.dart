import 'package:equatable/equatable.dart';
import '../../models/UserModel.dart';

abstract class UserState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<UserModel> users;
  final List<UserModel> filteredUsers;

  UserLoaded(this.users, this.filteredUsers);

  @override
  List<Object?> get props => [users, filteredUsers];
}

class UserError extends UserState {
  final String message;

  UserError(this.message);

  @override
  List<Object?> get props => [message];
}

class UserOperationSuccess extends UserState {
  final String message;

  UserOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
