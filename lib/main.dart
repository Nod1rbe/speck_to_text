import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'data/ai_service.dart';
import 'logic/search_cubit.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  final String openAiApiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  final String elevenLabsApiKey = dotenv.env['ELEVEN_LABS_API_KEY'] ?? '';

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
