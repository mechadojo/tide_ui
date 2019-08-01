import 'package:flutter_web/material.dart';
import 'dart:html';
import 'dart:js' as js;
import 'package:uuid/uuid.dart';

void main() => runApp(TheApp());

class TheApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        drawer: Container(color: Colors.green, child: Text("Side Bar")),
        body: EventContainer(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Container(
                      color: Colors.yellow,
                      height: 75,
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.red,
                        child: DraggableCard(
                          child: FlutterLogo(
                            size: 128,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 300, color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }
}

class EventContainer extends StatefulWidget {
  final Widget child;
  EventContainer({this.child});

  _EventContainerState createState() => _EventContainerState();
}

class _EventContainerState extends State<EventContainer> {
  var _eventkey = Uuid().toString();
  var _counter = 0;

  bool get IsCurrentHandler {
    return js.context["Window"]["eventmaster"] == _eventkey;
  }

  void _handleKeyDown(KeyboardEvent evt) {
    if (!IsCurrentHandler) return;
    if (evt.key != "Control") {
      _counter++;
      print(
          "Woot Key Down: Counter ${_counter} Ctrl:${evt.ctrlKey} Shift: ${evt.shiftKey} Key: ${evt.key} KeyCode: ${evt.keyCode}");
      if (evt.ctrlKey) evt.preventDefault();
    }
  }

  void _handleContextMenu(MouseEvent evt) {
    if (!IsCurrentHandler) return;
    print("Context Menu Clicked");
    evt.preventDefault();
  }

  void _handleMouseWheel(WheelEvent evt) {
    if (!IsCurrentHandler) return;
    print("Mouse Wheel: Ctrl: ${evt.ctrlKey} ${evt.deltaY}");
  }

  @override
  void initState() {
    var obj = js.context["Window"];
    obj["eventmaster"] = _eventkey;

    print("Adding new event listener with key: $_eventkey");
    window.onKeyDown.listen(_handleKeyDown);
    window.onContextMenu.listen(_handleContextMenu);
    window.onMouseWheel.listen(_handleMouseWheel);

    super.initState();
  }

  @override
  void dispose() {
    print("Disposing Event Container State");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: widget.child);
  }
}

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
