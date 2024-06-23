import 'dart:ui';

mixin ColorMixin {
  Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF' + hex;
    }
    return Color(int.parse(hex, radix: 16));
  }

  String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  List<double> rgbToHsl(int r, int g, int b) {
    double rd = r / 255;
    double gd = g / 255;
    double bd = b / 255;

    double max = [rd, gd, bd].reduce((a, b) => a > b ? a : b);
    double min = [rd, gd, bd].reduce((a, b) => a < b ? a : b);

    double h, s, l = (max + min) / 2;

    if (max == min) {
      h = s = 0; // achromatic
    } else {
      double d = max - min;
      s = l > 0.5 ? d / (2.0 - max - min) : d / (max + min);
      if (max == rd) {
        h = (gd - bd) / d + (gd < bd ? 6 : 0);
      } else if (max == gd) {
        h = (bd - rd) / d + 2;
      } else {
        h = (rd - gd) / d + 4;
      }
      h /= 6;
    }

    return [h, s, l];
  }

  List<int> hslToRgb(double h, double s, double l) {
    double r, g, b;

    if (s == 0) {
      r = g = b = l; // achromatic
    } else {
      double hue2rgb(double p, double q, double t) {
        if (t < 0) t += 1;
        if (t > 1) t -= 1;
        if (t < 1 / 6) return p + (q - p) * 6 * t;
        if (t < 1 / 3) return q;
        if (t < 1 / 2) return p + (q - p) * (2 / 3 - t) * 6;
        return p;
      }

      double q = l < 0.5 ? l * (1 + s) : l + s - l * s;
      double p = 2 * l - q;
      r = hue2rgb(p, q, h + 1 / 3);
      g = hue2rgb(p, q, h);
      b = hue2rgb(p, q, h - 1 / 3);
    }

    return [(r * 255).round(), (g * 255).round(), (b * 255).round()];
  }

  Color complementaryMonochromaticColor(Color color) {
    int r = color.red;
    int g = color.green;
    int b = color.blue;

    List<double> hsl = rgbToHsl(r, g, b);
    double h = hsl[0];
    double s = hsl[1];
    double l = hsl[2];

    // Find the complementary hue
    h = (h + 0.5) % 1.0;

    // Adjust saturation and lightness for monochromatic effect
    s = 0.75; // example adjustment for monochromatic
    l = 0.5; // example adjustment for monochromatic

    List<int> rgb = hslToRgb(h, s, l);
    return Color.fromARGB(255, rgb[0], rgb[1], rgb[2]);
  }
}
