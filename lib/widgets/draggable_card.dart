import 'package:flutter_web/material.dart';

class DraggableCard extends StatefulWidget {
  final Widget child;
  DraggableCard({this.child});

  @override
  _DraggableCardState createState() => _DraggableCardState();
}

class _DraggableCardState extends State<DraggableCard>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Alignment _dragAlignment = Alignment.center;

  Animation<Alignment> _animation;

  void _updateAnimation() {
    _animation = _controller.drive(
      AlignmentTween(
        begin: _dragAlignment,
        end: Alignment.center,
      ),
    );
  }

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _controller.addListener(() {
      setState(() {
        _dragAlignment = _animation.value;
      });
    });

    _updateAnimation();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        RenderBox rb = context.findRenderObject();
        Size size = rb.size;

        print("Long Press: ${size.width},${size.height}");
      },
      onDoubleTap: () {
        print("Double Tap");
        Scaffold.of(context)
          ..showSnackBar(SnackBar(content: Text("Hello World")));
      },
      onPanUpdate: (details) {
        setState(() {
          RenderBox rb = context.findRenderObject();
          Size size = rb.size;

          _dragAlignment += Alignment(
            details.delta.dx / ((size.width) / 2),
            details.delta.dy / (size.height / 2),
          );
        });
      },
      onPanDown: (details) {
        _controller.stop();
      },
      onPanEnd: (details) {
        _updateAnimation();
        RenderBox rb = context.findRenderObject();
        Size size = rb.size;

        // Calculate the velocity relative to the unit interval, [0,1],
        // used by the animation controller.
        var pxPerSecond = details.velocity.pixelsPerSecond;
        var unitsPerSecondX = pxPerSecond.dx / size.width;
        var unitsPerSecondY = pxPerSecond.dy / size.height;
        var unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
        var unitVelocity = unitsPerSecond.distance;
        print("Velocity: $unitVelocity");
        var spring = SpringDescription(
          mass: 30,
          stiffness: 1,
          damping: 1,
        );
        var simulation = SpringSimulation(spring, 0, 1, -unitVelocity);

        _controller.animateWith(simulation);
      },
      child: Align(
        alignment: _dragAlignment,
        child: Card(
          child: widget.child,
        ),
      ),
    );
  }
}
