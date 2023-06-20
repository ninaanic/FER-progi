import 'package:flutter/material.dart';
import 'package:inventura/services/auth.dart';
import 'package:provider/src/provider.dart';
import 'package:sizer/sizer.dart';
import 'interface.dart';
import 'size_config.dart';
import 'package:inventura/services/enums/roleEnum.dart';
import 'package:inventura/services/extensions/roleExtension.dart';

class SignUpWidget extends StatefulWidget {
  const SignUpWidget({Key? key}) : super(key: key);

  @override
  SignUpState createState() {
    return SignUpState();
  }
}

class SignUpState extends State<SignUpWidget> {
  // varijable u koje se spremaju input values
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _password = '';
  Role? _role = Role.WORKER;
  String error = '';

  bool loading = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      body: loading
          ? loader
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.safeBlockVertical! * 5,
                vertical: SizeConfig.safeBlockHorizontal! * 10,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // naslov INVENTURA
                    Text(
                      'Inventura',
                      style: title,
                    ),
                    SizedBox(height: SizeConfig.screenHeight! * 0.05),

                    // forma za validaciju unosa imena, preizmena, emaila i lozinke
                    Form(
                      key: _formKey,
                      //autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ime
                          Column(
                            children: [
                              Text(
                                'Ime',
                                style: plainTxt,
                              ),
                              SizedBox(height: SizeConfig.screenHeight! * 0.01),
                              Container(
                                alignment: Alignment.center,
                                child: TextFormField(
                                  initialValue: _firstName,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  keyboardType: TextInputType.emailAddress,
                                  style: plainTxt,
                                  textAlign: TextAlign.center,
                                  cursorHeight: SizeConfig.screenHeight! * 0.03,
                                  decoration: inputDecoration, // dodat u pravi interface
                                  validator: (firstName) {
                                    if (firstName!.isEmpty) return 'Ime ne smije biti prazno';
                                    return null;
                                  },
                                  onChanged: (firstName) => setState(() {
                                    _firstName = firstName;
                                  }),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: SizeConfig.screenHeight! * 0.03),

                          // prezime
                          Column(
                            children: <Widget>[
                              Text(
                                'Prezime',
                                style: plainTxt,
                              ),
                              SizedBox(height: SizeConfig.screenHeight! * 0.01),
                              Container(
                                alignment: Alignment.center,
                                child: TextFormField(
                                  initialValue: _lastName,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  keyboardType: TextInputType.emailAddress,
                                  style: plainTxt,
                                  textAlign: TextAlign.center,
                                  cursorHeight: SizeConfig.screenHeight! * 0.03,
                                  decoration: inputDecoration,
                                  validator: (lastName) {
                                    if (lastName!.isEmpty) return 'Prezime ne smije biti prazno';
                                    return null;
                                  },
                                  onChanged: (lastName) => setState(() {
                                    _lastName = lastName;
                                  }),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: SizeConfig.screenHeight! * 0.03),

                          // email
                          Column(
                            children: <Widget>[
                              Text(
                                'email',
                                style: plainTxt,
                              ),
                              SizedBox(height: SizeConfig.screenHeight! * 0.01),
                              Container(
                                alignment: Alignment.center,
                                child: TextFormField(
                                  initialValue: _email,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  keyboardType: TextInputType.emailAddress,
                                  style: plainTxt,
                                  textAlign: TextAlign.center,
                                  cursorHeight: SizeConfig.screenHeight! * 0.03,
                                  decoration: inputDecoration,
                                  validator: (email) {
                                    if (email!.isEmpty) return 'email ne smije bit prazan';
                                    return null;
                                  },
                                  onChanged: (email) => setState(() {
                                    _email = email;
                                  }),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: SizeConfig.screenHeight! * 0.03),

                          // lozinka
                          Column(
                            children: <Widget>[
                              Text(
                                'Lozinka',
                                style: plainTxt,
                              ),
                              SizedBox(height: SizeConfig.screenHeight! * 0.01),
                              Container(
                                alignment: Alignment.center,
                                child: TextFormField(
                                  initialValue: _password,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  keyboardType: TextInputType.emailAddress,
                                  obscureText: true,
                                  style: plainTxt,
                                  textAlign: TextAlign.center,
                                  cursorHeight: SizeConfig.screenHeight! * 0.03,
                                  decoration: inputDecoration,
                                  validator: (password) {
                                    if (password!.isEmpty) return 'Lozinka ne smije bit prazna';
                                    return null;
                                  },
                                  onChanged: (password) => setState(() {
                                    _password = password;
                                  }),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: SizeConfig.screenHeight! * 0.05),
                        ],
                      ),
                    ),

                    // odaberi ulogu
                    Text(
                      'Odaberi ulogu:',
                      style: plainTxt,
                    ),
                    SizedBox(height: SizeConfig.screenHeight! * 0.01),
                    Center(
                      child: SizedBox(
                        width: SizeConfig.screenWidth! / 2,
                        child: ListTile(
                          title: Text(Role.WORKER.asString, style: plainTxt, textAlign: TextAlign.center),
                          leading: Radio<Role>(
                            value: Role.WORKER,
                            groupValue: _role,
                            onChanged: (Role? value) {
                              setState(() {
                                _role = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        width: SizeConfig.screenWidth! / 2,
                        child: ListTile(
                          title: Text(Role.MANAGER.asString, style: plainTxt, textAlign: TextAlign.center),
                          leading: Radio<Role>(
                            value: Role.MANAGER,
                            groupValue: _role,
                            onChanged: (Role? value) {
                              setState(() {
                                _role = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        width: SizeConfig.screenWidth! / 2,
                        child: ListTile(
                          title: Text(Role.DIRECTOR.asString, style: plainTxt, textAlign: TextAlign.center),
                          leading: Radio<Role>(
                            value: Role.DIRECTOR,
                            groupValue: _role,
                            onChanged: (Role? value) {
                              setState(() {
                                _role = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: SizeConfig.screenHeight! * 0.03),

                    // gumb za registraciju
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              loading = true;
                            });
                            print(_email);
                            String result = await context.read<AuthService>().signUp(_email, _password, _firstName, _lastName, _role!);
                            print(_email);
                            if (result == "OK")
                              Navigator.pop(context);
                            else {
                              setState(() {
                                error = result;
                                loading = false;
                              });
                            }
                            print(_email);
                          }
                        },
                        style: ElevatedButton.styleFrom(padding: EdgeInsets.zero, shape: const RoundedRectangleBorder(borderRadius: borderRadius)),
                        child: Ink(
                          decoration: const BoxDecoration(gradient: gradient, borderRadius: borderRadius),
                          child: Container(
                            width: 30.w,
                            height: 8.h,
                            alignment: Alignment.center,
                            child: Text(
                              'Registriraj se',
                              style: plainTxt,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: SizeConfig.screenHeight! * 0.02),
                    Text(
                      error,
                      style: errorTxt,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
