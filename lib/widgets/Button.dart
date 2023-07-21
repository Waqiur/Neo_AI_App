import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  const Button({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        height: 50,
        margin: const EdgeInsets.only(bottom: 10),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade900,
            elevation: 1,
            shadowColor: Colors.grey,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ).copyWith(
            overlayColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed)) {
                  return Colors.grey.shade800;
                }
                return null;
              },
            ),
          ),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 10,),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
