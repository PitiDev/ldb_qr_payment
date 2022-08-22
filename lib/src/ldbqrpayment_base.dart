// TODO: Put public facing types in this file.

/// Checks if you are awesome. Spoiler: you are.
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class LDBPayment {

  late String token;

  getQR(String merchID, String merchREF, int totalAmount, String additionalData,
      String urlBackData, String urlCallBackData, String remarkData) async {
    final data = jsonEncode({
      'merchId': merchID,
      'merchRef': merchREF,
      'amount': totalAmount,
      'additional': additionalData,
      'urlBack': urlBackData,
      'urlCallBack': urlCallBackData,
      'remark': remarkData,
    });

    var urlAuth =
    Uri.parse('https://dehome.ldblao.la/ldbpay/v1/authService/token');
    String username = 'APPLINK';
    String password = 'T2C%tL81oxN3N!H5Aby9';
    var map = <String, dynamic>{};
    map['grant_type'] = 'client_credentials';
    var resToken =
    await http.post(urlAuth, body: map, headers: <String, String>{
      'Accept': 'application/json',
      'Authorization':
      'Basic ${base64Encode(utf8.encode('${username}:${password}'))}',
    });
    final bodyToken = json.decode(resToken.body);

    token = await bodyToken['access_token'];
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Authorization': 'Bearer ${bodyToken['access_token']}',
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
}
