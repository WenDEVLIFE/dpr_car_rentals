import 'package:dpr_car_rentals/src/widget/CustomPasswordField.dart';
import 'package:dpr_car_rentals/src/widget/CustomText.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/UserBloc.dart';
import '../../bloc/event/UserEvent.dart';
import '../../bloc/state/UserState.dart';
import '../../helpers/ThemeHelper.dart';
import '../../models/UserModel.dart';
import '../../repository/RegisterRepository.dart';
import '../../repository/UserRepository.dart';
import '../../widget/CustomTextField.dart';
import '../../widget/CustomPasswordField.dart';
import '../../widget/SearchTextField.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showUserDialog(BuildContext outerContext, {UserModel? user}) {
    final isEditing = user != null;
    final nameController = TextEditingController(text: user?.fullName ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final passwordController = TextEditingController();
    String selectedRole =
        (user?.role == 'owner' || user?.role == 'admin') ? user!.role : 'admin';
    final registerRepository = RegisterRepositoryImpl();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit User' : 'Add User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: nameController,
              labelText: 'Full Name',
              hintText: 'Enter full name',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: emailController,
              labelText: 'Email',
              hintText: 'Enter email',
              keyboardType: TextInputType.emailAddress,
            ),
            if (!isEditing) ...[
              const SizedBox(height: 16),
              CustomOutlinePassField(
                  hintText: 'Password',
                  labelText: 'Enter Password',
                  controller: passwordController)
            ],
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: InputDecoration(
                fillColor: ThemeHelper.secondaryColor,
                labelText: 'Role',
                labelStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: ThemeHelper.borderColor,
                    width: 1.0,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: ThemeHelper.borderColor,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: ThemeHelper.borderColor,
                    width: 2.0,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
              ),
              items: const [
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
                DropdownMenuItem(value: 'owner', child: Text('Owner')),
              ],
              onChanged: (value) {
                if (value != null) {
                  selectedRole = value;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final email = emailController.text.trim();
              final fullName = nameController.text.trim();
              final password = passwordController.text;

              if (!isEditing && password.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Password is required for new users')),
                );
                return;
              }

              if (isEditing) {
                final updatedUser = UserModel(
                  uid: user!.uid,
                  email: email,
                  fullName: fullName,
                  role: selectedRole,
                );
                outerContext
                    .read<UserBloc>()
                    .add(UpdateUser(user.uid, updatedUser));
              } else {
                // Create user through UserBloc for consistent state management
                final newUser = UserModel(
                  uid: '', // Will be set by Firebase Auth
                  email: email,
                  fullName: fullName,
                  role: selectedRole,
                );
                outerContext
                    .read<UserBloc>()
                    .add(RegisterUser(newUser, password));
              }

              Navigator.pop(context);
            },
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _deleteUser(String uid) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      context.read<UserBloc>().add(DeleteUser(uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is UserError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: CustomText(
              text: 'Users',
              size: 20,
              color: Colors.white,
              fontFamily: 'Inter',
              weight: FontWeight.w700),
          backgroundColor: Colors.blue,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () => _showUserDialog(context),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SearchTextField(
                controller: _searchController,
                hintText: 'Search users...',
                onChanged: (query) =>
                    context.read<UserBloc>().add(SearchUsers(query)),
              ),
            ),
            Expanded(
              child: BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  if (state is UserInitial) {
                    context.read<UserBloc>().add(LoadUsers());
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is UserLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is UserLoaded) {
                    final users = state.filteredUsers;
                    if (users.isEmpty) {
                      return const Center(child: Text('No users found'));
                    }

                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(
                                user.fullName.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              user.fullName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('${user.email}\nRole: ${user.role}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () =>
                                      _showUserDialog(context, user: user),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _deleteUser(user.uid),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is UserError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  return const Center(child: Text('No data'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
