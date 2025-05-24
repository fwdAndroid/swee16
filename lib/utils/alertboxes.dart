import 'package:flutter/material.dart';
import 'package:swee16/utils/color_platter.dart';

Future<void> deleteAlert(BuildContext context) async {
  await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Practice Data'),
        content: const Text(
          'Are you sure you want to delete all practice data? This cannot be undone.',
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel', style: TextStyle(color: mainColor)),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Delete', style: TextStyle(color: red)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      );
    },
  );
}

//Save Session
Future<void> saveSession(BuildContext context) async {
  await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Save Practice'),
        content: const Text(
          'Are you sure you want to save this practice session?',
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel', style: TextStyle(color: red)),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Save', style: TextStyle(color: mainColor)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      );
    },
  );
}
