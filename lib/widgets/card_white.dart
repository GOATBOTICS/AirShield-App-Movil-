  import 'package:flutter/material.dart';

class CardWhite extends StatelessWidget {
  final Widget child;
  final double? borroso;
  final Color? color;
  final bool? isCircular;

  const CardWhite({
    super.key,
    required this.child,
    this.borroso,
    this.color,
    this.isCircular,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: isCircular != null
            ? isCircular!
                ? BorderRadius.circular(20)
                : null
            : BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: borroso ?? 15,
            offset: Offset(0, 0), // changes position of shadow
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: child,
    );
  }
}
