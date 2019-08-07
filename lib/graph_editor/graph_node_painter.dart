import 'package:flutter_web/material.dart';
import 'package:tide_ui/graph_editor/data/graph.dart';
import 'package:tide_ui/graph_editor/icons/vector_icons.dart';

import 'data/graph_node.dart';

class GraphNodePainter extends CustomPainter {
  GraphNode node;
  GraphNodePainter(this.node);

  Paint get borderPaint => Graph.NodeBorder;
  Paint get shadowPaint => node.hovered ? Graph.NodeHoverShadow : Graph.NodeShadow;
  Paint get fillPaint => node.hovered? Graph.NodeHoverColor : darkNode ? Graph.NodeDarkColor : Graph.NodeColor;
  
  bool get darkNode =>node.type == GraphNodeType.inport || node.type == GraphNodeType.outport;


  @override
  void paint(Canvas canvas, Size size) {

    canvas.save();
    canvas.scale(node.scale, node.scale);
    canvas.translate(node.offset.dx, node.offset.dy);

    var nodeRect = Rect.fromCenter(center:node.pos, width:node.size.width, height:node.size.height);
    var nodeRRect = RRect.fromRectAndRadius(nodeRect, Radius.circular(Graph.NodeCornerRadius));

    
    canvas..drawRRect(nodeRRect, shadowPaint);
    canvas..drawRRect(nodeRRect, fillPaint);
    canvas..drawRRect(nodeRRect, borderPaint);
    VectorIcons.paintIcon(canvas, node.icon, node.pos, 45, fill: Paint()..color=Colors.black);
    canvas.restore();
    
  }

  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
