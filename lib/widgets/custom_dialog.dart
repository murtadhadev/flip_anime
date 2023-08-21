import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String heading;
  final String title;
  final String yes;
  final String no;

  const CustomDialog({
    super.key,
    required this.heading,
    required this.title,
    this.yes = "Yes",
    this.no = "No",
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(heading),
      content: Text(
        title,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: Text(yes),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: Text(no),
        ),
      ],
    );
  }
}
