import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:only_dev_app/features/profile/provider/user_provider.dart';
import 'package:only_dev_app/utils/generate_color.dart';
import 'package:only_dev_app/utils/app_toast_utils.dart';
import 'package:only_dev_app/widgets/buttons/custom_btn_loading_widget.dart';
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

  void fetchUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.userModel ?? userProvider.user;
    if (currentUser != null) {
      setState(() {
        firstname = currentUser.firstName;
        lastname = currentUser.lastName;
        backgroundColor = GenerateColor.generateRandomColor();
        textColor = GenerateColor.getContrastingTextColor(backgroundColor);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchUserData();
    });
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
                  AppToastUtils.success("Success!");
                  stopLoading;
                },
              ),
            ],
          ),
        ));
  }
}
