import 'package:autobus/barrel.dart';

// Initialize services at app level
late TokenService _tokenService;
late SessionAwareHttpClient _httpClient;
late ApiService _apiService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment variables
  await AppConfig.init();

  // Initialize Google Fonts (optional, but can help with loading)
  await GoogleFonts.pendingFonts([
    GoogleFonts.lato(),
    GoogleFonts.imprima(),
    GoogleFonts.righteous(),
  ]);

  // Initialize session handling services
  _tokenService = TokenService();
  _httpClient = SessionAwareHttpClient(
    tokenService: _tokenService,
    baseUrl: AppConfig.backendUrl,
  );
  _apiService = ApiService(httpClient: _httpClient);

  // Create AuthBloc with TokenService
  final authBloc = AuthBloc(tokenService: _tokenService);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiService>(create: (context) => _apiService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authBloc..add(CheckSessionEvent())),
          BlocProvider(create: (context) => AssistantBloc()),
          BlocProvider(create: (context) => ThemeBloc()),
        ],
        child: MyApp(httpClient: _httpClient),
      ),
    ),
  );
}

// Getters for services to be used throughout the app
SessionAwareHttpClient get appHttpClient => _httpClient;
ApiService get apiService => _apiService;
TokenService get tokenService => _tokenService;

class MyApp extends StatelessWidget {
  final SessionAwareHttpClient httpClient;

  const MyApp({required this.httpClient, super.key});

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
