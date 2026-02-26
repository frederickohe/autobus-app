import 'package:autobus/barrel.dart';

// Initialize services at app level
late TokenService _tokenService;
late SessionAwareHttpClient _httpClient;
late ApiService _apiService;
late PaystackService _paystackService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment variables
  await AppConfig.init();

  // Initialize Google Fonts
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

  // Initialize Paystack
  _paystackService = PaystackService();
  await _paystackService.initialize();

  // Create blocs
  final successBloc = SuccessBloc();
  final authBloc = AuthBloc(
    tokenService: _tokenService,
    successBloc: successBloc,
  );

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiService>(create: (context) => _apiService),
        RepositoryProvider<PaystackService>(
          create: (context) => _paystackService,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authBloc..add(CheckSessionEvent())),
          BlocProvider.value(value: successBloc),
          BlocProvider(create: (context) => AssistantBloc()),
          BlocProvider(create: (context) => ThemeBloc()),
        ],
        child: MyApp(httpClient: _httpClient),
      ),
    ),
  );
}

//Getters
SessionAwareHttpClient get appHttpClient => _httpClient;
ApiService get apiService => _apiService;
TokenService get tokenService => _tokenService;
PaystackService get paystackService => _paystackService;

class MyApp extends StatelessWidget {
  final SessionAwareHttpClient httpClient;

  const MyApp({required this.httpClient, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          navigatorKey: NavigationService.navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Autobus',
          theme: state.themeData,
          home: const SplashWrapper(),
        );
      },
    );
  }
}
