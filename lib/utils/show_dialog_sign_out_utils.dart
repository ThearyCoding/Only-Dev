import 'package:e_leaningapp/generated/l10n.dart';
import 'package:flutter/material.dart';

Future<bool?> showSignOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: Text(
          'Sign Out',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Theme.of(context).textTheme.bodyLarge!.color,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyMedium!.color,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text(
              'Yes',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: Text(
              'No',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium!.color,
              ),
            ),
          ),
        ],
      );
    },
  );
}


class LogOutDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  
  const LogOutDialog({super.key, required this.title, required this.message, this.icon});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
           icon != null ?  Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300]!.withOpacity(.4)
            ),
             child: Icon(
               icon,
                size: 35,
                color: Colors.red,
              ),
           ): const SizedBox.shrink(),
            const SizedBox(height: 20),
             Text(
             title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
             Text(
             message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child:  SizedBox(
                width: double.infinity,
                child: Center(
                  child: Text(
                  localization.yes_button,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child:  Text(
                    localization.no_button,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}