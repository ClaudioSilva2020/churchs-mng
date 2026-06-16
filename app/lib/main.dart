import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/di/injector.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupInjector();
  await initializeDateFormatting('pt_BR');
  runApp(const ChurchsMngApp());
}

class ChurchsMngApp extends StatelessWidget {
  const ChurchsMngApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => injector<AuthBloc>()..add(const AuthCheckRequested()),
      child: Builder(
        builder: (context) {
          final router = buildRouter(context.read<AuthBloc>());
          return MaterialApp.router(
            title: 'IBBE',
            theme: AppTheme.light,
            debugShowCheckedModeBanner: false,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
