import 'package:flutter/material.dart';
import 'package:nutricount/constants/app_colors.dart';

// ignore: must_be_immutable
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.action,
    this.showLeading = true,
  });
  final String? title;
  final Widget? titleWidget;
  final Widget? action;
  bool showLeading;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColor.primary,
      leading: showLeading
          ? IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 25,
              ))
          : SizedBox(),
      centerTitle: true,
      leadingWidth: showLeading ? null : 0,
      actions: [action ?? SizedBox()],
      title: titleWidget ??
          Text(
            title ?? '',
            style: const TextStyle(
                fontSize: 22,
                letterSpacing: 0.5,
                color: Colors.white,
                fontWeight: FontWeight.w500),
          ),
    );
  }
}
