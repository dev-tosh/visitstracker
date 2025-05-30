import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:visitstracker/main_layout.dart';
import 'package:visitstracker/features/actions/presentation/pages/actions_page.dart';
import 'package:visitstracker/features/activities/presentation/pages/activities_page.dart';
import 'package:visitstracker/features/customers/presentation/pages/customers_page.dart';
import 'package:visitstracker/features/profile/presentation/pages/profile_page.dart';
import 'package:visitstracker/features/visits/presentation/pages/new_visit_page.dart';
import 'package:visitstracker/features/visits/presentation/pages/visit_details_page.dart';
import 'package:visitstracker/features/home/presentation/pages/home_page.dart';
import 'package:visitstracker/features/visits/presentation/pages/visits_page.dart';

// Global navigator key
final rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainLayout(
        location: state.uri.toString(),
        child: child,
      ),
      routes: [
        GoRoute(
          path: '/',
          redirect: (_, __) => '/home',
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomePage(),
          routes: [
            GoRoute(
              path: 'new',
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const NewVisitPage(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            ),
            GoRoute(
              path: ':id',
              pageBuilder: (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: VisitDetailsPage(
                  id: state.pathParameters['id']!,
                ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/visits',
          builder: (context, state) => const VisitsPage(),
        ),
        GoRoute(
          path: '/customers',
          builder: (context, state) => const CustomersPage(),
        ),
        GoRoute(
          path: '/actions',
          builder: (context, state) => const ActionsPage(),
        ),
        GoRoute(
          path: '/activities',
          builder: (context, state) => const ActivitiesPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),
  ],
);
