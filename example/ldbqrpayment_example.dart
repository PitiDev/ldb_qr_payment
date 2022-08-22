import 'package:ldbqrpayment/ldbqrpayment.dart';

void main() async {
  // Note: Parameter
  // 1 merchId
  // 2 merchRef
  // 3 amount
  // 4 additional
  // 5 urlBack
  // 6 urlCallBack
  // 7 remark
  final dataQR = await LDBPayment().getQR(
      'LDB0302000001',
      'txt123456',
      10000,
      'testpayment',
      'app://pitidev.com',
      'https://pitidev.com/?status=success',
      'payment 1000 kip');
  print(dataQR);
}
