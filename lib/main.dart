import 'dart:ui';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spring Slider',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: Color(0xFFFF6688),
          scaffoldBackgroundColor: Colors.white),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget _buildTextButton(String title, bool isOnlight) {
    return new FlatButton(
      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Text(title,
          style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              color:
                  isOnlight ? Theme.of(context).primaryColor : Colors.white)),
      onPressed: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          iconTheme: new IconThemeData(
            color: Theme.of(context).primaryColor,
          ),
          brightness: Brightness.light,
          leading: new IconButton(icon: new Icon(Icons.menu), onPressed: () {}),
          actions: <Widget>[_buildTextButton("settings".toUpperCase(), true)],
        ),
        body: Column(
          children: <Widget>[
            new Expanded(
                child: SpringSlider(
                    markCount: 12,
                    positiveColor: Theme.of(context).primaryColor,
                    negativeColor: Theme.of(context).scaffoldBackgroundColor)),
            new Container(
              color: Theme.of(context).primaryColor,
              child: Row(
                children: <Widget>[
                  _buildTextButton('more'.toUpperCase(), false),
                  new Expanded(child: new Container()),
                  _buildTextButton("stats".toUpperCase(), false)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SpringSlider extends StatefulWidget {
  final int markCount;
  final Color positiveColor;
  final Color negativeColor;

  SpringSlider({this.markCount, this.positiveColor, this.negativeColor});

  @override
  State<StatefulWidget> createState() {
    return new SpringSliderState();
  }
}

class SpringSliderState extends State<SpringSlider> {
  final double paddingTop = 50.0;
  final double paddingBottom = 50.0;
  double sliderPercent = 0.5;

  @override
  Widget build(BuildContext context) {
    return SliderDragger(
      initialSliderPercent: sliderPercent,
      onSliderChange: (double sliderPercent) {
        setState(() {
          this.sliderPercent = sliderPercent;
        });
      },
      child: new Stack(
        children: <Widget>[
          new SliderMarks(
              markCount: widget.markCount,
              markColor: widget.positiveColor,
              backgroundColor: widget.negativeColor,
              paddingTop: paddingTop,
              paddingBottom: paddingBottom),
          // 用ClipPath强制把它移下去（sets what part of an element should be shown）
          new SliderGoo(
            sliderPercent: sliderPercent,
            paddingBottom: paddingBottom,
            paddingTop: paddingTop,
            child: new SliderMarks(
                markCount: widget.markCount,
                markColor: widget.negativeColor,
                backgroundColor: widget.positiveColor,
                paddingTop: paddingTop,
                paddingBottom: paddingBottom),
          ),
          new SliderPoints(
            sliderPercent: sliderPercent,
            paddingTop: paddingTop,
            paddingBottom: paddingBottom,
          ),
        ],
      ),
    );
  }
}

class SliderPoints extends StatelessWidget {
  final double sliderPercent;
  final double paddingTop;
  final double paddingBottom;

  const SliderPoints({this.sliderPercent, this.paddingTop, this.paddingBottom});

  @override
  Widget build(BuildContext context) {
    /// slider的文字
    return new Padding(
      padding: EdgeInsets.only(top: 0.0, bottom: 0.0),
      // LayoutBuilder的原因是要他里面的BoxConstraints,LayoutBuilder侦测的是他所在这个Widget的长宽高
      child: new LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final height = constraints.maxHeight;
          final sliderY = height * (1.0 - sliderPercent);
          final pointsYouNeed = (100 * (1.0 - sliderPercent)).round();
          final pointsYouHave = 100 - pointsYouNeed;

          return new Stack(
            children: <Widget>[
              new Positioned(
                left: 30.0,
                top: sliderY - 50.0,
                child: FractionalTranslation(
                    translation: Offset(0.0, -1.0),
                    child: new Points(
                      points: pointsYouNeed,
                      isAboveSlider: true,
                      isPointsYouNeed: true,
                      color: Theme.of(context).primaryColor,
                    )),
              ),
              new Positioned(
                left: 30.0,
                top: sliderY + 50.0,
                child: new Points(
                  points: pointsYouHave,
                  isAboveSlider: false,
                  isPointsYouNeed: false,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class SliderDragger extends StatefulWidget {
  final Widget child;
  final double initialSliderPercent;
  final Function(double sliderPercent) onSliderChange;

  const SliderDragger(
      {this.child, this.onSliderChange, this.initialSliderPercent = 0.0});

  @override
  _SliderDraggerState createState() => _SliderDraggerState();
}

class _SliderDraggerState extends State<SliderDragger> {
  double sliderPercent;
  double startDragY;
  double startDragPercent;

  @override
  void initState() {
    super.initState();
    sliderPercent = widget.initialSliderPercent;
  }

  void _onPanStart(DragStartDetails details) {
    startDragY = details.globalPosition.dy;
    startDragPercent = sliderPercent;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final dragDistance = startDragY - details.globalPosition.dy;
    final sliderHeight = context.size.height;
    final dragPercent = dragDistance / sliderHeight;
    sliderPercent = startDragPercent + dragPercent;
    if (widget.onSliderChange != null) {
      widget.onSliderChange(sliderPercent);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    startDragY = null;
    startDragPercent = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: widget.child,
    );
  }
}

class SliderGoo extends StatelessWidget {
  final double sliderPercent;
  final double paddingTop;
  final double paddingBottom;
  final Widget child;

  const SliderGoo(
      {this.sliderPercent, this.paddingTop, this.paddingBottom, this.child});

  @override
  Widget build(BuildContext context) {
    return new ClipPath(
      clipper: new SliderClipper(
          sliderPercent: sliderPercent,
          paddingBottom: paddingBottom,
          paddingTop: paddingTop),
      child: child,
    );
  }
}

/// Description: 分裂滑动界面为个界面（A widget that clips its child using self define shape.）
class SliderClipper extends CustomClipper<Path> {
  final double sliderPercent;
  final double paddingTop;
  final double paddingBottom;

  SliderClipper({this.sliderPercent, this.paddingTop, this.paddingBottom});

  @override
  Path getClip(Size size) {
    Path rect = new Path();

    final top = paddingTop;
    final bottom = size.height;
    final height = bottom - paddingBottom - top;
    final percentFromBottom = 1.0 - sliderPercent;

    // 保留的部分
    rect.addRect(new Rect.fromLTRB(
        0.0, top + (percentFromBottom * height), size.width, bottom));
    return rect;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class SliderMarks extends StatelessWidget {
  final int markCount;
  final Color markColor;
  final Color backgroundColor;
  final double paddingTop;
  final double paddingBottom;

  SliderMarks(
      {this.markCount,
      this.markColor,
      this.paddingTop,
      this.paddingBottom,
      this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return new CustomPaint(
      painter: new SliderMarksPainter(
          markCount: markCount,
          markColor: markColor,
          backgroundColor: backgroundColor,
          markThickness: 2.0,
          paddingTop: paddingTop,
          paddingBottom: paddingBottom,
          paddingRight: 20.0),
      child: Container(),
    );
  }
}

class SliderMarksPainter extends CustomPainter {
  final double largeMarkWidth = 30.0;
  final double smallMarkWidth = 10.0;
  final int markCount;
  final Color backgroundColor;
  final Color markColor;
  final double markThickness;
  final double paddingTop;
  final double paddingBottom;
  final double paddingRight;
  final Paint markPaint;
  final Paint backgroundPaint;

  SliderMarksPainter(
      {this.markCount,
      this.markColor,
      this.backgroundColor,
      this.markThickness,
      this.paddingTop,
      this.paddingBottom,
      this.paddingRight})
      : markPaint = new Paint()
          ..color = markColor
          ..strokeWidth = markThickness
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
        backgroundPaint = new Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Rect.fromLTWH(0.0, 0.0, size.width, size.height), backgroundPaint);
    final paintHeight = size.height - paddingTop - paddingBottom;
    final gap = paintHeight / (markCount - 1);

    for (int i = 0; i < markCount; ++i) {
      double markWidth = smallMarkWidth;
      if (i == 0 || i == markCount - 1) {
        markWidth = largeMarkWidth;
      } else if (i == 1 || i == markCount - 2) {
        markWidth = lerpDouble(smallMarkWidth, largeMarkWidth, 0.5);
      }

      final markY = i * gap + paddingTop;

      canvas.drawLine(new Offset(size.width - markWidth - paddingRight, markY),
          new Offset(size.width - paddingRight, markY), markPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

/// 文字的具体显示方式
class Points extends StatelessWidget {
  final int points;
  final bool isAboveSlider;
  final bool isPointsYouNeed;
  final Color color;

  const Points(
      {this.points, this.isAboveSlider, this.isPointsYouNeed, this.color});

  @override
  Widget build(BuildContext context) {
    final percent = points / 100.0;
    final pointTextSize = 30.0 + (70.0 * percent);
    return new Row(
      crossAxisAlignment:
          isAboveSlider ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        new FractionalTranslation(
          translation: Offset(0.0, isAboveSlider ? 0.18 : -0.18),
          child: new Text(
            '$points',
            style: new TextStyle(fontSize: pointTextSize, color: color),
          ),
        ),
        new Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: new Text(
                  "POINTS",
                  style:
                      new TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
              ),
              new Text(
                isPointsYouNeed ? "YOU NEED" : "YOU HAVE",
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        )
      ],
    );
  }
}
