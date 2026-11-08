import 'package:flutter/foundation.dart';

enum FilterPreset {
  original,
  cyberpunk,
  vintage,
  warmGold,
  coldBlue,
  noir,
}

@immutable
class ColorAdjustments {
  final FilterPreset preset;
  final double brightness; // -1.0 to 1.0 (0.0 default)
  final double contrast; // 0.5 to 1.5 (1.0 default)
  final double saturation; // 0.0 to 2.0 (1.0 default)
  final double warmth; // -1.0 to 1.0 (0.0 default)

  const ColorAdjustments({
    this.preset = FilterPreset.original,
    this.brightness = 0.0,
    this.contrast = 1.0,
    this.saturation = 1.0,
    this.warmth = 0.0,
  });

  bool get isDefault =>
      preset == FilterPreset.original &&
      brightness == 0.0 &&
      contrast == 1.0 &&
      saturation == 1.0 &&
      warmth == 0.0;

  ColorAdjustments copyWith({
    FilterPreset? preset,
    double? brightness,
    double? contrast,
    double? saturation,
    double? warmth,
  }) {
    return ColorAdjustments(
      preset: preset ?? this.preset,
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      saturation: saturation ?? this.saturation,
      warmth: warmth ?? this.warmth,
    );
  }

  /// Generates a 4x5 ColorFilter matrix for GPU-accelerated real-time rendering
  List<double> toColorFilterMatrix() {
    // 1. Base saturation calculation
    double s = saturation;
    if (preset == FilterPreset.noir) s = 0.0;
    if (preset == FilterPreset.cyberpunk) s = 1.4;
    if (preset == FilterPreset.vintage) s = 0.75;

    const rw = 0.3086;
    const gw = 0.6094;
    const bw = 0.0820;

    final invS = 1.0 - s;
    final rR = invS * rw + s;
    final rG = invS * gw;
    final rB = invS * bw;

    final gR = invS * rw;
    final gG = invS * gw + s;
    final gB = invS * bw;

    final bR = invS * rw;
    final bG = invS * gw;
    final bB = invS * bw + s;

    // 2. Contrast & Brightness offsets
    double c = contrast;
    if (preset == FilterPreset.cyberpunk) c = 1.25;
    if (preset == FilterPreset.noir) c = 1.3;

    final contrastOffset = 128.0 * (1.0 - c);
    final brightnessOffset = brightness * 100.0;
    final baseOffset = contrastOffset + brightnessOffset;

    // 3. Warmth offsets (warm adds red/yellow, cool adds blue)
    double rOffset = baseOffset;
    double gOffset = baseOffset;
    double bOffset = baseOffset;

    if (preset == FilterPreset.warmGold || warmth > 0) {
      final w = preset == FilterPreset.warmGold ? 20.0 : warmth * 25.0;
      rOffset += w;
      gOffset += (w * 0.5);
    } else if (preset == FilterPreset.coldBlue || warmth < 0) {
      final w = preset == FilterPreset.coldBlue ? 25.0 : warmth.abs() * 25.0;
      bOffset += w;
    } else if (preset == FilterPreset.vintage) {
      rOffset += 15.0;
      gOffset += 8.0;
      bOffset -= 10.0;
    }

    return [
      rR * c, rG * c, rB * c, 0, rOffset,
      gR * c, gG * c, gB * c, 0, gOffset,
      bR * c, bG * c, bB * c, 0, bOffset,
      0,      0,      0,      1, 0,
    ];
  }
}
