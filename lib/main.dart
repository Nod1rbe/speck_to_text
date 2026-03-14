import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/ai_service.dart';
import 'logic/search_cubit.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  const String openAiApiKey =
      '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';
  const String elevenLabsApiKey =
      'sk_0a932a27d172b69c226f4f6058441a7edb376e2d7bba6e88';

  final aiService = AiService(
    openAiApiKey: openAiApiKey,
    elevenLabsApiKey: elevenLabsApiKey,
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<SearchCubit>(create: (context) => SearchCubit(aiService)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D14),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          surface: Color(0xFF16161F),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
