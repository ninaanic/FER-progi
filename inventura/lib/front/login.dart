import 'package:flutter/material.dart';
import 'package:inventura/front/interface.dart';
import 'package:inventura/front/signup.dart';
import 'package:inventura/services/auth.dart';
import 'package:provider/src/provider.dart';
import 'package:sizer/sizer.dart';

import 'size_config.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  LoginState createState() {
    return LoginState();
  }
}

class LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  String _email = '';
  String _password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: _loading
          ? loader
          : Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.safeBlockVertical! * 5,
                vertical: SizeConfig.safeBlockHorizontal! * 10,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Inventura',
                            style: title,
                          ),
                          SizedBox(height: 8.h),
                          inputEmail(),
                          SizedBox(height: 3.h),
                          inputPassword(),
                          SizedBox(height: 5.h),
                          buttonSignIn(_formKey),
                          SizedBox(height: 0.1.h),
                          Text(
                            error,
                            style: errorTxt,
                          ),
                          SizedBox(height: 8.h),
                        ],
                      ),
                    ),
                    buttonSighUp(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget inputEmail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          'email',
          style: plainTxt,
        ),
        SizedBox(height: 0.5.h),
        Container(
          alignment: Alignment.centerLeft,
          height: 10.h,
          child: TextFormField(
            initialValue: _email,
            onChanged: (value) => setState(() => _email = value),
            keyboardType: TextInputType.emailAddress,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: plainTxt,
            textAlign: TextAlign.center,
            decoration: inputDecoration,
            validator: (email) {
              if (email!.isEmpty)
                return "email ne smije biti prazan";
              else
                return null;
            },
          ),
        ),
      ],
    );
  }

  Widget inputPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          'Lozinka',
          style: plainTxt,
        ),
        SizedBox(height: 0.5.h),
        Container(
          alignment: Alignment.center,
          height: 10.h,
          child: TextFormField(
            initialValue: _password,
            onChanged: (value) => setState(() => _password = value),
            keyboardType: TextInputType.visiblePassword,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            obscureText: true,
            style: plainTxt,
            textAlign: TextAlign.center,
            decoration: inputDecoration,
            validator: (password) {
              if (password!.isEmpty)
                return "Lozinka ne smije biti prazna";
              else
                return null;
            },
          ),
        ),
      ],
    );
  }

  Widget buttonSignIn(GlobalKey<FormState> _formKey) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            setState(() {
              _loading = true;
            });
          }
          String result = await context.read<AuthService>().signIn(_email, _password);
          if (result != 'OK') {
            setState(() {
              if (result == "Given String is empty or null")
                error = '';
              else
                error = result;
              _loading = false;
            });
          }
          if (this.mounted)
            setState(() {
              _loading = false;
            });
        },
        style: ElevatedButton.styleFrom(padding: EdgeInsets.zero, shape: const RoundedRectangleBorder(borderRadius: borderRadius)),
        child: Ink(
          decoration: const BoxDecoration(gradient: gradient, borderRadius: borderRadius),
          child: Container(
            width: 25.w,
            height: 7.h,
            alignment: Alignment.center,
            child: Text(
              'Prijavi se',
              style: plainTxt,
            ),
          ),
        ),
      ),
    );
  }

  Widget buttonSighUp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          'Nemaš račun?',
          style: plainTxt,
        ),
        Container(
          alignment: Alignment.center,
          child: TextButton(
              onPressed: () async => await Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpWidget())),
              child: Text(
                'Registriraj se',
                style: textButtonTxt,
              )),
        ),
      ],
    );
  }
}
