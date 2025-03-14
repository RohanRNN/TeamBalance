// Author - Rashmin Dungrani

import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:team_balance/config/app_config.dart';
import 'package:team_balance/utils/themes/app_colors.dart';
import 'package:team_balance/utils/themes/app_sizes.dart';
class AppLoader extends StatefulWidget {
  final bool isOverlay;
  final double size;
  final Color loaderColor;

  const AppLoader({
    super.key,
    this.isOverlay = false,
    this.size = 30,
    this.loaderColor = AppColors.blueThemeColor,
  });

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> with TickerProviderStateMixin {
  AnimationController? _animationController;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animationController!.addListener(() => setState(() {}));
    _animationController!.repeat();
    super.initState();
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print(color);

    return Center(
      child: widget.isOverlay
          ? Container(
              width: AppSizes.double125,
              height: AppSizes.double125,
              padding: EdgeInsets.all(AppSizes.double30),
              decoration: BoxDecoration(
                color: AppColors.blueThemeColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: AppConfig.isDebugMode
                  ? getLoader(widget.loaderColor)
                  : RotationTransition(
                      turns: Tween(begin: 0.0, end: 1.0)
                          .animate(_animationController!),
                      child: GradientCircularProgressIndicator(
                        radius: 20,
                        strokeWidth: 5,
                        gradientColors: const [
                          AppColors.blueThemeColorDark,
                          AppColors.blueThemeColor
                        ],
                      ),
                    ),
            )
          : AppConfig.isDebugMode
              ? getLoader(widget.loaderColor)
              : RotationTransition(
                  turns: Tween(begin: 0.0, end: 1.0)
                      .animate(_animationController!),
                  child: GradientCircularProgressIndicator(
                    radius: 20,
                    strokeWidth: 5,
                    gradientColors: const [
                      AppColors.blueThemeColorDark,
                      AppColors.blueThemeColor
                    ],
                  ),
                ),
    );
  }

  Widget getLoader(Color loaderColor) {
    if (AppConfig.isDebugMode) {
      return Icon(Icons.refresh, color: loaderColor);
    }

    if (Platform.isIOS) {
      return const CupertinoActivityIndicator();
    } else {
      return const CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
      );
    }
  }
}

class LoadingOverlay {
  LoadingOverlay._create(this._context);

  factory LoadingOverlay.of(BuildContext context) =>
      LoadingOverlay._create(context);
  BuildContext _context;

  void show(
      {Color backColor = const Color.fromRGBO(229, 229, 229, 0.3),
      bool showLoader = true}) {
    showDialog(
      context: _context,
      barrierDismissible: false,
      barrierColor: backColor,
      builder: (context) => WillPopScope(
        onWillPop: () async {
          return Future.value(false);
        },
        child: showLoader ? const AppLoader(isOverlay: true) : const SizedBox(),
      ),
    );
  }

  void showTransparent() {
    showDialog(
      context: _context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => WillPopScope(
        onWillPop: () async {
          return Future.value(false);
        },
        child: const SizedBox(),
      ),
    );
  }

  void hide() {
    // Navigator.of(_context).pop();
    Navigator.of(_context, rootNavigator: true).pop('dialog');
  }

  Future<T> during<T>(Future<T> future) {
    show();
    return future.whenComplete(hide);
  }
}

class GradientCircularProgressIndicator extends StatelessWidget {
  final double radius;
  final List<Color> gradientColors;
  final double strokeWidth;

  GradientCircularProgressIndicator({
    required this.radius,
    required this.gradientColors,
    this.strokeWidth = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.fromRadius(radius),
      painter: GradientCircularProgressPainter(
        radius: radius,
        gradientColors: gradientColors,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

class GradientCircularProgressPainter extends CustomPainter {
  GradientCircularProgressPainter({
    required this.radius,
    required this.gradientColors,
    required this.strokeWidth,
  });
  final double radius;
  final List<Color> gradientColors;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    size = Size.fromRadius(radius);
    double offset = strokeWidth / 2;
    Rect rect = Offset(offset, offset) &
        Size(size.width - strokeWidth, size.height - strokeWidth);
    var paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    paint.shader =
        SweepGradient(colors: gradientColors, startAngle: 0.0, endAngle: 2 * pi)
            .createShader(rect);
    canvas.drawArc(rect, 0.0, 2 * pi, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
