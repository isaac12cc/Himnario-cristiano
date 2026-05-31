import 'package:flutter/material.dart';
import '../models/himno.dart';

class HimnoAvatar extends StatelessWidget {
  final Himno himno;
  final double radius;

  const HimnoAvatar({
    super.key,
    required this.himno,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "himno_${himno.id}",
      child: CircleAvatar(
        radius: radius,
        child: Text(himno.numero.toString()),
      ),
    );
  }
}