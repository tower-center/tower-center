import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'views/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('settings').doc('app').snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final fontSizeStr = data?['fontSize'] ?? 'medium';
        
        double scaleFactor = 1.0;
        if (fontSizeStr == 'small') {
          scaleFactor = 0.85;
        } else if (fontSizeStr == 'medium') {
          scaleFactor = 1.0;
        } else if (fontSizeStr == 'large') {
          scaleFactor = 1.2;
        } else if (fontSizeStr == 'extraLarge') {
          scaleFactor = 1.4;
        }

        return MaterialApp(
          title: '空拍機隊管理系統',
          debugShowCheckedModeBanner: false,
          // 使用 Material 3 機隊深/淺色主題
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF006C84), // 科技感藍綠色調
              brightness: Brightness.light,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF006C84),
              brightness: Brightness.dark,
            ),
          ),
          themeMode: ThemeMode.system, // 自動跟隨系統深淺色設定
          builder: (context, child) {
            final mediaQueryData = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQueryData.copyWith(
                textScaler: TextScaler.linear(scaleFactor),
              ),
              child: child!,
            );
          },
          home: const HomePage(),
        );
      },
    );
  }
}
