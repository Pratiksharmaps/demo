
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class alertdialog extends StatelessWidget {
  final String tittle;
  final String content;
  final Function() ButtonFunction;
  const alertdialog(
      {super.key,
      required this.tittle,
      required this.content,
      required this.ButtonFunction});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(25),
      titlePadding: EdgeInsets.fromLTRB(20, 15, 0, 1),
      shape: RoundedRectangleBorder(),
      title: Text(tittle),
      titleTextStyle: TextStyle(
          fontSize: 23, fontWeight: FontWeight.bold, color: Colors.blue),
      contentTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
      actionsAlignment: MainAxisAlignment.end,
      content: Text(content),
      actions: [
         GestureDetector(
          onTap: ButtonFunction,
           child: Container(
            
              alignment: Alignment.bottomRight,
              height: 33,
              width: 85,
              decoration: BoxDecoration(color: Colors.blue),
              child: const Center(
                child: Text(
                  "OK",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
         ),
        
      ],
    );
  }
}
void showAlertDialogBox(BuildContext context, String tittle, String content,
    Function() button_function) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: ((context) {
        return alertdialog(
          tittle: tittle,
          content: content,
          ButtonFunction: button_function,
        );
      }));
}

void ahideProgressDialog(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop();
}
