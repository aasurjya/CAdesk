import 'package:flutter/material.dart';

import 'package:ca_app/features/clients/domain/models/client_type.dart';

class ClientAvatar extends StatelessWidget {
  const ClientAvatar({
    super.key,
    required this.initials,
    required this.clientType,
    this.radius = 22,
    this.fontSize = 14,
  });

  final String initials;
  final ClientType clientType;
  final double radius;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: clientType.color.withAlpha(30),
      child: Text(
        initials,
        style: TextStyle(
          color: clientType.color,
          fontWeight: FontWeight.w700,
          fontSize: fontSize,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
