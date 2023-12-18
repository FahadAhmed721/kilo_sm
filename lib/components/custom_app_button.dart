import 'package:flutter/material.dart';
import 'package:kiloi_sm/utils/app_colors.dart';

class CustomButton extends StatelessWidget {
  GestureTapCallback onTap;
  String title;
  CustomButton({required this.onTap, required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
            color: AppColors.appThemeColor,
            borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
