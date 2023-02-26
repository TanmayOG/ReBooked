import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final Function onClick;
  final TextInputType type;
  final TextEditingController controller;

  const CustomTextField(
      {Key? key,
      required this.hint,
      required this.icon,
      required this.onClick,
      required this.type,
      required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0, right: 25, bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
          border: InputBorder.none,
          hintText: hint,
          fillColor: Colors.grey[100],
          filled: true,
          prefixIcon: Icon(
            icon,
            color: Colors.black,
          ),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return "Please Enter $hint";
          }
          return null;
        },
      ),
    );
  }
}
