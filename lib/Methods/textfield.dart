import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

class UnderlineInputField extends StatelessWidget {
  final String hint;
  final int? max;
  final int? maxChar;
  final Widget? end;
  final bool expand;
  final TextInputType? inputType;
  final TextEditingController? controller;
  final FormFieldValidator? validator;
  const UnderlineInputField({Key? key,this.inputType, required this.hint,this.controller,this.validator,this.max,this.maxChar,this.end,this.expand = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String currentLocale = Locales.currentLocale(context).toString();
    return Container(
      margin: const EdgeInsets.all(8),
      child: TextFormField(
        keyboardType: inputType,
        validator: validator,
        controller: controller,
        maxLines: max,
        maxLength: maxChar,
        expands: expand,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: Locales.string(context,hint),
          hintText: Locales.string(context,hint),
          hintStyle: TextStyle(fontFamily: currentLocale == "en"?"Ubuntu":"Dubai"),
          helperStyle: TextStyle(fontFamily: currentLocale == "en"?"Ubuntu":"Dubai"),
          labelStyle: TextStyle(fontFamily: currentLocale == "en"?"Ubuntu":"Dubai"),
          suffixIcon: end
        ),
      ),
    );
  }
}
