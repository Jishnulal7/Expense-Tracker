import 'package:yarima_wallet_pro/app/data/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FormFieldValidator<String>? validator;
  final bool? readOnly;
  final Function()? onTap;
  final void Function(String)? onChanged;
  final int? maxLength;
  final int? maxLines;
  final bool? obscureText;
  final FocusNode? focusNode;
  final Function()? onEditingComplete;
  final void Function(String?)? onSaved;
  final bool? filled;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? style;
  final List<TextInputFormatter>? inputFormatters;
  const CustomTextField({
    super.key,
    this.controller,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.validator,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.maxLength,
    this.maxLines = 1,
    this.labelText,
    this.obscureText = false,
    this.onEditingComplete,
    this.focusNode,
    this.onSaved,
    this.filled = false,
    this.contentPadding,
    this.style,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      onEditingComplete: onEditingComplete,
      obscureText: obscureText!,
      maxLines: maxLines,
      maxLength: maxLength,
      readOnly: readOnly!,
      controller: controller,
      onSaved: onSaved,
      keyboardType: keyboardType,
      validator: validator,
      onTap: onTap,
      style: style,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      decoration: InputDecoration(
        contentPadding: contentPadding,
        counterText: '',
        prefixIcon: prefixIcon,
        hintText: hintText,
        labelText: labelText,
        suffixIcon: suffixIcon,
        filled: filled,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(
            color: AppColor.kPrimary,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }
}
