import 'package:flutter/material.dart';
import 'package:mynote/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context, 
    title: "Delete Note", 
    content: "Are you sure to delete this note?", 
    optionBuilder: () => {
      "Cancel": false,
      "Delete" : true
    }).then((value) => value ?? false);
}