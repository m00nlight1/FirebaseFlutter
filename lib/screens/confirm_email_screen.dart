import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/screens/home_screen.dart';
import 'package:flutter_firebase/utils/constants.dart';
import 'package:flutter_firebase/utils/snack_bar.dart';

class ConfirmEmailScreen extends StatefulWidget {
  const ConfirmEmailScreen({super.key});

  @override
  State<ConfirmEmailScreen> createState() => _ConfirmEmailScreenState();
}

class _ConfirmEmailScreenState extends State<ConfirmEmailScreen> {
  Timer? timer;
  bool resendEmail = false;
  bool isEmailConfirmed = false;

  @override
  void initState() {
    super.initState();

    isEmailConfirmed = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailConfirmed) {
      sendVerificationEmail();

      timer = Timer.periodic(
        const Duration(seconds: 3),
            (_) => checkEmailConfirmed(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailConfirmed() async {
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailConfirmed = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    print(isEmailConfirmed);

    if (isEmailConfirmed) timer?.cancel();
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => resendEmail = false);
      await Future.delayed(const Duration(seconds: 5));

      setState(() => resendEmail = true);
    } catch (e) {
      print(e);
      if (mounted) {
        SnackBarService.showSnackBar(
          context,
          '$e',
          //'Неизвестная ошибка! Попробуйте еще раз или обратитесь в поддержку.',
          true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => isEmailConfirmed
      ? const HomeScreen()
      : Scaffold(
    resizeToAvoidBottomInset: false,
    backgroundColor: Colors.white,
    appBar: AppBar(
      elevation: 0,
      backgroundColor: kSecondaryColor,
      title: const Text('Подтверждение Email'),
    ),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'На ваш Email адрес было отправлено письмо с подтверждением',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: resendEmail ? sendVerificationEmail : null,
              icon: const Icon(Icons.email),
              label: const Text('Отправить повторно'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () async {
                timer?.cancel();
                await FirebaseAuth.instance.currentUser!.delete();
              },
              child: const Text(
                'Отменить',
                style: TextStyle(
                  color: kSecondaryColor,
                  fontSize: 14
                ),
              ),
            )
          ],
        ),
      ),
    ),
  );
}