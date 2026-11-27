import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:playdesk_owner_stories/core/theme.dart';
import 'package:playdesk_owner_stories/ui/home/home_screen.dart';

class PlayDeskApp extends ConsumerWidget {
  const PlayDeskApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'PlayDesk Owner Stories',
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}