import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String buttonText;
  final  Function()? buttonFunction;
  const Button({super.key, required this.buttonText, this.buttonFunction});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        buttonFunction!();
      },
      child: Container(
        height: 47,
        width: 238,
        margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        decoration: const BoxDecoration(
          color: Color.fromRGBO(255, 180, 4, 1.0),
          borderRadius: BorderRadius.all(Radius.circular(11)),
        ),
        child: Center(
          child: Text(
            buttonText,
            style: const TextStyle(
                color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
