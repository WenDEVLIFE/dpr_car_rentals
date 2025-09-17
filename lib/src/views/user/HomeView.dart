import 'package:flutter/cupertino.dart';

class Homeview extends StatefulWidget  {
  const Homeview({super.key});

  @override
  State<Homeview> createState() => _HomeviewState();
}

class _HomeviewState extends State<Homeview> {
  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Home View'),
      ),
      child: Center(
        child: Text('Welcome, User!'),
      ),
    );
  }
}