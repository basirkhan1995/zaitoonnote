import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';

import 'colors.dart';

class ZField extends StatelessWidget {
  final String title;
  final String? hint;
  final bool isRequire;
  final IconData? icon;
  final Widget? end;
  final bool securePassword;
  final TextInputAction? inputAction;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator? validator;
  final TextInputType? keyboardInputType;
  final TextEditingController? controller;
  final Widget? trailing;
  final List<TextInputFormatter>? inputFormat;
  const ZField(
      {Key? key,
        required this.title,
        this.hint,
        this.securePassword = false,
        this.end,
        this.isRequire = false,
        this.icon,
        this.inputFormat,
        this.validator,
        this.controller,
        this.onChanged,
        this.trailing,
        this.keyboardInputType,
        this.inputAction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
  String locale = Locales.currentLocale(context).toString();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 6),
      child: SizedBox(
        width: MediaQuery.of(context).size.width *.9,
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        LocaleText(
                          title,
                          style: TextStyle(fontWeight: FontWeight.bold,fontFamily: locale == "en"?"Ubuntu":"Dubai"),
                        ),
                        isRequire? Text(" *",style: TextStyle(color: Colors.red.shade900),): const SizedBox(),
                      ],
                    )
                  ],
                )
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: MediaQuery.of(context).size.width *.9,
              child: Row(
                children: [
                  Flexible(
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: validator,
                        onChanged: onChanged,
                        obscureText: securePassword,
                        inputFormatters: inputFormat,
                        keyboardType: keyboardInputType,
                        controller: controller,
                        decoration: InputDecoration(
                            helperStyle: const TextStyle(fontFamily: "Dubai"),
                            suffixIcon: trailing,
                            suffix: end,
                            isDense: true,
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:  const BorderSide(color: zPrimaryColor,width: 1)
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: zPrimaryColor,width: 1.5)),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.red.shade900,width: 1.5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.red.shade900),
                            ),
                            prefixIcon: Icon(icon,size: 20,color: zPrimaryColor),
                            hintText: Locales.string(context,title),
                            hintStyle: const TextStyle(fontSize: 16,fontFamily: "Dubai")
                        ),
                      ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
