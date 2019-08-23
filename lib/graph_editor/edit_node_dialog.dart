import 'package:flutter_web/material.dart';
import 'package:tide_chart/tide_chart.dart';

class EditNodeDialog extends StatefulWidget {
  static double EditNodeDialogHeight = 150;
  final TideChartNode node;
  final VoidCallback onClose;

  EditNodeDialog(this.node, this.onClose);

  _EditNodeDialogState createState() => _EditNodeDialogState();
}

class _EditNodeDialogState extends State<EditNodeDialog> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: EditNodeDialog.EditNodeDialogHeight,
      child: Row(
        children: <Widget>[
          FlatButton(
            child: Text("Close Me"),
            onPressed: widget.onClose,
          ),
          Container(
            width: 100,
            child: Column(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(border: OutlineInputBorder()),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
