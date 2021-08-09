import 'package:flutter/material.dart';

class Badge extends StatelessWidget {

  final Widget child;
  final String value;
  final Color color;

  const Badge({@required this.child, @required this.value, this.color });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Positioned(
          right: 5,
          top: 5,
          child: CircleAvatar(
            //maxRadius: 9,
            minRadius: 8,
            backgroundColor: color != null ? color : Theme.of(context).accentColor,
            foregroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text(value, textAlign: TextAlign.center, style: TextStyle( fontSize: 12 ),),
            ),
          ),
        )
      ],
    );
  }
}
