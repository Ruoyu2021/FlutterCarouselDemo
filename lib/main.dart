import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Carousel Demo',
      theme: ThemeData(primaryColor: Colors.blue),
      home: FlutterCarouselDemo(),
    );
  }
}

class FlutterCarouselDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FlutterCarouselDemoState();
  }
}

class FlutterCarouselDemoState extends State<FlutterCarouselDemo>
    with SingleTickerProviderStateMixin {
  var images = [
    'assets/images/1.png',
    'assets/images/2.png',
    'assets/images/3.png',
  ];
  var _width = 300.0;
  var _height = 180.0;
  var _currentIndex = 0;
  bool _animationRunning = false;
  bool _onDragging = false;
  late Offset _dragStartPosition;
  late Offset _dragCurrentPosition;

  late AnimationController _controller;
  var _curveAnimation;
  var _tween, _tweenBegin = 0.0, _tweenEnd = 0.0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )
      ..addListener(() {
        setState(() {});
        // print('addListener: ${_controller.value}');
      })
      ..addStatusListener((status) {
        print('addStatusListener');
        if (status == AnimationStatus.completed) {
          print('completed');
          switch (_increaseCurrentIndex) {
            case -1:
              _currentIndex--;
              break;
            case 1:
              _currentIndex++;
              break;
          }
          if (_currentIndex == images.length) {
            _currentIndex = 0;
          }
          if (_currentIndex < 0) {
            _currentIndex = images.length - 1;
          }
          _timer.cancel();
          _controller.stop();
          _animationRunning = false;
          _dragDistance = 0.0;
          for (var i = 0; i < _leftOffset.length; i++) {
            _leftOffset[i] = 0.0;
          }
          _initTimer();
        }
      });

    _curveAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _tween = Tween(begin: _tweenBegin, end: _tweenEnd).animate(_curveAnimation);

    for (var i = 0; i < images.length; i++) {
      _leftOffset.add(0.0);
    }
    _initTimer();
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('test'),
      ),
      body: Center(
        child: Container(
          color: Colors.red,
          height: 180,
          width: 300,
          child: GestureDetector(
            onTap: () {
              _onTap();
            },
            onTapDown: (tapDown) {
              print('tapDown');
              _onTapDown(tapDown);
            },
            onTapUp: (tapUp) {
              print('tapDown');
              _onTapUp(tapUp);
            },
            onHorizontalDragStart: (dragStart) {
              print('dragStart');
              _onDragStart(dragStart);
            },
            onHorizontalDragUpdate: (dragUpdate) {
              print('dragUpdate');
              _onDragUpdate(dragUpdate);
            },
            onHorizontalDragEnd: (dragEnd) {
              print('dragEnd');
              _onDragEnd(dragEnd);
            },
            child: Stack(
              children: _generateCarousel(),
            ),
          ),
        ),
      ),
    );
  }

  _initTimer() {
    try {
      _timer = Timer(Duration(milliseconds: 3000), () {
        print('timer start');
        _controller.reset();
        _controller.forward();
        _animationRunning = true;
      });
    } catch (ex) {
      // print(ex);
    }
  }

  List<Widget> _generateCarousel() {
    List<Widget> widgets = [];
    if (images.length == 0) {
      var widget = Container(
        width: _width,
        height: _height,
        child: Center(
          child: Text('NO IMAGES'),
        ),
      );
      widgets.add(widget);
    } else if (images.length == 1) {
      widgets.add(
        Positioned(
          left: 0,
          width: _width,
          height: _height,
          child: Image.asset(
            images[0],
            fit: BoxFit.fill,
          ),
        ),
      );
    } else if (images.length >= 2) {
      for (var i = 0; i < 3; i++) {
        var widget = Positioned(
          left: _calculateLeft(i),
          width: _width,
          height: _height,
          child: Image.asset(
            _calculateImage(i),
            fit: BoxFit.fill,
          ),
        );
        widgets.add(widget);
      }
    }
    return widgets;
  }

  double _dragDistance = 0.0;
  List<double> _leftOffset = [];
  int _increaseCurrentIndex = 0; // -1 dc 0  1 ic

  double _calculateLeft(int index) {
    double _left = _leftOffset[index] + _dragDistance;
    if (!_onDragging) {
      if (_dragDistance == 0.0) {
        _tweenBegin = (index - 1) * _width;
        _tweenEnd = (index - 2) * _width;
        _tween =
            Tween(begin: _tweenBegin, end: _tweenEnd).animate(_curveAnimation);
        _left = _animationRunning ? _tween.value : (index - 1) * _width;
        _leftOffset[index] = _left;
        _increaseCurrentIndex = 1;
      } else {
        _tweenBegin = _left;
        if (_leftOffset[1] < 0) {
          if (_leftOffset[1] + _width + _dragDistance >= 0.25 * _width) {
            _tweenEnd = (index - 1) * _width;
            _increaseCurrentIndex = 0;
          } else if (_leftOffset[1] + _width + _dragDistance < 0.25 * _width) {
            _tweenEnd = (index - 2) * _width;
            _increaseCurrentIndex = 1;
          }
        } else {
          if (_dragDistance >= 0.25 * _width) {
            _tweenEnd = index * _width;
            _increaseCurrentIndex = -1;
          } else if (_dragDistance <= -0.25 * _width) {
            _tweenEnd = (index - 2) * _width;
            _increaseCurrentIndex = 1;
          } else {
            _tweenEnd = (index - 1) * _width;
            _increaseCurrentIndex = 0;
          }
        }
        _tween =
            Tween(begin: _tweenBegin, end: _tweenEnd).animate(_curveAnimation);
        _left = _tween.value;
      }
    }
    return _left;
  }

  String _calculateImage(int index) {
    var imageName = images[0];
    switch (index) {
      case 0:
        if (_currentIndex == 0) {
          imageName = images[images.length - 1];
        } else {
          imageName = images[_currentIndex - 1];
        }
        break;
      case 1:
        imageName = images[_currentIndex];
        break;
      case 2:
        if (_currentIndex == images.length - 1) {
          imageName = images[0];
        } else {
          imageName = images[_currentIndex + 1];
        }
        break;
    }
    return imageName;
  }

  _onTap() {
    print('onTap');
  }

  _onTapDown(TapDownDetails tapDown) {
    print('_onTapDown');
    _timer.cancel();
    _controller.stop();
  }

  _onTapUp(TapUpDetails tapUp) {
    print('_onTapUp');
    _controller.forward();
  }

  _onDragStart(DragStartDetails dragStart) {
    print('_onDragStart');
    _timer.cancel();
    _controller.stop();
    _dragStartPosition = dragStart.localPosition;
  }

  _onDragUpdate(DragUpdateDetails dragUpdate) {
    print('_onDragUpdate');
    setState(() {
      _onDragging = true;
      _dragCurrentPosition = dragUpdate.localPosition;
      _dragDistance = _dragCurrentPosition.dx - _dragStartPosition.dx;
    });
  }

  _onDragEnd(DragEndDetails os) {
    print('_onDragEnd');
    _onDragging = false;
    _controller.reset();
    _controller.forward();
  }
}
