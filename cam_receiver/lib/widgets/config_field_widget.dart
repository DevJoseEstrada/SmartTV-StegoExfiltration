import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FieldConfigWidget extends StatelessWidget {
  final String label;
  final String hintText;
  final Function(String)? onChanged;

  const FieldConfigWidget(
      {super.key, required this.label, required this.onChanged, required this.hintText});

 @override
  Widget build(BuildContext context) {
    return Wrap(
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 6.0,
    runSpacing: 6.0,
    children: [
      Container(
        alignment: Alignment.center,
        width: 100,
        child: Text(
          textAlign: TextAlign.center,
          label,
          style: const TextStyle(fontSize: 14),
        ),
      ),
      Container(
        alignment: Alignment.center,
        width: 75,
        child: TextField(
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: onChanged,
          decoration: InputDecoration(
            
            hintText: hintText,
            border: const OutlineInputBorder(),
          ),
        ),
      ),
    ],
  );
  }
}
