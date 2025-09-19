import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/UserModel.dart';
import '../repository/RegisterRepository.dart';
import '../repository/UserRepository.dart';
import 'event/UserEvent.dart';
import 'state/UserState.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;
  final RegisterRepository registerRepository;
  List<UserModel> _allUsers = [];

  UserBloc(this.userRepository, this.registerRepository)
      : super(UserInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<AddUser>(_onAddUser);
    on<RegisterUser>(_onRegisterUser);
    on<UpdateUser>(_onUpdateUser);
    on<DeleteUser>(_onDeleteUser);
    on<SearchUsers>(_onSearchUsers);
  }

  void _onLoadUsers(LoadUsers event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      await for (final users in userRepository.getUsers()) {
        _allUsers = users;
        emit(UserLoaded(_allUsers, _allUsers));
      }
    } catch (e) {
      emit(UserError('Failed to load users: $e'));
    }
  }

  void _onAddUser(AddUser event, Emitter<UserState> emit) async {
    try {
      await userRepository.addUser(event.user);
      emit(UserOperationSuccess('User added successfully'));
      add(LoadUsers()); // Reload users to update the list
    } catch (e) {
      emit(UserError('Failed to add user: $e'));
    }
  }

  void _onRegisterUser(RegisterUser event, Emitter<UserState> emit) async {
    try {
      final success = await registerRepository.registerUser(
        email: event.user.email,
        fullName: event.user.fullName,
        password: event.password,
        role: event.user.role,
      );
      if (success) {
        emit(UserOperationSuccess('User registered successfully'));
        add(LoadUsers()); // Reload users to update the list
      } else {
        emit(UserError('Failed to register user'));
      }
    } catch (e) {
      emit(UserError('Failed to register user: $e'));
    }
  }

  void _onUpdateUser(UpdateUser event, Emitter<UserState> emit) async {
    try {
      await userRepository.updateUser(event.uid, event.user);
      emit(UserOperationSuccess('User updated successfully'));
      add(LoadUsers()); // Reload users to update the list
    } catch (e) {
      emit(UserError('Failed to update user: $e'));
    }
  }

  void _onDeleteUser(DeleteUser event, Emitter<UserState> emit) async {
    try {
      await userRepository.deleteUser(event.uid);
      emit(UserOperationSuccess('User deleted successfully'));
      add(LoadUsers()); // Reload users to update the list
    } catch (e) {
      emit(UserError('Failed to delete user: $e'));
    }
  }

  void _onSearchUsers(SearchUsers event, Emitter<UserState> emit) {
    final query = event.query.toLowerCase();
    final filteredUsers = _allUsers.where((user) {
      return user.fullName.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.role.toLowerCase().contains(query);
    }).toList();
    emit(UserLoaded(_allUsers, filteredUsers));
  }
}
