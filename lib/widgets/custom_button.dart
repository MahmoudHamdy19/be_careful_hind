
import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  double opacity ;
   ButtonWidget({required this.onPressed, required this.text,this.opacity = 1.0,Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return   SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(onPressed: onPressed, child: Text(text,style: TextStyle(color: Colors.white,fontSize: 18.9,fontWeight: FontWeight.bold),)),
    );
  }
}
