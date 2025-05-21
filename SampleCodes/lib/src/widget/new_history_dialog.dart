import 'package:flutter/material.dart';

class NewHistoryDialog extends StatefulWidget {
  final bool visible;
  final Function onClose;
  final List<dynamic> data;
  final String title;

  const NewHistoryDialog({
    Key? key,
    required this.visible,
    required this.onClose,
    required this.data,
    required this.title,
  }) : super(key: key);

  @override
  _NewHistoryDialogState createState() => _NewHistoryDialogState();
}

class _NewHistoryDialogState extends State<NewHistoryDialog> {
  int selectedType = 0;
  bool loadData = true;
  List<String> titles = [
    "New History Data",
    "Temperature",
    "Excluded Swimming Activity",
    "Daily Activity",
    "Exercise Activity",
    "Exercise Vital Signs",
    "Swimming Exercise",
    "Single Lap Swimming",
    "Sleep",
    "Step/Temperature/intensity",
  ];

  @override
  void initState() {
    super.initState();
    if (widget.visible) {
      Future.delayed(Duration.zero, () {
        setState(() {
          loadData = false;
        });
      });
    }
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
          DropdownButton<int>(
            value: selectedType,
            onChanged: (int? newValue) {
              setState(() {
                selectedType = newValue!;
              });
            },
            items: List.generate(widget.data.length, (index) {
              return DropdownMenuItem<int>(
                value: index,
                child: Text(titles[index]),
              );
            }),
          ),
          SizedBox(height: 15),
          loadData
              ? Text("Loading... please wait a moment.")
              : SingleChildScrollView(
                  child: Text(
                    widget.data.isNotEmpty
                        ? widget.data[selectedType].toString()
                        : 'No data',
                  ),
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

// 使用示例
// void showNewHistoryDialog(BuildContext context, List<dynamic> data) {
//   showDialog(
//     context: context,
//     builder: (context) {
//       return NewHistoryDialog(
//         visible: true,
//         onClose: () {
//           Navigator.of(context).pop();
//         },
//         data: data,
//         title: "History Data",
//       );
//     },
//   );
// }
