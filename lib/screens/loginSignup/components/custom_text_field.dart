import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../constants/colors.dart';

class CustomTextFormField extends StatefulWidget {
  final String hintKey;
  final String? Function(String?)? validation;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool isPassword;
  final bool isDropdown;
  final List<String>? dropdownItems;
  final void Function(String?)? onSaved;
  final void Function(String?)? onChanged;

  const CustomTextFormField({
    super.key,
    required this.hintKey,
    this.validation,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.isDropdown = false,
    this.dropdownItems,
    this.onSaved,
    this.onChanged,
  });

  @override
  CustomTextFormFieldState createState() => CustomTextFormFieldState();
}

class CustomTextFormFieldState extends State<CustomTextFormField> {
  bool isHidden = true;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: screenWidth * 0.98, // 98% width of the screen
          height: 60, // Fixed height
          child: widget.isDropdown && widget.dropdownItems != null
              ? _buildDropdownField()
              : _buildTextField(),
        ),
      ],
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value:
      widget.dropdownItems!.isNotEmpty ? widget.dropdownItems!.first : null,
      onChanged: widget.onChanged,
      items: widget.dropdownItems!.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: TextStyle(fontSize: 16, color: AppColors.hintColor),
          ),
        );
      }).toList(),
      dropdownColor: Colors.white,
      style: TextStyle(fontSize: 16, color: AppColors.hintColor),
      decoration: _buildInputDecoration(widget.hintKey).copyWith(
        hintText: null,
      ),
      validator: widget.validation,
      onSaved: widget.onSaved,
      icon: Icon(Icons.arrow_drop_down, color: AppColors.iconColor),
      isExpanded: true,
    );
  }

  Widget _buildTextField() {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.isPassword ? isHidden : false,
      decoration: _buildInputDecoration(widget.hintKey),
      validator: widget.validation,
      onSaved: widget.onSaved,
      onChanged: widget.onChanged,
      cursorColor: AppColors.primaryColor,
      cursorHeight: 20,
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      suffixIcon: widget.isPassword
          ? Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GestureDetector(
          onTap: () {
            setState(() {
              isHidden = !isHidden;
            });
          },
          child: Icon(
            isHidden
                ? FontAwesomeIcons.solidEye
                : FontAwesomeIcons.eyeSlash,
            color: AppColors.hintColor,
            size: 18,
          ),
        ),
      )
          : null,
      suffixIconConstraints: const BoxConstraints(minHeight: 0, minWidth: 0),
      fillColor: AppColors.surfaceColor,
      filled: true,
      hintText: hint,
      isDense: false,
      hintStyle: const TextStyle(color: AppColors.hintColor),
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      alignLabelWithHint: true,
      errorStyle: const TextStyle(height: 0),
      helperText: ' ',
      errorMaxLines: 1,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: BorderSide(color: AppColors.iconColor, width: 0.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: BorderSide(color: AppColors.iconColor, width: 0.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: BorderSide(color: AppColors.primaryColor, width: 0.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: const BorderSide(color: Colors.red, width: 0.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
    );
  }
}
