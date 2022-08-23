import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:ldb_qr_payment/ldb_qr_payment.dart';
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
  late String token, linkPayment = '', qrScan = '', dataResponse = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTokenAuthen();
  }

  void getTokenAuthen() async {
    // Note: Parameter
    // 1 user    ----> LDB bank create a user to you (user test: APPLINK)
    // 2 pass    ----> LDB bank create a user to you (pass test: T2C%tL81oxN3N!H5Aby9)
    final getToken = await LDBPayment()
        .tokenAuthentication('APPLINK', 'T2C%tL81oxN3N!H5Aby9');
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
    final dataQR = await LDBPayment().getQR(
        LDBToken,
        'LDB0302000001',
        'txt123456',
        1,
        'testpayment',
        'https://preh5.newpay.la/scale/success.html',
        'https://app.pitidev.com/?status=success',
        'payment 1000kip');
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
    final dataRes = await LDBPayment().checkPayment(
        publicPem, 'LDB0302000001', 'txt123456', token, 'APPLINK');
    print('RES: ${dataRes}');
    setState(() {
      dataResponse = dataRes.toString();
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
                height: 300,
                child: Text(dataResponse),
              )
            ],
          ),
        ),
      ),
    );
  }
}
