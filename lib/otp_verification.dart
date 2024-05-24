// ignore_for_file: use_build_context_synchronously
import 'package:demo/dashboard_screen.dart';
import 'package:demo/phone_login.dart';
import 'package:demo/utils/progress_dialog.dart';
import 'package:demo/utils/snackbars.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  const OtpScreen({super.key, required this.verificationId});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String otp = "";
  void _verifyOtp(String otp) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId, smsCode: otp);
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      if (userCredential.user != null) {
        hideProgressDialog(context);

        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()));
      }
    } on FirebaseAuthException catch (ex) {
      hideProgressDialog(context);
      switch (ex.code) {
        case 'invalid-verification-code':
          Snackbars.error(context, "Invalid OTP");
          break;
        case 'session-expired':
          Snackbars.error(context, "Timeout please retry");
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const PhoneAuth()));
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: SingleChildScrollView(
            child: Column(
              children: [
              const Column(
                children: [
                  SizedBox(
                    width: 38,
                  ),
                  Text(
                    "Verification Code",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(255, 180, 4, 1.0),
                    ),
                  ),
                  Text(
                    "Please Enter OTP",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Image(
                    image: AssetImage("assets/icons/otp.png"),
                    height: 180,
                    width: 310,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              Center(
                  child: Column(
                children: [
                  const SizedBox(
                    height: 25,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: OtpTextField(
                        numberOfFields: 6,
                        fieldHeight: 55,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(10),
                        keyboardType: TextInputType.number,
                        borderColor: Colors.blue,
                        borderWidth: 1.5,
                        focusedBorderColor: Colors.blue,
                        disabledBorderColor: Colors.black,
                        enabledBorderColor: Colors.black,
                        enabled: true,
                        showFieldAsBox: true,
                        onSubmit: (value) => {
                              otp += value,
                            }),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (otp != "" || otp.length >= 6) {
                        showProgressDialog(context, "Verifying please wait!");
                        _verifyOtp(otp);
                      } else {
                        Snackbars.error(context, "Enter valid OTP");
                      }
                    },
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      height: 48,
                      width: 198,
                      margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(255, 180, 4, 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(11)),
                      ),
                      child: const Center(
                        child: Text(
                          "Verify",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  )
                ],
              )),
            ]),
          ),
        )));
  }
}
