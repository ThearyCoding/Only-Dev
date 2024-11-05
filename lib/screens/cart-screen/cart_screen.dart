import 'dart:math' as math;

import 'package:e_leaningapp/export/curriculum_export.dart';
import 'package:e_leaningapp/utils/generate_color.dart';
import 'package:e_leaningapp/utils/show_error_utils.dart';
import 'package:e_leaningapp/widgets/buttons/custom_btn_loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<int> items = [];
  final User? user = FirebaseAuth.instance.currentUser;

  Color backgroundColor = Colors.white;
  Color textColor = Colors.black;
  String firstname = '';
  String lastname = '';

 

  // Function to fetch user color and names from Firestore
  void fetchUserColor() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    if (doc.exists) {
      String? colorHex = doc['backgroundColor'];
      String firstname = doc["firstName"] ?? '';
      String lastname = doc["lastName"] ?? '';

      if (colorHex != null) {
        Color userColor = Color(int.parse(colorHex.replaceFirst('#', '0xff')));
        setState(() {
          backgroundColor = userColor;
          textColor =GenerateColor.getContrastingTextColor(userColor);
          this.firstname = firstname;
          this.lastname = lastname;
        });
      }
    }
  }

  // Function to handle user login and save random color
  Future<void> onUserLogin() async {
    Color userColor =GenerateColor.generateRandomColor();
    String colorHex = '#${userColor.value.toRadixString(16).padLeft(6, '0')}';

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
      'backgroundColor': colorHex,
    }, SetOptions(merge: true));
  }

  @override
  void initState() {
    super.initState();
    onUserLogin();
    fetchUserColor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: const Text("Your cart"),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CircleAvatar(
                backgroundColor: backgroundColor,
                child: Text(
                  '${firstname.isNotEmpty ? firstname[0] : ''}${lastname.isNotEmpty ? lastname[0] : ''}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            items.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                      shrinkWrap: false,
                      itemCount: items.length,
                      itemBuilder: (ctx, index) {
                        return Slidable(
                          key: ValueKey(items[index]),
                          endActionPane: ActionPane(
                            dismissible: DismissiblePane(
                              onDismissed: () {
                                setState(() {
                                  items.removeAt(index);
                                });
                              },
                            ),
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  setState(() {
                                    items.removeAt(index);
                                  });
                                },
                                backgroundColor: const Color(0xFFFE4A49),
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Delete',
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Color(
                                      (math.Random().nextDouble() * 0xFFFFFF)
                                          .toInt())
                                  .withOpacity(1.0),
                            ),
                            title: Text(
                              "items: ${index + 1}",
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : const Expanded(
                    child: Center(child: Text("Your Cart is empty")))
          ],
        ),
        bottomSheet: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomBtnLoadingWidget(
                btnText: "Check Out",
                borderRadius: 8,
                backgroundColor: Colors.green,
                onTap: (startLoading, stopLoading, btnstate) async {
                  startLoading;

                  await onUserLogin();

                  showSnackbar("Success!");
                  stopLoading;
                },
              ),
            ],
          ),
        ));
  }
}
