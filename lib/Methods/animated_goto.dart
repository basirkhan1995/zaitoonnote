import 'package:flutter/material.dart';

class GotoRoute extends PageRouteBuilder {
  final Widget route;
  GotoRoute(this.route)
      : super(
      pageBuilder: (context, animation, anotherAnimation) => route,
      transitionDuration: const Duration(microseconds: 1000),
      reverseTransitionDuration: const Duration(microseconds: 400),
      transitionsBuilder: (context, animation, anotherAnimation, child) {
        animation = CurvedAnimation(
            parent: animation,
            curve: Curves.fastLinearToSlowEaseIn,
            reverseCurve: Curves.fastOutSlowIn);
        return SlideTransition(
            position: Tween(
                begin: const Offset(1.0, 0.0),
                end: const Offset(0.0, 0.0))
                .animate(animation),
            child: route);
      });
}
