import 'package:flutter/cupertino.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'User Screen',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}