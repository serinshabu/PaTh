import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_os/app/theme/life_os_palette.dart';

void main() {
  const List<LifeOsPalette> palettes = <LifeOsPalette>[
    LifeOsPalette.midnightRose,
    LifeOsPalette.lavenderDream,
    LifeOsPalette.softBlush,
  ];

  test('theme accent selection preserves accessible primary text', () {
    for (final LifeOsPalette palette in palettes) {
      for (final String accentId in <String>['rose', 'lavender']) {
        final ThemeData theme = palette.toTheme(accentId: accentId);
        expect(
          _contrast(theme.colorScheme.primary, palette.card),
          greaterThanOrEqualTo(4.5),
          reason: '${palette.id} $accentId accent on card',
        );
        expect(
          _contrast(theme.colorScheme.onPrimary, theme.colorScheme.primary),
          greaterThanOrEqualTo(4.5),
          reason: '${palette.id} $accentId button label',
        );
      }
    }
  });
  test('material themes expose visible keyboard focus and hover cues', () {
    for (final LifeOsPalette palette in palettes) {
      final ThemeData theme = palette.toTheme();
      expect(theme.focusColor.a, greaterThan(0));
      expect(theme.hoverColor.a, greaterThan(0));
    }
  });

  test('text and semantic accents meet AA contrast on theme surfaces', () {
    for (final LifeOsPalette palette in palettes) {
      expect(
        _contrast(palette.text, palette.canvas),
        greaterThanOrEqualTo(4.5),
        reason: '${palette.id} primary text on canvas',
      );
      expect(
        _contrast(palette.text, palette.card),
        greaterThanOrEqualTo(4.5),
        reason: '${palette.id} primary text on card',
      );
      expect(
        _contrast(palette.secondaryText, palette.canvas),
        greaterThanOrEqualTo(4.5),
        reason: '${palette.id} secondary text on canvas',
      );
      expect(
        _contrast(palette.secondaryText, palette.card),
        greaterThanOrEqualTo(4.5),
        reason: '${palette.id} secondary text on card',
      );
      expect(
        _contrast(palette.rose, palette.card),
        greaterThanOrEqualTo(4.5),
        reason: '${palette.id} rose accent on card',
      );
      expect(
        _contrast(palette.lavender, palette.card),
        greaterThanOrEqualTo(4.5),
        reason: '${palette.id} lavender accent on card',
      );
      expect(
        _contrast(palette.positive, palette.card),
        greaterThanOrEqualTo(4.5),
        reason: '${palette.id} positive status on card',
      );
      expect(
        _contrast(palette.warning, palette.card),
        greaterThanOrEqualTo(4.5),
        reason: '${palette.id} warning status on card',
      );
      expect(
        _contrast(palette.negative, palette.card),
        greaterThanOrEqualTo(4.5),
        reason: '${palette.id} negative status on card',
      );
      expect(
        _contrast(palette.onAccent, palette.rose),
        greaterThanOrEqualTo(4.5),
        reason: '${palette.id} accent button text',
      );
    }
  });
}

double _contrast(Color foreground, Color background) {
  final double first = _luminance(foreground);
  final double second = _luminance(background);
  final double lighter = math.max(first, second);
  final double darker = math.min(first, second);
  return (lighter + 0.05) / (darker + 0.05);
}

double _luminance(Color color) {
  double linear(int value) {
    final double channel = value / 255;
    if (channel <= 0.04045) return channel / 12.92;
    return math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }

  return (0.2126 * linear(color.red)) +
      (0.7152 * linear(color.green)) +
      (0.0722 * linear(color.blue));
}
