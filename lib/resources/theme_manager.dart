import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/color.dart';
import 'styles_manager.dart';
import 'values_manager.dart';
import 'font_manager.dart';

// Bypassing import issue by defining colors directly. TODO: Consolidate into color.dart later.
const textPrimaryDark = Color(0xFF212121); // Soft dark grey for text
const textPrimaryLight = Color(0xFFFFFFFF);

// Light Dark Theme
ThemeData getLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    disabledColor: greyShade,
    scaffoldBackgroundColor: backgroundLite,

    // dialog theme
    dialogTheme: const DialogThemeData(
      backgroundColor: backgroundLite,
      titleTextStyle: TextStyle(
        color: textPrimaryDark,
      ),
      contentTextStyle: TextStyle(
        color: textPrimaryDark,
      ),
    ),

    // Bottom sheet theme
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: backgroundLite,
    ),

    // card theme
    cardTheme: CardThemeData(
      color: cardsLite,
      shadowColor: greyShade,
      elevation: AppSize.s4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSize.s10),
      ),
    ),

    datePickerTheme: DatePickerThemeData(
      headerBackgroundColor: primaryColor,
      todayBackgroundColor: MaterialStateProperty.all(primaryColor),
      todayBorder: BorderSide.none,
      shadowColor: primaryColor,
    ),

    // button theme
    buttonTheme: ButtonThemeData(
      buttonColor: primaryColor,
      shape: const StadiumBorder(),
      disabledColor: greyShade,
    ),

    // elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.s8),
        ),
        backgroundColor: primaryColor,
        disabledBackgroundColor: accentColor,
        disabledForegroundColor: textPrimaryLight,
        textStyle: getRegularStyle(
          color: textPrimaryLight,
          fontSize: FontSize.s16,
          fontWeight: FontWeightManager.bold,
        ),
      ),
    ),

    // input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      fillColor: textBoxLite,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSize.s8),
        borderSide: const BorderSide(color: textBoxLite),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSize.s8),
        borderSide: const BorderSide(color: textBoxLite),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSize.s8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSize.s8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSize.s8),
        borderSide: const BorderSide(color: primaryColor),
      ),
      labelStyle: getRegularStyle(color: textPrimaryDark),
      hintStyle: getRegularStyle(color: greyFontColor),
      contentPadding: const EdgeInsets.all(AppPadding.p8),
      errorStyle: getRegularStyle(color: Colors.red),
      suffixIconColor: iconColor,
      prefixIconColor: iconColor,
    ),

    // app bar theme
    appBarTheme: AppBarTheme(
      iconTheme: const IconThemeData(
        color: textPrimaryDark,
        size: AppSize.s30, // Adjusted size
      ),
      color: Colors.transparent,
      elevation: AppSize.s0,
      titleTextStyle: getRegularStyle(
        color: textPrimaryDark,
        fontSize: FontSize.s18,
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    ),

    // text theme
    textTheme: TextTheme(
      displayLarge: getHeadingStyle(color: textPrimaryDark, fontSize: FontSize.s30),
      displayMedium: getHeadingStyle(color: textPrimaryDark, fontSize: FontSize.s25),
      titleLarge: getBoldStyle(color: textPrimaryDark, fontSize: FontSize.s20),
      titleMedium: getMediumStyle(color: textPrimaryDark, fontSize: FontSize.s18),
      titleSmall: getRegularStyle(color: textPrimaryDark, fontSize: FontSize.s16),
      bodyLarge: getRegularStyle(color: textPrimaryDark, fontSize: FontSize.s14),
      bodyMedium: getRegularStyle(color: textPrimaryDark, fontSize: FontSize.s12),
      bodySmall: getLightStyle(color: greyFontColor, fontSize: FontSize.s12),
    ),

    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      surface: cardsLite,
      background: backgroundLite,
      error: Colors.red,
      onPrimary: textPrimaryLight,
      onSecondary: textPrimaryDark,
      onSurface: textPrimaryDark,
      onBackground: textPrimaryDark,
      onError: textPrimaryLight,
    ),
  );
}

// Dark Theme Settings
ThemeData getDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    disabledColor: greyShade,
    scaffoldBackgroundColor: backgroundDark,

    // dialog theme
    dialogTheme: const DialogThemeData(
      backgroundColor: backgroundDark,
      titleTextStyle: TextStyle(
        color: textPrimaryLight,
      ),
      contentTextStyle: TextStyle(
        color: textPrimaryLight,
      ),
    ),

    // Bottom sheet theme
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: backgroundDark,
    ),

    // card theme
    cardTheme: CardThemeData(
      color: cardsDark,
      shadowColor: Colors.black.withOpacity(0.5),
      elevation: AppSize.s4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSize.s10),
      ),
    ),

    // button theme
    buttonTheme: ButtonThemeData(
      buttonColor: primaryColor,
      shape: const StadiumBorder(),
      disabledColor: greyShade,
    ),

    // elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.s8),
        ),
        backgroundColor: primaryColor,
        disabledBackgroundColor: accentColor,
        disabledForegroundColor: textPrimaryLight,
        textStyle: getRegularStyle(
          color: textPrimaryLight,
          fontSize: FontSize.s16,
          fontWeight: FontWeightManager.bold,
        ),
      ),
    ),

    // input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      fillColor: textBoxDark,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSize.s8),
        borderSide: const BorderSide(color: textBoxDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSize.s8),
        borderSide: const BorderSide(color: textBoxDark),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSize.s8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSize.s8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSize.s8),
        borderSide: const BorderSide(color: primaryColor),
      ),
      labelStyle: getRegularStyle(color: textPrimaryLight),
      hintStyle: getRegularStyle(color: greyFontColor),
      contentPadding: const EdgeInsets.all(AppPadding.p8),
      errorStyle: getRegularStyle(color: Colors.red),
      suffixIconColor: iconColor,
      prefixIconColor: iconColor,
    ),

    // app bar theme
    appBarTheme: AppBarTheme(
      iconTheme: const IconThemeData(
        color: textPrimaryLight,
        size: AppSize.s30, // Adjusted size
      ),
      color: Colors.transparent,
      elevation: AppSize.s0,
      titleTextStyle: getRegularStyle(
        color: textPrimaryLight,
        fontSize: FontSize.s18,
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
    ),

    // text theme
    textTheme: TextTheme(
      displayLarge: getHeadingStyle(color: textPrimaryLight, fontSize: FontSize.s30),
      displayMedium: getHeadingStyle(color: textPrimaryLight, fontSize: FontSize.s25),
      titleLarge: getBoldStyle(color: textPrimaryLight, fontSize: FontSize.s20),
      titleMedium: getMediumStyle(color: textPrimaryLight, fontSize: FontSize.s18),
      titleSmall: getRegularStyle(color: textPrimaryLight, fontSize: FontSize.s16),
      bodyLarge: getRegularStyle(color: textPrimaryLight, fontSize: FontSize.s14),
      bodyMedium: getRegularStyle(color: textPrimaryLight, fontSize: FontSize.s12),
      bodySmall: getLightStyle(color: greyFontColor, fontSize: FontSize.s12),
    ),

    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      surface: cardsDark,
      background: backgroundDark,
      error: Colors.red,
      onPrimary: textPrimaryLight,
      onSecondary: textPrimaryDark,
      onSurface: textPrimaryLight,
      onBackground: textPrimaryLight,
      onError: textPrimaryLight,
    ),
  );
}