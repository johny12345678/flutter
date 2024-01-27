import 'package:cvapp/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<void> errorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog(
    context: context,
    title: 'An error occured',
    content: text,
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
