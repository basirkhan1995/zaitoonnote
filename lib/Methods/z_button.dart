
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'colors.dart';

class ZButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String? label;
  final double height;
  final double width;
  final double fontSize;
  final Color? backgroundColor;
  final Color? labelColor;
  final double? radius;
  const ZButton({Key? key,
    this.onTap,
    this.label,
    this.fontSize = 15,
    this.width = .9,
    this.height = 50,
    this.radius = 8,
    this.backgroundColor = zPrimaryColor,
    this.labelColor = Colors.white
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String locale = Locales.currentLocale(context).toString();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10,horizontal: 6),
      width: MediaQuery.of(context).size.width * width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8)
      ),
      child: TextButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius!),
          ),
        ),
        onPressed: onTap,
        child: LocaleText(label!,style: TextStyle(color: labelColor,fontSize: fontSize,fontFamily: locale == "en"? "Ubuntu":"Dubai",fontWeight: FontWeight.bold)),
      ),
    );
  }
}
