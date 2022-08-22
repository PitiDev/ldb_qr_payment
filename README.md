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

TODO: Put a short description of the package here that helps potential users
know whether this package might be useful for them.

## Features
Lao Development Bank E-Commerce payment
- generate qr code for scan payment with app LDB Trust
- deeplink payment with app LDB Trust
- check status payment with public key

TODO:
 - Check status transaction
 - 
## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder. 

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LDB QR Payment',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LDBPAY(),
    );
  }
}

//for example
class LDBPAY extends StatefulWidget {
  const LDBPAY({Key? key}) : super(key: key);

  @override
  State<LDBPAY> createState() => _LDBPAYState();
}

class _LDBPAYState extends State<LDBPAY> {
  late String linkPayment = '', qrScan = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getQRcode();
  }

  void getQRcode() async {
    // Note: Parameter
    // 1 merchId
    // 2 merchRef
    // 3 amount
    // 4 additional
    // 5 urlBack
    // 6 urlCallBack
    // 7 remark
    final dataQR = await LDBPayment().getQR('LDB0302000001', 'merchRef 22', 1,
        'additional 44', 'urlBack 55', 'urlCallBack 66', 'remark77');
    print(dataQR);

    setState(() {
      linkPayment = dataQR['link'];
      qrScan = dataQR['qr'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            children: [
              InkWell(
                onTap: () {},
                child: Image.network(qrScan),
              ),
              Container(
                margin: const EdgeInsets.all(10),
                child: MaterialButton(
                  color: Colors.blue,
                  onPressed: () {
                    getQRcode();
                  },
                  child: Text('GET LDB QR PAYMENT'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

```

## Additional information

TODO: Tell users more about the package: where to find more information, how to 
contribute to the package, how to file issues, what response they can expect 
from the package authors, and more.
