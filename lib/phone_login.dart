import 'package:demo/otp_verification.dart';
import 'package:demo/utils/progress_dialog.dart';
import 'package:demo/utils/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class PhoneAuth extends StatefulWidget {
  const PhoneAuth({super.key});
  @override
  State<PhoneAuth> createState() => _PhoneAuthState();
}

class _PhoneAuthState extends State<PhoneAuth> {
  final _phoneNumberController = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> _verifyPhoneNumber() async {
     if (_phoneNumberController.text.isEmpty) {
      Snackbars.error(context, " Please Enter Your Number");
    }
    final String _phone = "+91" + _phoneNumberController.text.trim();
   
    if (_phone.length == 13) {
      try {
        showProgressDialog(context, 'Sending OTP Please Wait');
        await _auth.verifyPhoneNumber(
          phoneNumber: _phone,
          verificationCompleted: (Credential) {},
          verificationFailed: (FirebaseAuthException e) {
            _phoneNumberController.clear();
            hideProgressDialog(context);
            // Handle verification failure errors
            switch (e.code) {
              case 'invalid-phone-number':
                // Invalid phone number
                Snackbars.error(context, "Please enter valid phone number");

                break;
              case 'invalid-verification-id':
                // Invalid verification ID
                Snackbars.error(context, "Something went wrong, Please try again");
                break;
              case 'quota-exceeded':
                // Quota exceeded, too many SMS sent to the same number
                Snackbars.error(context, "Maximum attempt reaches, please try again later");
                break;
              case 'missing-client-identifier':
                // Missing client identifier
                Snackbars.error(context, "Something went wrong, Please try again");
                break;
              case 'app-not-authorized':
                // App not authorized to use Firebase Authentication
                 Snackbars.error(context, "Something went wrong, Please try again later");
                break;
              case 'user-disabled':
                // The user corresponding to the given phone number has been disabled
                Snackbars.error(context, "user removed,please try again later");
                break;
              case 'user-not-found':
                // The user corresponding to the given phone number was not found
                Snackbars.error(context, "Usernot found");
                break;
              case 'operation-not-allowed':
                // Operation not allowed, verifyPhoneNumber is disabled
                Snackbars.error(context, "Something went wrong, Please try again later");
                break;
              default:
                // Handle other errors
                Snackbars.error(context, e.code);
                break;
            }
          },
          codeSent: (verificationId, resendToken) {
            hideProgressDialog(context);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: ((context) => OtpScreen(
                          verificationId: verificationId,
                        ))));
          },
          codeAutoRetrievalTimeout: (verification) {},
          timeout: Duration(seconds: 120),
        );
      } on FirebaseAuthException catch (e) {
        print('Failed to sign in with phone number: $e');
        hideProgressDialog(context);
        Snackbars.error(context, e.code);
        setState(() {});
      }
    } else {
      Snackbars.error(context, "Enter valid number");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20, 
            horizontal: 12
            ),
          child: SingleChildScrollView(
            child: Column(
              children: [
              const Column(
                children: [
                  SizedBox(
                    width: 38,
                  ),
                  Text(
                    "Phone Number",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(255, 180, 4, 1.0),
                    ),
                  ),
                  Text(
                    "Please Enter your Information",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Image(
                    image: AssetImage("assets/icons/phnauth.png"),
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
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 15, 12, 20),
                    child: SizedBox(
                      height: 46,
                      child: TextFormField(
                        controller: _phoneNumberController,
                        decoration: const InputDecoration(
                            hintText: "Enter Your Number",
                            label: Text("Phone number"),
                            border: OutlineInputBorder(),
                            fillColor: Color.fromRGBO(225, 225, 225, 0.302),
                            filled: true,
                            icon: Icon(
                              Icons.phone_android,
                              size: 38,
                            )),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(10),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      _verifyPhoneNumber();
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
                          "Get OTP",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 23,
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