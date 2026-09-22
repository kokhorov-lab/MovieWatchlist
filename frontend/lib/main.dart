import 'package:flutter/material.dart';
import 'package:frontend/router/app_router.dart';

void main() {
  runApp(MyWidget());
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Movie App',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );
  }
}
