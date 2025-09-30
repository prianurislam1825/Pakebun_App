import 'package:flutter/widgets.dart';
import 'package:pakebun_app/common/theme/app_theme.dart';

class PagePadding extends StatelessWidget {
  final Widget child;
  final bool applyTop;
  final bool applyBottom;

  const PagePadding({
    super.key,
    required this.child,
    this.applyTop = false,
    this.applyBottom = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppTheme.spacingM,
        right: AppTheme.spacingM,
        top: applyTop ? AppTheme.spacingM : 0,
        bottom: applyBottom ? AppTheme.spacingM : 0,
      ),
      child: child,
    );
  }
}
