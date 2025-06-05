import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:swee16/firebase_options.dart';
import 'package:swee16/provider/practice_provider.dart';
import 'package:swee16/provider/speech_provider.dart';
import 'package:swee16/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase and mute system sounds immediately
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SystemChannels.platform.invokeMethod('SystemSound.mute');

  // Preload sound assets
  await preloadSounds();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SpeechProvider()),
        ChangeNotifierProvider(create: (_) => PracticeProvider()),
      ],
      child: const SilentApp(),
    ),
  );
}

// Sound preloading function
Future<void> preloadSounds() async {
  try {
    final audioCache = AudioCache(prefix: 'assets/sounds/');
    await audioCache.loadAll(['good.mp3', 'missed.mp3']);
    debugPrint('Sounds preloaded successfully');
  } catch (e) {
    debugPrint('Error preloading sounds: $e');
  }
}

class SilentApp extends StatefulWidget {
  const SilentApp({super.key});

  @override
  State<SilentApp> createState() => _SilentAppState();
}

class _SilentAppState extends State<SilentApp> with WidgetsBindingObserver {
  static const platform = MethodChannel('com.example.audio_channel');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _muteSystemPermanently();
  }

  Future<void> _muteSystemPermanently() async {
    try {
      await platform.invokeMethod('disableAllSounds');
      // Additional Flutter-level sound muting
      await SystemChannels.platform.invokeMethod('SystemSound.mute');
    } catch (e) {
      debugPrint('Mute error: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _muteSystemPermanently(); // Re-apply mute when app returns to foreground
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Basketball Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        // Disable all animation sounds
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: NoAnimationPageTransitionsBuilder(),
            TargetPlatform.iOS: NoAnimationPageTransitionsBuilder(),
          },
        ),
      ),
      home: const AnimatedSilencer(child: SplashScreen()),
    );
  }
}

class NoAnimationPageTransitionsBuilder extends PageTransitionsBuilder {
  const NoAnimationPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child; // No transitions, no sounds
  }
}

class AnimatedSilencer extends StatefulWidget {
  final Widget child;
  const AnimatedSilencer({required this.child, super.key});

  @override
  State<AnimatedSilencer> createState() => _AnimatedSilencerState();
}

class _AnimatedSilencerState extends State<AnimatedSilencer> {
  late Timer _soundCheckTimer;

  @override
  void initState() {
    super.initState();
    // Check and mute sounds every 500ms
    _soundCheckTimer = Timer.periodic(const Duration(milliseconds: 500), (
      _,
    ) async {
      await SystemChannels.platform.invokeMethod('SystemSound.mute');
    });
  }

  @override
  void dispose() {
    _soundCheckTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        // Disable all keyboard sounds
        LogicalKeySet(LogicalKeyboardKey.space): DoNothingIntent(),
        LogicalKeySet(LogicalKeyboardKey.enter): DoNothingIntent(),
        LogicalKeySet(LogicalKeyboardKey.select): DoNothingIntent(),
      },
      child: Actions(
        actions: {DoNothingIntent: DoNothingAction()},
        child: Focus(autofocus: true, child: widget.child),
      ),
    );
  }
}

class DoNothingIntent extends Intent {}

class DoNothingAction extends Action<DoNothingIntent> {
  @override
  Object? invoke(DoNothingIntent intent) => null;
}
