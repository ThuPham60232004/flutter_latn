import 'package:flutter/material.dart';

class ResponsiveText {
  static const double _baseFontSize = 14.0;

  // App Bar and Navigation
  static const double appBarTitle = 16.0;
  static const double navigationLabel = 14.0;

  // Headers and Titles
  static const double h1 = 18.0; // Main section headers
  static const double h2 = 16.0; // Sub section headers
  static const double h3 = 15.0; // Card titles
  static const double h4 = 14.0; // Small headers

  // Body Text
  static const double bodyLarge = 14.0;
  static const double bodyMedium = 13.0;
  static const double bodySmall = 12.0;
  static const double bodyTiny = 11.0;

  // Labels and Captions
  static const double label = 12.0;
  static const double caption = 11.0;
  static const double overline = 10.0;

  // Button Text
  static const double buttonLarge = 14.0;
  static const double buttonMedium = 13.0;
  static const double buttonSmall = 12.0;

  // Input and Form
  static const double inputText = 14.0;
  static const double hintText = 13.0;

  // Card and List Items
  static const double cardTitle = 15.0;
  static const double cardSubtitle = 13.0;
  static const double cardCaption = 11.0;

  // Search and Filter
  static const double searchText = 14.0;
  static const double filterText = 12.0;

  // Rating and Stats
  static const double rating = 12.0;
  static const double stats = 11.0;

  // Tags and Chips
  static const double tag = 11.0;
  static const double chip = 12.0;

  // Error and Status
  static const double error = 13.0;
  static const double status = 12.0;

  // Helper methods for common text styles
  static TextStyle get appBarTitleStyle => const TextStyle(
    fontSize: appBarTitle,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  static TextStyle get sectionHeaderStyle =>
      const TextStyle(fontSize: h1, fontWeight: FontWeight.bold);

  static TextStyle get cardTitleStyle =>
      const TextStyle(fontSize: cardTitle, fontWeight: FontWeight.bold);

  static TextStyle get cardSubtitleStyle => const TextStyle(
    fontSize: cardSubtitle,
    color: Colors.teal,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get bodyTextStyle =>
      const TextStyle(fontSize: bodyMedium, color: Colors.black87);

  static TextStyle get captionStyle =>
      const TextStyle(fontSize: caption, color: Colors.grey);

  static TextStyle get tagStyle => const TextStyle(
    fontSize: tag,
    fontWeight: FontWeight.w600,
    color: Colors.teal,
  );

  static TextStyle get ratingStyle => const TextStyle(
    fontSize: rating,
    fontWeight: FontWeight.bold,
    color: Color(0xFF199A8E),
  );
}
