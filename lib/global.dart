import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kiloi_sm/firebase_options.dart';
import 'package:kiloi_sm/main.dart';
import 'package:kiloi_sm/services/storage.dart';

class Global {
  static Future iniit() async {
    WidgetsFlutterBinding.ensureInitialized();
    await StorageService().init();
    // try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    // } catch (error) {
    //   kPrint("error $error");
    // }
  }
}
