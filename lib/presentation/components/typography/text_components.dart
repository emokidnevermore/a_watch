import 'package:flutter/material.dart';
import 'package:a_watch/core/theme/typography.dart';

/// Универсальный текстовый компонент с предопределенными стилями
class AppText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? height;
  final String? fontFamily;
  final TextDecoration? decoration;

  const AppText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.fontFamily,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Text(
      text,
      style: style ??
          AppTypography.body(
            fontSize: fontSize ?? AppTypography.sizeMedium,
            fontWeight: fontWeight ?? FontWeight.normal,
            brightness: brightness,
            color: color,
            height: height,
          ).copyWith(
            fontFamily: fontFamily,
            decoration: decoration,
          ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Заголовок H1
class AppH1 extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;

  const AppH1(
    this.text, {
    super.key,
    this.textAlign,
    this.color,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Text(
      text,
      style: AppTypography.h1(
        brightness: brightness,
        color: color,
      ).copyWith(
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      textAlign: textAlign,
    );
  }
}

/// Заголовок H2
class AppH2 extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;

  const AppH2(
    this.text, {
    super.key,
    this.textAlign,
    this.color,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Text(
      text,
      style: AppTypography.h2(
        brightness: brightness,
        color: color,
      ).copyWith(
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      textAlign: textAlign,
    );
  }
}

/// Заголовок H3
class AppH3 extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;

  const AppH3(
    this.text, {
    super.key,
    this.textAlign,
    this.color,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Text(
      text,
      style: AppTypography.h3(
        brightness: brightness,
        color: color,
      ).copyWith(
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      textAlign: textAlign,
    );
  }
}

/// Заголовок H4
class AppH4 extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;

  const AppH4(
    this.text, {
    super.key,
    this.textAlign,
    this.color,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Text(
      text,
      style: AppTypography.h4(
        brightness: brightness,
        color: color,
      ).copyWith(
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      textAlign: textAlign,
    );
  }
}

/// Заголовок H5
class AppH5 extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;

  const AppH5(
    this.text, {
    super.key,
    this.textAlign,
    this.color,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Text(
      text,
      style: AppTypography.h5(
        brightness: brightness,
        color: color,
      ).copyWith(
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      textAlign: textAlign,
    );
  }
}

/// Основной текст (Body Large)
class AppBodyLarge extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? height;

  const AppBodyLarge(
    this.text, {
    super.key,
    this.textAlign,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.maxLines,
    this.overflow,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Text(
      text,
      style: AppTypography.bodyLarge(
        brightness: brightness,
        color: color,
      ).copyWith(
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Средний текст (Body Medium)
class AppBodyMedium extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? height;

  const AppBodyMedium(
    this.text, {
    super.key,
    this.textAlign,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.maxLines,
    this.overflow,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Text(
      text,
      style: AppTypography.bodyMedium(
        brightness: brightness,
        color: color,
      ).copyWith(
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Маленький текст (Body Small)
class AppBodySmall extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? height;

  const AppBodySmall(
    this.text, {
    super.key,
    this.textAlign,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.maxLines,
    this.overflow,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Text(
      text,
      style: AppTypography.bodySmall(
        brightness: brightness,
        color: color,
      ).copyWith(
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Подпись (Caption)
class AppCaption extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final int? maxLines;
  final TextOverflow? overflow;

  const AppCaption(
    this.text, {
    super.key,
    this.textAlign,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Text(
      text,
      style: AppTypography.caption(
        brightness: brightness,
        color: color,
      ).copyWith(
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Подпись Small
class AppCaptionSmall extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final int? maxLines;
  final TextOverflow? overflow;

  const AppCaptionSmall(
    this.text, {
    super.key,
    this.textAlign,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Text(
      text,
      style: AppTypography.captionSmall(
        brightness: brightness,
        color: color,
      ).copyWith(
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Подсказка (Hint)
class AppHint extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final int? maxLines;
  final TextOverflow? overflow;

  const AppHint(
    this.text, {
    super.key,
    this.textAlign,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Text(
      text,
      style: AppTypography.hint(
        fontSize: fontSize ?? AppTypography.sizeMedium,
        fontWeight: fontWeight ?? FontWeight.normal,
        brightness: brightness,
        color: color,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Label текст
class AppLabel extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;

  const AppLabel(
    this.text, {
    super.key,
    this.textAlign,
    this.color,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Text(
      text,
      style: AppTypography.label(
        brightness: brightness,
        color: color,
      ).copyWith(
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      textAlign: textAlign,
    );
  }
}

/// Секция заголовка
class AppSectionTitle extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;

  const AppSectionTitle(
    this.text, {
    super.key,
    this.textAlign,
    this.color,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Text(
      text,
      style: AppTypography.sectionTitle(
        brightness: brightness,
        color: color,
      ).copyWith(
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      textAlign: textAlign,
    );
  }
}

/// Подзаголовок
class AppSubtitle extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;

  const AppSubtitle(
    this.text, {
    super.key,
    this.textAlign,
    this.color,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Text(
      text,
      style: AppTypography.subtitle(
        brightness: brightness,
        color: color,
      ).copyWith(
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      textAlign: textAlign,
    );
  }
}
