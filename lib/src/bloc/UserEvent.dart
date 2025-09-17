import 'package:equatable/equatable.dart';
import '../models/UserModel.dart';

abstract class UserEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadUsers extends UserEvent {}

class AddUser extends UserEvent {
  final UserModel user;

  AddUser(this.user);

  @override
  List<Object?> get props => [user];
}

class UpdateUser extends UserEvent {
  final String uid;
  final UserModel user;

  UpdateUser(this.uid, this.user);

  @override
  List<Object?> get props => [uid, user];
}

class DeleteUser extends UserEvent {
  final String uid;

  DeleteUser(this.uid);

  @override
  List<Object?> get props => [uid];
}

class SearchUsers extends UserEvent {
  final String query;

  SearchUsers(this.query);

  @override
  List<Object?> get props => [query];
}
