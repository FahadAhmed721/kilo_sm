import 'package:flutter/material.dart';
import 'package:kiloi_sm/utils/app_colors.dart';

class CustomTextField extends StatelessWidget {
  String title;
  Function onSaved;
  FocusNode focusNode;
  FocusNode? nextFocusNode;
  bool isReadOnly;
  final bool isObscure;
  TextInputType keyboardType;
  FormFieldValidator<String> validator;
  Function(String newVal) onChange;
  TextEditingController controller;
  Widget suffixIcon;
  int? maxLines;
  CustomTextField(
      {required this.title,
      required this.controller,
      required this.focusNode,
      required this.keyboardType,
      this.maxLines,
      this.isObscure = false,
      required this.isReadOnly,
      required this.onChange,
      required this.nextFocusNode,
      required this.onSaved,
      required this.validator,
      required this.suffixIcon,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: AppColors.fieldBorderColor)),
      child: TextFormField(
        maxLines: maxLines ?? null,
        minLines: 1,
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        cursorColor: AppColors.appThemeColor,
        obscureText: isObscure,

        //textAlign: TextAlign.center,
        readOnly: isReadOnly,
        // style: TextStyle(
        //     fontFamily: 'Avenir',
        //     color: Colors.black,
        //     fontSize: 20.sp,
        //     fontWeight: FontWeight.bold),

        decoration: InputDecoration(
            suffixIcon: suffixIcon,
            suffixIconConstraints: const BoxConstraints(
              maxHeight: 15,
            ),
            focusColor: AppColors.appThemeColor,
            hintText: title,
            // fillColor: MyColors.giftCardDetailsClr,
            isDense: true,
            // filled: true,
            hintStyle: const TextStyle(
              color: AppColors.fieldHintColor,
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
            border: InputBorder.none),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
        textInputAction:
            nextFocusNode == null ? TextInputAction.done : TextInputAction.next,
        onFieldSubmitted: (_) {
          FocusScope.of(context).unfocus();
          nextFocusNode == null
              ? FocusScope.of(context).unfocus()
              : FocusScope.of(context).requestFocus(nextFocusNode);
        },
        validator: (value) => validator(value),
        onSaved: (value) {},
        onChanged: (value) {
          onChange(value);
        },
      ),
    );
  }
}
