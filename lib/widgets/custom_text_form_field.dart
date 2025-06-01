import 'package:flutter/material.dart';

import '../theme/theme_helper.dart';


class TextFieldWidget extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final bool? readOnly;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;


  const TextFieldWidget({
    required this.labelText,
    required this.controller,
    this.obscureText = false,
    this.suffixIcon,
    this.hintText,
    this.readOnly,
    this.validator
  });

  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      width: double.infinity,
      child: Column(
        spacing: 5.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(labelText,style: TextStyle(color: theme.primaryColor,fontSize:14,fontWeight: FontWeight.bold),),
          TextFormField(
            validator: validator,
            controller: controller,
            obscureText: obscureText,
            readOnly: readOnly??false,
            decoration: InputDecoration(
              hintText: hintText??'ادخل $labelText',
              hintStyle: TextStyle(fontSize: 14.0,color: Colors.black),
              suffixIcon: suffixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}