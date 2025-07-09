class TextUtils {
  /// Formats text to prevent overflow by adding ellipsis if text is longer than maxLength
  static String formatText(String text, {int maxLength = 50}) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }

  /// Formats author name to prevent overflow (max 5 characters + ellipsis)
  static String formatAuthorName(String authorName) {
    if (authorName.length <= 5) {
      return authorName;
    }
    return '${authorName.substring(0, 5)}...';
  }

  /// Formats category tag to prevent overflow (max 5 characters + ellipsis)
  static String formatCategoryTag(String categoryTag) {
    if (categoryTag.length <= 5) {
      return categoryTag;
    }
    return '${categoryTag.substring(0, 5)}...';
  }

  /// Formats title to prevent overflow (max 30 characters + ellipsis)
  static String formatTitle(String title) {
    if (title.length <= 30) {
      return title;
    }
    return '${title.substring(0, 30)}...';
  }

  /// Formats description to prevent overflow (max 100 characters + ellipsis)
  static String formatDescription(String description) {
    if (description.length <= 100) {
      return description;
    }
    return '${description.substring(0, 100)}...';
  }

  /// Formats address to prevent overflow (max 40 characters + ellipsis)
  static String formatAddress(String address) {
    if (address.length <= 40) {
      return address;
    }
    return '${address.substring(0, 40)}...';
  }

  /// Formats email to prevent overflow (max 25 characters + ellipsis)
  static String formatEmail(String email) {
    if (email.length <= 25) {
      return email;
    }
    return '${email.substring(0, 25)}...';
  }

  /// Formats name to prevent overflow (max 20 characters + ellipsis)
  static String formatName(String name) {
    if (name.length <= 20) {
      return name;
    }
    return '${name.substring(0, 20)}...';
  }
}
