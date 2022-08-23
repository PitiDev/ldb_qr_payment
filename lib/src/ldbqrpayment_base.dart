// TODO: Put public facing types in this file.

/// Checks if you are awesome. Spoiler: you are.
import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:http/http.dart' as http;
import 'package:pointycastle/asymmetric/api.dart';

class LDBPayment {
  tokenAuthentication(String user, String pass) async {
    var urlAuth =
        Uri.parse('https://dehome.ldblao.la/ldbpay/v1/authService/token');
    String username = user;
    String password = pass;
    var map = <String, dynamic>{};
    map['grant_type'] = 'client_credentials';
    var resToken =
        await http.post(urlAuth, body: map, headers: <String, String>{
      'Accept': 'application/json',
      'Authorization':
          'Basic ${base64Encode(utf8.encode('${username}:${password}'))}',
    });
    final bodyToken = json.decode(resToken.body);
    return bodyToken['access_token'];
  }

  getQR(
      String token,
      String merchID,
      String merchREF,
      int totalAmount,
      String additionalData,
      String urlBackData,
      String urlCallBackData,
      String remarkData) async {
    final data = jsonEncode({
      'merchId': merchID,
      'merchRef': merchREF,
      'amount': totalAmount,
      'additional': additionalData,
      'urlBack': urlBackData,
      'urlCallBack': urlCallBackData,
      'remark': remarkData,
    });

    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var resGetQR = await http.post(
        Uri.parse('https://dehome.ldblao.la/ldbpay/v1/payment/getLink.service'),
        body: data,
        headers: headers);
    final bodyQR = json.decode(resGetQR.body);
    if (resGetQR.statusCode == 200) {
      return bodyQR['dataResponse'];
    }
  }

  checkPayment(
    dynamic publicKeyPem,
    String merchID,
    String merchREF,
    String token,
    String userAuth,
  ) async {
    var dataBody = jsonEncode({
      'merchId': merchID,
      'refNumber': merchREF,
    });

    final publicKey = RSAKeyParser().parse(publicKeyPem) as RSAPublicKey;
    final encrypter = Encrypter(RSA(publicKey: publicKey));
    var text = '{\"merchId\":\"$merchID\",\"refNumber\":\"$merchREF\"}';

    final encrypted = encrypter.encrypt(text);
    print('encrypted : ${encrypted.base64}');

    Map<String, String> headers = {
      'Content-type': 'application/json',
      'ldb-Signature': 'keyId="$userAuth",signature="${encrypted.base64}"',
      'Authorization': "Bearer ${token}",
    };

    var resGetQR = await http.post(
      Uri.parse('https://dehome.ldblao.la/ldbpay/v1/payment/enquiry.service'),
      body: dataBody,
      headers: headers,
    );
    final bodyQR = json.decode(resGetQR.body);
    return bodyQR;
  }
}
