import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:visitstracker/core/network/api_client.dart';
import 'package:visitstracker/core/network/supabase_service.dart';
import 'package:visitstracker/core/storage/storage_service.dart';
import 'package:visitstracker/features/actions/data/repositories/action_repository.dart';
import 'package:visitstracker/features/actions/presentation/providers/actions_provider.dart';
import 'package:visitstracker/features/activities/data/repositories/activity_repository.dart';
import 'package:visitstracker/features/activities/presentation/providers/activities_provider.dart';
import 'package:visitstracker/features/customers/data/repositories/customer_repository.dart';
import 'package:visitstracker/features/customers/presentation/providers/customers_provider.dart';
import 'package:visitstracker/features/visits/data/repositories/visit_repository.dart';
import 'package:visitstracker/features/visits/data/services/visit_service.dart';
import 'package:visitstracker/features/visits/presentation/providers/visits_provider.dart';
import 'package:visitstracker/core/routes/app_router.dart';
import 'package:visitstracker/core/theme/theme_provider.dart';
import 'package:visitstracker/core/services/cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);
  final httpClient = http.Client();
  final supabaseService = SupabaseService(httpClient);

  final apiClient = ApiClient();
  final cacheService = CacheService(apiClient);
  await cacheService.initialize();

  final actionRepository = ActionRepository();
  final customerRepository = CustomerRepository(apiClient, cacheService);
  final activityRepository = ActivityRepository(apiClient, cacheService);
  final visitRepository = VisitRepository(apiClient, cacheService);
  final visitService = VisitService(visitRepository);

  runApp(
    MultiProvider(
      providers: [
        Provider<SupabaseService>.value(value: supabaseService),
        Provider<CacheService>.value(value: cacheService),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => ActionsProvider(actionRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ActivitiesProvider(activityRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => CustomersProvider(customerRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => VisitsProvider(visitRepository),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Set the context for CacheService after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final cacheService = context.read<CacheService>();
        cacheService.setContext(context);
        cacheService.startMonitoring();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Visits Tracker',
          theme: ThemeData.light(useMaterial3: true),
          darkTheme: ThemeData.dark(useMaterial3: true),
          themeMode:
              themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          routerConfig: router,
        );
      },
    );
  }
}
