import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget {
  final String message;

  const ProgressDialog({super.key, required this.message});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CircularProgressIndicator(),
          const SizedBox(height: 16.0),
          Text(message),
        ],
      ),
    );
  }
}
void showProgressDialog(BuildContext context, String progressMessage) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return ProgressDialog(message: progressMessage);
    },
  );
}
void hideProgressDialog(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop();
}
