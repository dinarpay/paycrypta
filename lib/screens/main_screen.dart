import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
                  List<Text> tWidgets = [];
                  for (var transaction in transactions) {
                    final sender = transaction.data['sender'];
                    final receiver = transaction.data['receiver'];
                    final amount = transaction.data['amount'];
                    if (sender == loggedInUser.email) {
                      final tWidget = Text('$amount sent to $receiver');
                      tWidgets.add(tWidget);
                    } else if (receiver == loggedInUser.email) {
                      final tWidget = Text('$amount received from  $sender');
                      tWidgets.add(tWidget);
                    }
                  }

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
