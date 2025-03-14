import 'package:flutter/material.dart';

typedef DialogOptionBuilder <T> = Map<String, T?> Function();

Future<T?> showGenericDialog<T>({
    required BuildContext context, 
    required String title, 
    required String content,
    required DialogOptionBuilder<T> optionBuilder
    }) {
    final options = optionBuilder();
    return showDialog<T>(
        context: context, 
        builder: (context) {
            return AlertDialog(
                title: Text(title),
                content: Text(content),
                actions: options.keys.map((optionTitle) {
                    final T option = options[optionTitle]!;
                    return TextButton(
                        onPressed: () {
                            if (option != null) {
                                Navigator.of(context).pop(option);
                            } else {
                                Navigator.of(context).pop();
                            }
                        },
                        child: Text(optionTitle),
                    );
                }).toList(),
            );
        });
}