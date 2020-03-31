import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:paycrypta/constants.dart';
import 'package:paycrypta/components/rounded_button.dart';
import 'package:paycrypta/screens/main_screen.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:paycrypta/components/decimal_input_formatter.dart';

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
  bool isAlerted = false;
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
                        .toStringAsFixed(2);

                _firestore
                    .collection('balance')
                    .document(doc.documentID)
                    .updateData({'balance': newBalance});
                isDone = true;
              }
            }));
  }

  void addNewTransactionToDataBase() {
    if (amount != '0') {
      _firestore.collection('transactions').add({
        'sender': loggedInUser.email,
        'receiver': receiver,
        'amount': amount,
      });
    }
  }

  Future<bool> updateBalanceOfReceiver() async {
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
                        .toStringAsFixed(2);

                _firestore
                    .collection('balance')
                    .document(doc.documentID)
                    .updateData({'balance': newBalance});
                updateBalanceOfSender();
                addNewTransactionToDataBase();
                showSuccessAlert();
                isDone = true;
                return true;
              }
              return false;
            }));
  }

  void showSuccessAlert() {
    Alert(
      context: context,
      type: AlertType.success,
      title: "Payment Sucessfull",
      desc: "",
      buttons: [
        DialogButton(
          child: Text(
            "Okay",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
        )
      ],
    ).show();
  }

  void failAlert() {
    Alert(
      context: context,
      type: AlertType.error,
      title: "Something Went Wrong",
      desc: "Please Check It Out",
      buttons: [
        DialogButton(
          child: Text(
            "Okay",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
        )
      ],
    ).show();
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
                inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
                textAlign: TextAlign.center,
                onChanged: (value) {
                  amount = double.parse(value).toStringAsFixed(2);
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
                  receiver = value.toString();
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
                  if (receiver != null &&
                      double.parse(MainScreen.oldBalance) >=
                          double.parse(amount)) {
                    isAlerted = await updateBalanceOfReceiver();
                  }

                  if (isAlerted == false) {
                    failAlert();
                  } else {
                    isAlerted = false;
                  }
                  setState(() {});
                } catch (Exception) {
                  print('bura mi');
                  failAlert();
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
