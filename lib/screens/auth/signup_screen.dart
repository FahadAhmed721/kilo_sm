import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kiloi_sm/components/custom_app_button.dart';
import 'package:kiloi_sm/components/custom_auth_field.dart';
import 'package:kiloi_sm/components/custom_widgets.dart';
import 'package:kiloi_sm/providers/auth_provider.dart';
import 'package:kiloi_sm/screens/home/home.dart';
import 'package:kiloi_sm/utils/app_colors.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  static const String route_name = "/sign_up";
  bool isAdmin;
  SignUpScreen({required this.isAdmin, super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late Size size;
  late _ScreenNotifier _screenNotifier;

  @override
  void dispose() {
    _screenNotifier.fullNameController.dispose();
    _screenNotifier.fullNameNode.dispose();
    _screenNotifier.adressController.dispose();
    _screenNotifier.adressNode.dispose();
    _screenNotifier.passwordController.dispose();
    _screenNotifier.passwordNode.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return ChangeNotifierProvider(
        create: (context) => _ScreenNotifier(),
        builder: (context, _) {
          _screenNotifier =
              Provider.of<_ScreenNotifier>(context, listen: false);
          return Scaffold(
            // resizeToAvoidBottomInset: false,
            body: SingleChildScrollView(
                child: Column(
              children: [
                SizedBox(
                  height: size.height * 0.09,
                ),
                const AuthScreensHeader(),
                SignUpFieldsCell(
                  isAdmin: widget.isAdmin,
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(
                      size.height * 0.05,
                      // _currentPage == 0 ?
                      size.height * 0.06,
                      // : 0,
                      size.height * 0.05,
                      size.height * 0.06),
                  child: Column(
                    children: [
                      const ORWidget(),
                      SizedBox(
                        height: size.height * 0.051,
                      ),
                      Text.rich(TextSpan(
                          text: "Already Have an account? ",
                          style: Theme.of(context).textTheme.titleSmall,
                          children: [
                            TextSpan(
                              text: "Click here",
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.of(context).pop();
                                },
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    color: AppColors.appThemeColor,
                                  ),
                            )
                          ])),
                    ],
                  ),
                ),
              ],
            )),
          );
        });
  }
}

// ignore: must_be_immutable
class SignUpFieldsCell extends StatelessWidget {
  bool isAdmin;
  SignUpFieldsCell({required this.isAdmin, super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var _screenNotifier = Provider.of<_ScreenNotifier>(context, listen: false);
    return Container(
      margin: EdgeInsets.only(
        top: size.height * 0.06,
        left: size.height * 0.05,
        right: size.height * 0.05,
      ),
      width: double.infinity,
      // color: Colors.amber,
      child: Form(
        key: _screenNotifier.form,
        child: Column(
          children: [
            Text.rich(TextSpan(
                text: "Sign Up as ",
                style: Theme.of(context).textTheme.titleMedium,
                children: [
                  TextSpan(
                    text: isAdmin ? "Admin" : "User",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: AppColors.appThemeColor),
                  )
                ])),
            SizedBox(
              height: size.height * 0.04,
            ),
            CustomTextField(
                title: "Full Name",
                controller: _screenNotifier.fullNameController,
                isReadOnly: false,
                suffixIcon: const SizedBox(),
                onChange: (newVal) {},
                focusNode: _screenNotifier.fullNameNode,
                keyboardType: TextInputType.text,
                maxLines: 5,
                nextFocusNode: _screenNotifier.adressNode,
                onSaved: () {},
                validator: (text) {
                  if (text!.isEmpty) {
                    return "Please Enter Full Name";
                  }
                  return null;
                }),
            SizedBox(
              height: size.height * 0.02,
            ),
            CustomTextField(
                title: "Email Address",
                controller: _screenNotifier.adressController,
                isReadOnly: false,
                suffixIcon: const SizedBox(),
                onChange: (newVal) {},
                focusNode: _screenNotifier.adressNode,
                keyboardType: TextInputType.text,
                maxLines: 5,
                nextFocusNode: _screenNotifier.passwordNode,
                onSaved: () {},
                validator: (text) {
                  bool isValidEmail = _screenNotifier.isValidEmail(text!);
                  if (text == null || text.isEmpty) {
                    return 'Please enter email address';
                  } else if (!isValidEmail) {
                    return 'Enter a valid email address';
                  }
                  return null;
                }),
            SizedBox(
              height: size.height * 0.02,
            ),
            CustomTextField(
                title: "Password",
                controller: _screenNotifier.passwordController,
                isReadOnly: false,
                suffixIcon: const SizedBox(),
                onChange: (newVal) {},
                focusNode: _screenNotifier.passwordNode,
                keyboardType: TextInputType.text,
                maxLines: 5,
                nextFocusNode: null,
                onSaved: () {},
                validator: (text) {
                  if (text!.isEmpty) {
                    return "Please Enter Password";
                  } else if (text.length < 7) {
                    return "Password should be atleast 7 characters";
                  }
                  return null;
                }),
            SizedBox(
              height: size.height * 0.05,
            ),
            CustomButton(
              onTap: () {
                final isValid = _screenNotifier.form.currentState!.validate();
                if (!isValid) {
                  return;
                }
                _screenNotifier.form.currentState!.save();
                signUp(context, _screenNotifier);
              },
              title: "Sign Up",
            ),
          ],
        ),
      ),
    );
  }

  // ignore: library_private_types_in_public_api
  signUp(BuildContext context, _ScreenNotifier screenNotifier) async {
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    EasyLoading.show(
        indicator: const CircularProgressIndicator(),
        maskType: EasyLoadingMaskType.clear,
        dismissOnTap: false);

    await authProvider
        .signUpWithEmailAndPassword(
            email: screenNotifier.adressController.text,
            password: screenNotifier.passwordController.text,
            name: screenNotifier.fullNameController.text,
            isAdmin: isAdmin)
        .then((value) {
      EasyLoading.dismiss();
      if (value) {
        Navigator.pop(context);
        // Navigator.pushReplacementNamed(context, HomeScreen.route_name);
        // Here we will nevigate to Home SCREEN
      }
    });
    EasyLoading.dismiss();
  }
}

class _ScreenNotifier extends ChangeNotifier {
  final GlobalKey<FormState> form = GlobalKey<FormState>();
  TextEditingController fullNameController = TextEditingController();
  FocusNode fullNameNode = FocusNode();
  TextEditingController adressController = TextEditingController();
  FocusNode adressNode = FocusNode();
  TextEditingController passwordController = TextEditingController();
  FocusNode passwordNode = FocusNode();

  bool isValidEmail(String email) {
    String pattern =
        r'^(([^<>()\[\]\\.,;:\s@\"]+(\.[^<>()\[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }
}
