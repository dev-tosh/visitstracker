import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visitstracker/core/network/api_client.dart';
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

void main() {
  final apiClient = ApiClient();
  final actionRepository = ActionRepository();
  final activityRepository = ActivityRepository(apiClient);
  final customerRepository = CustomerRepository(apiClient);
  final visitRepository = VisitRepository(apiClient);
  final visitService = VisitService(visitRepository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => ActionsProvider(actionRepository)),
        ChangeNotifierProvider(
            create: (_) => ActivitiesProvider(activityRepository)),
        ChangeNotifierProvider(
            create: (_) => CustomersProvider(customerRepository)),
        ChangeNotifierProvider(create: (_) => VisitsProvider(visitService)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Visits Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
