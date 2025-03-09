import 'package:flutter/material.dart';
import 'package:mynote/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context, 
    title: "Logout", 
    content: "Are you sure to logout now?", 
    optionBuilder: () => {
      "Cancel": false,
      "Log out" : true
    }).then((value) => value ?? false);
}