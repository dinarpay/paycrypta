import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:paycrypta/constants.dart';
import 'package:paycrypta/components/rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paycrypta/screens/main_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:bip39/bip39.dart' as bip39;

class SendScreen extends StatefulWidget {
  static const String id = 'send_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<SendScreen> {
  //final _auth = FirebaseAuth.instance;
  final _firestore = Firestore.instance;
  String amount;
  String balance;
  String receiver;

  void updateBalanceOfSender() async {
    String newBalance;
    bool isDone = false;
    _firestore
        .collection('balance')
        .where('user', isEqualTo: loggedInUser.email)
        .snapshots()
        .listen((data) => data.documents.forEach((doc) {
              if (isDone == false) {
                newBalance =
                    (double.parse(MainScreen.oldBalance) - double.parse(amount))
                        .toString();

                _firestore
                    .collection('balance')
                    .document(doc.documentID)
                    .updateData({'balance': newBalance});
                isDone = true;
              }
            }));
  }

  void updateBalanceOfReceiver() {
    String newBalance;
    bool isDone = false;
    _firestore
        .collection('balance')
        .where('user', isEqualTo: receiver)
        .snapshots()
        .listen((data) => data.documents.forEach((doc) {
              if (isDone == false) {
                newBalance =
                    (double.parse(doc.data['balance']) + double.parse(amount))
                        .toString();
                print('-----$newBalance');
                _firestore
                    .collection('balance')
                    .document(doc.documentID)
                    .updateData({'balance': newBalance});
                isDone = true;
              }
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.list),
              onPressed: () {
                //Implement logout functionality
              }),
        ],
        title: Text('⚡PayCrypta'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 48.0,
            ),
            Container(
              child: TextField(
                textAlign: TextAlign.center,
                onChanged: (value) {
                  amount = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'How Much BTC will you send?'),
              ),
            ),
            SizedBox(
              height: 24.0,
            ),
            Container(
              child: TextField(
                textAlign: TextAlign.center,
                onChanged: (value) {
                  receiver = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter The Email Of Receiver'),
              ),
            ),
            RoundedButton(
              colour: Colors.lightBlueAccent,
              title: 'Send',
              onPressed: () async {
                try {
                  if (1 == 1) {
                    updateBalanceOfSender();
                    updateBalanceOfReceiver();
                    _firestore.collection('transactions').add({
                      'sender': loggedInUser.email,
                      'receiver': receiver,
                      'amount': amount,
                    });
                  } else {}
                  setState(() {});
                } catch (Exception) {}
              },
            )
          ],
        ),
      ),
    );
  }
}
