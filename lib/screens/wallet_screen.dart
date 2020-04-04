import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paycrypta/constants.dart';
import 'package:paycrypta/components/rounded_button.dart';
import 'package:paycrypta/screens/main_screen.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:paycrypta/components/decimal_input_formatter.dart';

class WalletScreen extends StatefulWidget {
  static const String id = 'wallet_screen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<WalletScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        title: Text('⚡PayCrypta'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Text(
              'Public Key',
              style: kBigtexts2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  MainScreen.wallId,
                  style: TextStyle(fontSize: 16.0),
                ),
                IconButton(
                    icon: Icon(Icons.content_copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: MainScreen.wallId));
                    }),
              ],
            ),
            Text(
              'Wallet Satoshis:' + MainScreen.wallBalance,
              style: TextStyle(fontSize: 19.0),
            ),
            Text('BTC Price In Usd:' + MainScreen.usdPrice,
                style: TextStyle(fontSize: 19.0)),
            FlatButton(
              child: Text('Convert It To Usd'),
              onPressed: () {},
            ),
            TextField(
              keyboardType: TextInputType.emailAddress,
              textAlign: TextAlign.center,
              onChanged: (value) {
                //Do something with the user input.
              },
              decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter Your BTC Wallet'),
            ),
            FlatButton(
              child: Text('Withdraw Your BTC'),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
