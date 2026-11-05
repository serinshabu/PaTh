import 'package:flutter/material.dart';

@immutable
class LifeOsPalette {
  const LifeOsPalette({
    required this.id,
    required this.brightness,
    required this.canvas,
    required this.sidebar,
    required this.card,
    required this.elevated,
    required this.rose,
    required this.lavender,
    required this.highlight,
    required this.text,
    required this.secondaryText,
    required this.border,
    required this.positive,
    required this.warning,
    required this.negative,
    required this.onAccent,
  });

  final String id;
  final Brightness brightness;
  final Color canvas;
  final Color sidebar;
  final Color card;
  final Color elevated;
  final Color rose;
  final Color lavender;
  final Color highlight;
  final Color text;
  final Color secondaryText;
  final Color border;
  final Color positive;
  final Color warning;
  final Color negative;
  final Color onAccent;

  static const LifeOsPalette midnightRose = LifeOsPalette(
    id: 'midnightRose',
    brightness: Brightness.dark,
    canvas: Color(0xFF15121B),
    sidebar: Color(0xFF1D1824),
    card: Color(0xFF26202E),
    elevated: Color(0xFF302838),
    rose: Color(0xFFD9A0BC),
    lavender: Color(0xFFB9A3E3),
    highlight: Color(0xFFF1D4DF),
    text: Color(0xFFF7F1F5),
    secondaryText: Color(0xFFADA3B4),
    border: Color(0xFF403546),
    positive: Color(0xFFA6C7AA),
    warning: Color(0xFFF1C879),
    negative: Color(0xFFE7A0A5),
    onAccent: Color(0xFF241923),
  );

  static const LifeOsPalette lavenderDream = LifeOsPalette(
    id: 'lavenderDream',
    brightness: Brightness.light,
    canvas: Color(0xFFF4F0F8),
    sidebar: Color(0xFFEAE4F0),
    card: Color(0xFFFFFDFE),
    elevated: Color(0xFFEFEAF4),
    rose: Color(0xFF85435F),
    lavender: Color(0xFF665187),
    highlight: Color(0xFF715578),
    text: Color(0xFF28222F),
    secondaryText: Color(0xFF5B5362),
    border: Color(0xFFC9BED2),
    positive: Color(0xFF42694B),
    warning: Color(0xFF775300),
    negative: Color(0xFF8C3F4B),
    onAccent: Color(0xFFFFFFFF),
  );

  static const LifeOsPalette softBlush = LifeOsPalette(
    id: 'softBlush',
    brightness: Brightness.light,
    canvas: Color(0xFFFBF5F3),
    sidebar: Color(0xFFF3E9E8),
    card: Color(0xFFFFFDFC),
    elevated: Color(0xFFF8ECEB),
    rose: Color(0xFF94445F),
    lavender: Color(0xFF66577F),
    highlight: Color(0xFF80435B),
    text: Color(0xFF2E2328),
    secondaryText: Color(0xFF62555A),
    border: Color(0xFFD2C0C2),
    positive: Color(0xFF3D694F),
    warning: Color(0xFF795300),
    negative: Color(0xFF8A3E47),
    onAccent: Color(0xFFFFFFFF),
  );

  static LifeOsPalette fromId(String id) => switch (id) {
    'lavenderDream' => lavenderDream,
    'softBlush' => softBlush,
    _ => midnightRose,
  };

  ThemeData toTheme({String accentId = 'rose'}) {
    final Color primaryAccent = accentId == 'lavender' ? lavender : rose;
    final ColorScheme scheme =
        ColorScheme.fromSeed(
          seedColor: primaryAccent,
          brightness: brightness,
        ).copyWith(
          primary: primaryAccent,
          onPrimary: onAccent,
          secondary: lavender,
          onSecondary: onAccent,
          surface: card,
          onSurface: text,
          error: negative,
          onError: onAccent,
        );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      dividerColor: border,
      focusColor: primaryAccent.withValues(alpha: 0.32),
      hoverColor: primaryAccent.withValues(alpha: 0.12),
      appBarTheme: AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: text,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: sidebar,
        indicatorColor: lavender.withValues(alpha: 0.22),
        labelTextStyle: WidgetStatePropertyAll<TextStyle>(
          TextStyle(color: text, fontSize: 12),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: elevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border),
        ),
        textStyle: TextStyle(color: text),
      ),
    );
  }
}
