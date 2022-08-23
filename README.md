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
- check status payment with public key

TODO:
-  Check status transaction realtime
-

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
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

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

```

## Code Encrypt ລຸ່ມນີ້ແມ່ນໃຊ້ສຳລັບຢູ່ຝັ່ງ Backend 
public key ສຳລັບໄວ້ທົດລອງການດຶງຂໍ້ມູນກວດສອບທຸລະກຳ

```` dart
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApL8zynFJXiS1+tZpgBaF
bVeITB2951zYSq1/9yVTFXelAoBA+8t2D38GsJDoQi/sIdxDYRmO4TDAoFTIOHqm
NNQBZTSGnr4jf7VarIF4nK3aFH+sJq1noCiHPHvPZTC3kwl4kX+d3pbs0zO50ZYn
bTV/8/QoeOJOgwbw8890FKShv4pEA8FAydB6HYJIjqI3HzYWz1NibR3sud6fmbkx
iMpIbjTJNDmXGU5/vH4pb8ofiHbXOa4iDWNUUmg1LUXUQuZQOW/Pr+JAUGoDcI3d
LIYVdThJNYdmVnUntEwU3+jcG0J9FUbZNU9fODeimjckDGUGgSranL8+rzaKog64
jwIDAQAB
-----END PUBLIC KEY-----

````

Code NodeJS ສຳລັບການເຂົ້າລະຫັດດ້ວຍ Public key ທີ່ທ່າງ LDB ຈະສ້າງ public key ໃຫ້ເພື່ອສົ່ງມາຮ້ອງຂໍຂໍ້ມູນທຸລະກຳທີ່ຕ້ອງການກວດສອບ:

```dart
const path = require("path");
const fs = require("fs");
const forge = require("node-forge");

function encryptStringWithRsaPublicKey(text) {
    const absolutePath = path.resolve('public.pem');
    const publicKeyFile = fs.readFileSync(absolutePath, 'utf-8');

    var pki = forge.pki;
    // convert a PEM-formatted public key to a Forge public key
    var publicKey = pki.publicKeyFromPem(publicKeyFile);
    const encrypted = publicKey.encrypt(text);
    console.log("encrypted:", forge.util.encode64(encrypted));

    return forge.util.encode64(encrypted);
};


function decryptStringWithRsaPrivateKey(toDecrypt) {
    
};

module.exports = encryptStringWithRsaPublicKey('{\"merchId\":\"LDB0302000001\",\"refNumber\":\"pitix99\"}');

```

Code Java ສຳລັບການເຂົ້າລະຫັດດ້ວຍ Public key ທີ່ທ່າງ LDB ຈະສ້າງ public key ໃຫ້ເພື່ອສົ່ງມາຮ້ອງຂໍຂໍ້ມູນທຸລະກຳທີ່ຕ້ອງການກວດສອບ:
````dart
public class EncodeDataExam {

    private static Cipher cipher;

    public PrivateKey getPrivate(String filename) throws Exception {
        byte[] keyBytes = Files.readAllBytes(new File(filename).toPath());
        PKCS8EncodedKeySpec spec = new PKCS8EncodedKeySpec(keyBytes);
        KeyFactory kf = KeyFactory.getInstance("RSA");
        return kf.generatePrivate(spec);
    }

    public String encryptText(String msg, PrivateKey key)
            throws UnsupportedEncodingException, IllegalBlockSizeException,
            BadPaddingException, InvalidKeyException {

        cipher.init(Cipher.ENCRYPT_MODE, key);
        String encrypt = Base64.encodeBase64String(cipher.doFinal(msg.getBytes("UTF-8")));

        return encrypt;

    }

    public static void main(String[] args) throws Exception {
        EncodeDataExam ac = new EncodeDataExam();
        PrivateKey privateKey = ac.getPrivate("public");

        String msg = "{\"merchId\":\"LDB0302000001\",\"refNumber\":\"pitix99\"}";
        String encrypted_msg = ac.encryptText(msg, privateKey);
        System.out.println("Encode = " + encrypted_msg);
    }

}
````

Code Golang ສຳລັບການເຂົ້າລະຫັດດ້ວຍ Public key ທີ່ທ່າງ LDB ຈະສ້າງ public key ໃຫ້ເພື່ອສົ່ງມາຮ້ອງຂໍຂໍ້ມູນທຸລະກຳທີ່ຕ້ອງການກວດສອບ:
 ````dart

````


