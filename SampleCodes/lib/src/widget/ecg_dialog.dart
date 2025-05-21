import 'package:flutter/material.dart';

class EcgDialog extends StatefulWidget {
  final bool visible;
  final Function onClose;
  final String data;
  final String title;

  const EcgDialog({
    Key? key,
    required this.visible,
    required this.onClose,
    required this.data,
    required this.title,
  }) : super(key: key);

  @override
  _EcgDialogState createState() => _EcgDialogState();
}

class _EcgDialogState extends State<EcgDialog> {
  @override
  void initState() {
    super.initState();
  }

  void handleConfirm() {
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return SizedBox.shrink();

    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            child: Text(widget.data),
          ),
        ],
      )),
      actions: [
        TextButton(
          onPressed: handleConfirm,
          child: Text("Close"),
          style: TextButton.styleFrom(primary: Colors.red),
        ),
      ],
    );
  }
}
