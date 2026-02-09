import 'package:autobus/barrel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Google Fonts (optional, but can help with loading)
  await GoogleFonts.pendingFonts([
    GoogleFonts.lato(),
    GoogleFonts.imprima(),
    GoogleFonts.righteous(),
  ]);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()..add(CheckAuthEvent())),
        BlocProvider(create: (context) => AssistantBloc()),
        BlocProvider(create: (context) => ThemeBloc()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Autobus',
          theme: state.themeData,
          home: const SplashWrapper(),
        );
      },
    );
  }
}
