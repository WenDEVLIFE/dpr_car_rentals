import 'package:flutter/cupertino.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Admin Dashboard'),
      ),
      child: Center(
        child: Text('Welcome, Admin!'),
      ),
    );
  }
}