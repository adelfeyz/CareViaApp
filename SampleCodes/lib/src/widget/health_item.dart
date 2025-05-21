
import 'package:flutter/material.dart';

class HealthItemWidget extends StatefulWidget {
  var buttonTitle;

  var data;

  var onPressed;

  Axis direction;

  bool visible;

  double process;

  final Widget? child;

  var listDate;

  HealthItemWidget(
      {super.key,
      this.data,
      this.visible = false,
      this.process = 0,
      this.direction = Axis.horizontal,
      this.child,
      this.listDate = const [],
      required this.buttonTitle,
      required this.onPressed});

  @override
  State<HealthItemWidget> createState() => _HealthItemWidgetState();
}

class _HealthItemWidgetState extends State<HealthItemWidget> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.direction == Axis.horizontal
            ? Row(
                children: [
                  const SizedBox(width: 10),
                  TextButton(
                      onPressed: widget.onPressed,
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blue[100])),
                      child: Text(
                        widget.buttonTitle,
                      )),
                  const SizedBox(width: 10),
                  widget.child ?? Container(),
                  Expanded(
                      child: Text(
                    widget.data,
                    maxLines: 1000,
                    overflow: TextOverflow.ellipsis,
                  )),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 10),
                  TextButton(
                      onPressed: widget.onPressed,
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blue[100])),
                      child: Text(
                        widget.buttonTitle,
                      )),
                  const SizedBox(width: 10),
                  widget.child ?? Container(),
                  Text(
                    widget.data,
                    maxLines: 1000,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
        Center(
          child: Container(
            height: widget.listDate.length > 0 ? 200 : 0, // 固定高度
            width: double.infinity, // 宽度占满整个屏幕
            child: ListView.builder(
              itemCount: widget.listDate.length, // 数据长度
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text("${widget.listDate[index]}"),
                );
              },
            ),
          ),
        ),
        Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              child: Visibility(
                  visible: widget.visible,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.black, // 背景颜色
                    valueColor:
                        const AlwaysStoppedAnimation(Colors.red), // 进度动画颜色
                    value: widget.process, // 如果进度是确定的，那么可以设置进度百分比，0-1
                  )),
            ),
            const Divider(),
          ],
        )
      ],
    );
  }
}
