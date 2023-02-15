<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

## Features

Lao Development Bank E-Commerce payment

- generate qr code for scan payment with app LDB Trust
- deeplink payment with app LDB Trust
- Check status transaction realtime
- check status payment with api auth by public key


## Getting started

ຂັ້ນຕອນການຂໍຊຳລະເງິນ online ຜ່ານ LDB QR Payment:

- ເຮັດໃບສະເຫນີເຂົ້າມາຂໍເຊື່ອມຕໍ່ QR payment ກັບ ທະນາຄານພັດທະນາລາວ
- ເຈລະຈາຕົກລົງຄ່າທຳນຽມ ແລະ ການເຊັນສັນຍາຮ່ວມມື
- ຝາຍໄອທີຈະສ້າງ Merchant ID ໃຫ້ເພື່ອຊຳລະເງິນແທ້

## Usage

ລຸ່ມນີ້ແມ່ນ  Example Code ທ່ານສາມາດນຳໄປທົດລອງໄດ້ທັນທີ

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:ldb_qr_payment/ldb_qr_payment.dart';
import 'package:pubnub/pubnub.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LDB QR Payment',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LDBPAY(),
    );
  }
}

//for example
class LDBPAY extends StatefulWidget {
  @override
  State<LDBPAY> createState() => _LDBPAYState();
}

class _LDBPAYState extends State<LDBPAY> {
  // for user basic authentication
  String userAuth = 'APPLINK';
  String passAuth = 'T2C%tL81oxN3N!H5Aby9';

  //for data payment
  String merchId = 'LDB0302000001';
  String merchRef = 'pitix99piti';
  int amount = 1;
  String additional = 'testpayment';
  String urlBack = 'https://preh5.newpay.la/scale/success.html';
  String urlCallBack = 'https://app.ldblao.la/?status=success';
  String remark = 'payment 1000kip';

  late String token,
      linkPayment = '',
      qrScan = '',
      dataResponse = '',
      dataResponseRealtime = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTokenAuthen();
    checkPaymentRealtime();
  }

  void getTokenAuthen() async {
    // Note: Parameter
    // 1 user    ----> LDB bank create a user to you (user test: APPLINK)
    // 2 pass    ----> LDB bank create a pass to you (pass test: T2C%tL81oxN3N!H5Aby9)
    final getToken = await LDBPayment().tokenAuthentication(userAuth, passAuth);
    print('LDB TOKEN: $getToken');
    setState(() {
      token = getToken;
      getQRcode(getToken);
    });
  }

  void getQRcode(String LDBToken) async {
    // Note: Parameter
    // 1 token
    // 2 merchId
    // 3 merchRef
    // 4 amount
    // 5 additional
    // 6 urlBack
    // 7 urlCallBack
    // 8 remark
    final dataQR = await LDBPayment().getQR(LDBToken, merchId, merchRef, amount,
        additional, urlBack, urlCallBack, remark);
    print(dataQR);

    setState(() {
      linkPayment = dataQR['link'];
      qrScan = dataQR['qr'];
    });
  }

  Future<void> _openAppTrust() async {
    if (!await launchUrl(Uri.parse(linkPayment))) {
      throw 'Could not launch $linkPayment';
    }
  }

  void checkQrPayment() async {
    // Note: Parameter
    // 1 public_key.pem
    // 2 merchId
    // 3 merchRef
    // 4 token
    // 5 user
    final publicPem = await rootBundle.loadString('assets/public_key.pem');
    final dataRes = await LDBPayment()
        .checkPayment(publicPem, merchId, merchRef, token, userAuth);
    print('RES: ${dataRes}');
    setState(() {
      dataResponse = dataRes.toString();
    });
  }

  // for subscribe realtime check payment success with PubNub
  // Before you can use this function, you need to install the Package flutter PubNub
  void checkPaymentRealtime()async{
    final refCheck = 'merchId-$merchId-refNumber-$merchRef';
    var pubnub = PubNub(
      defaultKeyset: Keyset(
        subscribeKey: 'sub-c-e8e87ff5-d6ac-4746-89fa-a61636721cbd',
        uuid: const UUID('LDBBANK'),
      ),
    );
    // Subscribe to a channel
    var subscription =
    pubnub.subscribe(channels: {refCheck});
    subscription.messages.listen((envelope) async {
      setState(() async{
        print('LDB Res = ${envelope.payload}');
        dataResponseRealtime = envelope.payload.toString();
        await subscription.dispose();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            children: [
              SizedBox(
                height: 10,
              ),
              const Center(
                child: Text('LDB QR Payment',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Image.network(qrScan),
              ),
              Container(
                margin: const EdgeInsets.all(10),
                child: MaterialButton(
                  color: Colors.blue,
                  onPressed: () {
                    //ນຳໃຊ້ package url_launcher: ^6.1.5 ເພື່ອທຳການ link open app LDB Trust ເພື່ອຊຳລະເງິນ
                    _openAppTrust();
                  },
                  child: const Text('Payment With LDB Trust'),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(10),
                child: MaterialButton(
                  color: Colors.green,
                  onPressed: () {
                    checkQrPayment();
                    checkPaymentRealtime();
                  },
                  child: const Text('Check QR Payment'),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(10),
                child: const Text(
                  'Data Callback Response:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(10),

                child: Text(dataResponse),
              ),
              Divider(),
              Container(
                margin: const EdgeInsets.all(10),
                child: const Text(
                  'Data Callback Response Realtime:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(10),
                child: Text(dataResponseRealtime),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


```


