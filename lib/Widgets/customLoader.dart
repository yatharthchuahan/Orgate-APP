import 'package:flutter/material.dart';



class LoaderOverlay extends StatelessWidget {
  const LoaderOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(181, 255, 255, 255), 
      child: Center(
        child: Image.asset(
          'assets/video/loader.gif',
          width: 50,
          height: 50,
        ),
      ),
    );
  }
}