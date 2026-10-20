import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:shimmer/shimmer.dart';

/// A robust, centralized image widget for Only Dev (`only_dev_app`).
///
/// Features:
/// 1. Pre-validates URL strings to completely prevent "No host specified in URI" errors.
/// 2. Gracefully falls back to placeholders or initials when images are null, empty, or malformed.
/// 3. Built-in adaptive shimmer loading placeholders respecting dark/light theme.
/// 4. Support for rectangle (with customizable border radius) and circular shapes.
/// 5. BlurHash placeholder support.
class AppImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final BoxBorder? border;
  final Color? backgroundColor;
  final String? blurHash;
  final Widget? fallbackWidget;
  final String? fallbackAsset;
  final IconData fallbackIcon;
  final Widget Function(BuildContext context, String url)? placeholder;
  final Widget Function(BuildContext context, String url, dynamic error)? errorWidget;

  const AppImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.border,
    this.backgroundColor,
    this.blurHash,
    this.fallbackWidget,
    this.fallbackAsset,
    this.fallbackIcon = Icons.image_not_supported_outlined,
    this.placeholder,
    this.errorWidget,
  });

  /// Factory for circular images (e.g. avatars, thumbnail badges)
  factory AppImageWidget.circle({
    Key? key,
    required String? imageUrl,
    required double size,
    BoxBorder? border,
    Color? backgroundColor,
    Widget? fallbackWidget,
    IconData fallbackIcon = Icons.person_outline,
  }) {
    return AppImageWidget(
      key: key,
      imageUrl: imageUrl,
      width: size,
      height: size,
      shape: BoxShape.circle,
      border: border,
      backgroundColor: backgroundColor,
      fallbackWidget: fallbackWidget,
      fallbackIcon: fallbackIcon,
    );
  }

  /// Validates whether a given URL string is a well-formed HTTP/HTTPS URL with a valid host.
  static bool isValidUrl(String? url) {
    if (url == null) return false;
    final trimmed = url.trim();
    if (trimmed.isEmpty) return false;
    final uri = Uri.tryParse(trimmed);
    if (uri == null) return false;
    return uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  /// Safe ImageProvider helper to prevent "No host specified in URI" in widgets
  /// like [CircleAvatar(backgroundImage: ...)].
  static ImageProvider? safeNetworkImageProvider(
    String? url, {
    ImageProvider? fallback,
  }) {
    if (isValidUrl(url)) {
      return CachedNetworkImageProvider(url!.trim());
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final valid = isValidUrl(imageUrl);

    Widget content;

    if (!valid) {
      content = _buildFallback(context, isDark);
    } else {
      content = CachedNetworkImage(
        imageUrl: imageUrl!.trim(),
        width: width,
        height: height,
        fit: fit,
        placeholder: placeholder ?? (ctx, url) => _buildPlaceholder(ctx, isDark),
        errorWidget: errorWidget ?? (ctx, url, err) => _buildFallback(ctx, isDark),
      );
    }

    if (shape == BoxShape.circle) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: border,
          color: backgroundColor ?? (isDark ? Colors.grey[850] : Colors.grey[200]),
        ),
        clipBehavior: Clip.antiAlias,
        child: content,
      );
    }

    final effectiveRadius = borderRadius ?? BorderRadius.zero;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        border: border,
        color: backgroundColor ?? (isDark ? Colors.grey[850] : Colors.grey[200]),
      ),
      clipBehavior: Clip.antiAlias,
      child: content,
    );
  }

  Widget _buildPlaceholder(BuildContext context, bool isDark) {
    if (blurHash != null && blurHash!.trim().isNotEmpty) {
      return BlurHash(hash: blurHash!.trim());
    }

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        color: Colors.white,
      ),
    );
  }

  Widget _buildFallback(BuildContext context, bool isDark) {
    if (fallbackWidget != null) {
      return fallbackWidget!;
    }

    if (fallbackAsset != null && fallbackAsset!.isNotEmpty) {
      return Image.asset(
        fallbackAsset!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildDefaultErrorContainer(isDark),
      );
    }

    return _buildDefaultErrorContainer(isDark);
  }

  Widget _buildDefaultErrorContainer(bool isDark) {
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
      alignment: Alignment.center,
      child: Icon(
        fallbackIcon,
        color: isDark ? Colors.white38 : Colors.grey[400],
        size: (width != null && height != null)
            ? (width! < height! ? width! * 0.4 : height! * 0.4).clamp(16.0, 48.0)
            : 24.0,
      ),
    );
  }
}

/// A dedicated Circle Avatar that safely renders an avatar image or initials
/// without ever throwing "No host specified in URI".
class AppCircleAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double radius;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final BoxBorder? border;

  const AppCircleAvatar({
    super.key,
    required this.imageUrl,
    this.name,
    this.radius = 16.0,
    this.backgroundColor,
    this.textStyle,
    this.border,
  });

  String _extractInitials(String? rawName) {
    if (rawName == null || rawName.trim().isEmpty) return '?';
    final parts = rawName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final initials = _extractInitials(name);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBg = backgroundColor ??
        (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0));

    final defaultTextStyle = textStyle ??
        TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1E293B),
          fontSize: (radius * 0.75).clamp(10.0, 20.0),
          fontWeight: FontWeight.bold,
        );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: defaultBg,
        border: border,
      ),
      clipBehavior: Clip.antiAlias,
      child: AppImageWidget(
        imageUrl: imageUrl,
        width: size,
        height: size,
        shape: BoxShape.circle,
        fit: BoxFit.cover,
        fallbackWidget: Center(
          child: Text(
            initials,
            style: defaultTextStyle,
          ),
        ),
      ),
    );
  }
}

