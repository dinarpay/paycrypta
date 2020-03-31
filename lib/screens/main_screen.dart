import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:paycrypta/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:paycrypta/screens/send_screen.dart';
import 'package:string_scanner/string_scanner.dart';

class MainScreen extends StatefulWidget {
  static const String id = 'main_screen';
  static String oldBalance;
  @override
  _MainScreenState createState() => _MainScreenState();
}

final _firestore = Firestore.instance;
String balance;
FirebaseUser loggedInUser;

class _MainScreenState extends State<MainScreen> {
  final _auth = FirebaseAuth.instance;
  String balanceString;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
    //getBalance();
  }

  void getBalance() async {
    await for (var snapshot in _firestore.collection('balance').snapshots()) {
      for (var balances in snapshot.documents) {
        if (balances.data['user'] == loggedInUser.email) {
          balance = balances.data['balance'].toString();
        }
      }
    }
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (Exception) {
      print(Exception);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.account_balance_wallet),
              onPressed: () {
                //Implement logout functionality
              }),
        ],
        title: Text('⚡PayCrypta'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('balance').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final balances = snapshot.data.documents;
                      List<Text> balanceWidgets = [];
                      for (var balance in balances) {
                        final balanceText = balance.data['balance'];
                        MainScreen.oldBalance = balanceText;
                        final balanceOwner = balance.data['user'];
                        if (balanceOwner == loggedInUser.email) {
                          return Text(
                            '$balanceText',
                            style: kBigtexts,
                          );
                        }
                      }
                    }
                    return Text(
                      '0',
                      style: kBigtexts,
                    );
                  },
                ),
                Container(
                  child: Text(
                    ' \$',
                    style: kBigtexts,
                  ),
                ),
              ],
            ),
            SizedBox(height: 0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(),
                Container(
                  child: FlatButton(
                    child: Icon(
                      Icons.send,
                      color: Colors.green,
                      size: 48.0,
                      semanticLabel: 'Text to announce in accessibility modes',
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, SendScreen.id);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),
            Text(
              'TRANSACTIONS',
            ),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('transactions').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final transactions = snapshot.data.documents;
                  List<TransactionBubble> tWidgets = [];
                  TransactionBubble tWidget;
                  for (var transaction in transactions) {
                    final sender = transaction.data['sender'];
                    final receiver = transaction.data['receiver'];
                    final amount = transaction.data['amount'];

                    if (sender == loggedInUser.email) {
                      final tWidget = TransactionBubble(
                        messageText: Text(
                          '$amount sent to $receiver',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      );
                      tWidgets.add(tWidget);
                    } else if (receiver == loggedInUser.email) {
                      final tWidget = TransactionBubble(
                        messageText: Text(
                          '$amount received from $sender',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      );
                      tWidgets.add(tWidget);
                    }
                  }
                  print(tWidgets);
                  return Expanded(
                    child: ListView(
                        padding: EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 10.0),
                        children: tWidgets),
                  );
                }
                return Text(
                  'There is no transaction made yet',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionBubble extends StatelessWidget {
  final Text messageText;

  TransactionBubble({this.messageText});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(2.0),
      child: Material(
        borderRadius: BorderRadius.circular(10.0),
        color: Color(0X0FB8ac6d1),
        child: Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
            child: messageText),
      ),
    );
  }
}
