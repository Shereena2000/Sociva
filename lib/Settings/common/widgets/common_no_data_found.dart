import 'package:flutter/material.dart';

class CommonNoDataFoundWidget extends StatelessWidget {
  const CommonNoDataFoundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: size.height / 5),
        child: const Text('No data found'),
      ),
    );
  }
}
