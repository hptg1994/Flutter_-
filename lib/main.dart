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
      theme: ThemeData(primaryColor: Color(0xFFFF6688), scaffoldBackgroundColor: Colors.white),
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
              color: isOnlight ? Theme.of(context).primaryColor : Colors.white)),
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
  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
        new SliderMarks(
            markCount: widget.markCount,
            color: widget.positiveColor,
            paddingTop: 50.0,
            paddingBottom: 50.0),
        new Container(
          color: widget.positiveColor,
        ),
        new SliderMarks(
            markCount: widget.markCount,
            color: widget.negativeColor,
            paddingTop: 50.0,
            paddingBottom: 50.0
        ),
      ],
    );
  }
}

class SliderMarks extends StatelessWidget {
  final int markCount;
  final Color color;
  final double paddingTop;
  final double paddingBottom;

  SliderMarks({this.markCount, this.color, this.paddingTop, this.paddingBottom});

  @override
  Widget build(BuildContext context) {
    return new CustomPaint(
      painter: new SliderMarksPainter(
          markCount: markCount,
          color: color,
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
  final Color color;
  final double markThickness;
  final double paddingTop;
  final double paddingBottom;
  final double paddingRight;
  final Paint markPaint;

  SliderMarksPainter(
      {this.markCount,
      this.color,
      this.markThickness,
      this.paddingTop,
      this.paddingBottom,
      this.paddingRight})
      : markPaint = new Paint()
          ..color = color
          ..strokeWidth = markThickness
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
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
