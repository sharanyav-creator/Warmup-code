import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'data/repositories/session_repository.dart';
import 'features/shell/root_shell.dart';

void main() {
  runApp(const WarmupApp());
}

class WarmupApp extends StatelessWidget {
  const WarmupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<SessionRepository>(
      create: (_) => SessionRepository(),
      child: MaterialApp(
        title: 'Warmup',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const RootShell(),
      ),
    );
  }
}
