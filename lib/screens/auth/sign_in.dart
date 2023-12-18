import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kiloi_sm/components/custom_app_button.dart';
import 'package:kiloi_sm/components/custom_auth_field.dart';
import 'package:kiloi_sm/components/custom_pageview.dart';
import 'package:kiloi_sm/components/custom_widgets.dart';
import 'package:kiloi_sm/main.dart';
import 'package:kiloi_sm/providers/auth_provider.dart';
import 'package:kiloi_sm/screens/auth/signup_screen.dart';
import 'package:kiloi_sm/screens/home/home.dart';

import 'package:kiloi_sm/utils/app_colors.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatefulWidget {
  static const String routeName = "/sign_in";
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignInScreen> {
  final PageController _pageController = PageController();
  ScrollController scrollController = ScrollController();
  late _ScreenNotifier _screenNotifier;

  late Size size;
  int _currentPage = 0;
  double? height;
  GlobalKey stackKey = GlobalKey();
  bool? widgetHasHeigh;

  List<Widget> pagWidgets() {
    return [
      SignInScreenTab(isAdmin: true),
      SignInScreenTab(
        isAdmin: false,
      )
    ];
  }

  @override
  void initState() {
    super.initState();

    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    // _pageController.dispose();
    _screenNotifier.emailAdressController.dispose();
    _screenNotifier.emailAdressNode.dispose();
    _screenNotifier.loginPasswordController.dispose();
    _screenNotifier.loginPasswordNode.dispose();
    _screenNotifier.userEmailAdressController.dispose();
    _screenNotifier.userEmailAdressNode.dispose();
    _screenNotifier.userPasswordController.dispose();
    _screenNotifier.userPasswordNode.dispose();
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
            resizeToAvoidBottomInset: false,
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: size.height * 0.09,
                  ),
                  const AuthScreensHeader(),
                  ExpandablePageView(
                    itemBuilder: (context, index) {
                      return pagWidgets()[index];
                    },
                    itemCount: pagWidgets().length,
                    controller: _pageController,
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
                            text: "Don't Have an account? ",
                            style: Theme.of(context).textTheme.titleSmall,
                            children: [
                              TextSpan(
                                text: "Click here",
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushNamed(
                                        context, SignUpScreen.route_name,
                                        arguments: {
                                          "isAdmin":
                                              _currentPage == 0 ? true : false
                                        });
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List<Widget>.generate(2, (index) {
                      return _buildPageIndicator(index == _currentPage);
                    }),
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  const Text("Swipe to change user type!",
                      style: TextStyle(color: Colors.white)),
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildPageIndicator(bool isCurrentPage) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
        height: 5,
        width: 25,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isCurrentPage
                ? AppColors.appThemeColor
                : AppColors.fieldHintColor),
      ),
    );
  }
}

class SignInScreenTab extends StatelessWidget {
  bool isAdmin;
  SignInScreenTab({required this.isAdmin, super.key});

  late Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    var screenNotifier = Provider.of<_ScreenNotifier>(context, listen: false);
    return Container(
      margin: EdgeInsets.only(
        top: size.height * 0.06,
        left: size.height * 0.05,
        right: size.height * 0.05,
      ),
      width: double.infinity,
      // color: Colors.amber,
      child: Form(
        key: isAdmin ? screenNotifier.form : screenNotifier.userForm,
        child: Column(
          children: [
            Text.rich(TextSpan(
                text: "Sign In as ",
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
                title: "Email Address",
                controller: isAdmin
                    ? screenNotifier.emailAdressController
                    : screenNotifier.userEmailAdressController,
                isReadOnly: false,
                suffixIcon: const SizedBox(),
                onChange: (newVal) {},
                focusNode: isAdmin
                    ? screenNotifier.emailAdressNode
                    : screenNotifier.userEmailAdressNode,
                keyboardType: TextInputType.text,
                maxLines: 5,
                nextFocusNode: isAdmin
                    ? screenNotifier.loginPasswordNode
                    : screenNotifier.userPasswordNode,
                onSaved: () {},
                validator: (text) {
                  bool isValidEmail = screenNotifier.isValidEmail(text!);
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
                controller: isAdmin
                    ? screenNotifier.loginPasswordController
                    : screenNotifier.userPasswordController,
                isReadOnly: false,
                suffixIcon: const SizedBox(),
                onChange: (newVal) {},
                focusNode: isAdmin
                    ? screenNotifier.loginPasswordNode
                    : screenNotifier.userPasswordNode,
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
                  if (isAdmin) {
                    final isValid =
                        screenNotifier.form.currentState!.validate();
                    if (!isValid) {
                      return;
                    }
                    screenNotifier.form.currentState!.save();
                  } else {
                    final isValid =
                        screenNotifier.userForm.currentState!.validate();
                    if (!isValid) {
                      return;
                    }
                    screenNotifier.userForm.currentState!.save();
                  }

                  signIn(context, screenNotifier, isAdmin);
                },
                title: "Login"),
          ],
        ),
      ),
    );
  }

  // ignore: library_private_types_in_public_api
  signIn(BuildContext context, _ScreenNotifier screenNotifier,
      bool isAdmin) async {
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    EasyLoading.show(
        indicator: const CircularProgressIndicator(),
        maskType: EasyLoadingMaskType.clear,
        dismissOnTap: false);

    await authProvider
        .signInWithEmailAndPassword(
            email: isAdmin
                ? screenNotifier.emailAdressController.text
                : screenNotifier.userEmailAdressController.text,
            password: isAdmin
                ? screenNotifier.loginPasswordController.text
                : screenNotifier.userPasswordController.text,
            isAdmin: isAdmin)
        .then((value) {
      EasyLoading.dismiss();
      kPrint("login value is $value");
      if (value) {
        // Navigator.pushNamed(context, HomeScreen.route_name);
        // Navigator.pushReplacementNamed(context, HomeScreen.route_name);
        // Here we will nevigate to Home SCREEN
      }
    });
    EasyLoading.dismiss();
  }
}

class _ScreenNotifier extends ChangeNotifier {
  final GlobalKey<FormState> form = GlobalKey<FormState>();
  final GlobalKey<FormState> userForm = GlobalKey<FormState>();

  TextEditingController emailAdressController = TextEditingController();
  FocusNode emailAdressNode = FocusNode();
  TextEditingController loginPasswordController = TextEditingController();
  FocusNode loginPasswordNode = FocusNode();
  TextEditingController userEmailAdressController = TextEditingController();
  FocusNode userEmailAdressNode = FocusNode();
  TextEditingController userPasswordController = TextEditingController();
  FocusNode userPasswordNode = FocusNode();

  bool isValidEmail(String email) {
    String pattern =
        r'^(([^<>()\[\]\\.,;:\s@\"]+(\.[^<>()\[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }
}
