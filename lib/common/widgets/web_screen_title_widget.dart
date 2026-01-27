import 'package:flutter/material.dart';
import 'package:lestar_user/helper/responsive_helper.dart';
import 'package:lestar_user/util/dimensions.dart';
import 'package:lestar_user/util/styles.dart';


class WebScreenTitleWidget extends StatelessWidget {
  final String title;
  const WebScreenTitleWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.isDesktop(context) ? Container(
      height: 64,
      color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
      child: Center(child: Text(title, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600))),
    ) : const SizedBox();
  }
}
