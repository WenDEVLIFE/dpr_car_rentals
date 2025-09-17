import 'package:flutter/cupertino.dart';

class OwnerView extends StatefulWidget {

  const OwnerView({super.key});

  @override
  State<OwnerView> createState() => _OwnerViewState();
}

class _OwnerViewState extends State<OwnerView> {
  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Owner View'),
      ),
      child: Center(
        child: Text('Welcome, Owner!'),
      ),
    );
  }
}
