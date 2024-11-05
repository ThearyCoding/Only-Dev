import 'dart:io' show Platform;
import 'package:flutter/rendering.dart';
import 'package:photo_manager/photo_manager.dart' show AssetType;

/// All text delegates.
const List<AssetPickerTextDelegate> assetPickerTextDelegates = <AssetPickerTextDelegate>[
  EnglishAssetPickerTextDelegate(),
  KhmerAssetPickerTextDelegate(),
];

/// Obtain the text delegate from the given locale.
AssetPickerTextDelegate assetPickerTextDelegateFromLocale(Locale? locale) {
  if (locale == null) {
    return const EnglishAssetPickerTextDelegate();
  }
  final String languageCode = locale.languageCode.toLowerCase();
  for (final AssetPickerTextDelegate delegate in assetPickerTextDelegates) {
    if (delegate.languageCode == languageCode) {
      return delegate;
    }
  }
  return const EnglishAssetPickerTextDelegate();
}

/// Text delegate that controls text in widgets.
abstract class AssetPickerTextDelegate {
  const AssetPickerTextDelegate();

  String get languageCode;

  String get confirm;
  String get cancel;
  String get edit;
  String get gifIndicator;
  String get livePhotoIndicator;
  String get loadFailed;
  String get original;
  String get preview;
  String get select;
  String get emptyList;
  String get unSupportedAssetType;
  String get unableToAccessAll;
  String get viewingLimitedAssetsTip;
  String get changeAccessibleLimitedAssets;
  String get accessAllTip;
  String get goToSystemSettings;
  String get accessLimitedAssets;
  String get accessiblePathName;
  String durationIndicatorBuilder(Duration duration);
  String get sTypeAudioLabel;
  String get sTypeImageLabel;
  String get sTypeVideoLabel;
  String get sTypeOtherLabel;
  String semanticTypeLabel(AssetType type);
  String get sActionPlayHint;
  String get sActionPreviewHint;
  String get sActionSelectHint;
  String get sActionSwitchPathLabel;
  String get sActionUseCameraHint;
  String get sNameDurationLabel;
  String get sUnitAssetCountLabel;
  AssetPickerTextDelegate get semanticsTextDelegate => this;
}

/// [AssetPickerTextDelegate] implements with English.
class EnglishAssetPickerTextDelegate extends AssetPickerTextDelegate {
  const EnglishAssetPickerTextDelegate();

  @override
  String get languageCode => 'en';

  @override
  String get confirm => 'Confirm';
  @override
  String get cancel => 'Cancel';
  @override
  String get edit => 'Edit';
  @override
  String get gifIndicator => 'GIF';
  @override
  String get livePhotoIndicator => 'LIVE';
  @override
  String get loadFailed => 'Load failed';
  @override
  String get original => 'Origin';
  @override
  String get preview => 'Preview';
  @override
  String get select => 'Select';
  @override
  String get emptyList => 'Empty list';
  @override
  String get unSupportedAssetType => 'Unsupported HEIC asset type.';
  @override
  String get unableToAccessAll => 'Unable to access all assets on the device';
  @override
  String get viewingLimitedAssetsTip =>
      'Only view assets and albums accessible to app.';
  @override
  String get changeAccessibleLimitedAssets =>
      'Click to update accessible assets';
  @override
  String get accessAllTip =>
      'App can only access some assets on the device. Go to system settings and allow app to access all assets on the device.';
  @override
  String get goToSystemSettings => 'Go to system settings';
  @override
  String get accessLimitedAssets => 'Continue with limited access';
  @override
  String get accessiblePathName => 'Accessible assets';

  @override
  String durationIndicatorBuilder(Duration duration) {
    const String separator = ':';
    final String minute = duration.inMinutes.toString().padLeft(2, '0');
    final String second = (duration - Duration(minutes: duration.inMinutes))
        .inSeconds
        .toString()
        .padLeft(2, '0');
    return '$minute$separator$second';
  }

  @override
  String get sTypeAudioLabel => 'Audio';
  @override
  String get sTypeImageLabel => 'Image';
  @override
  String get sTypeVideoLabel => 'Video';
  @override
  String get sTypeOtherLabel => 'Other asset';

  @override
  String semanticTypeLabel(AssetType type) {
    switch (type) {
      case AssetType.audio:
        return sTypeAudioLabel;
      case AssetType.image:
        return sTypeImageLabel;
      case AssetType.video:
        return sTypeVideoLabel;
      case AssetType.other:
      default:
        return sTypeOtherLabel;
    }
  }

  @override
  String get sActionPlayHint => 'play';
  @override
  String get sActionPreviewHint => 'preview';
  @override
  String get sActionSelectHint => 'select';
  @override
  String get sActionSwitchPathLabel => 'switch path';
  @override
  String get sActionUseCameraHint => 'use camera';
  @override
  String get sNameDurationLabel => 'duration';
  @override
  String get sUnitAssetCountLabel => 'count';
}

/// [AssetPickerTextDelegate] implements with Khmer.
class KhmerAssetPickerTextDelegate extends AssetPickerTextDelegate {
  const KhmerAssetPickerTextDelegate();

  @override
  String get languageCode => 'km';

  @override
  String get confirm => 'បញ្ជាក់';
  @override
  String get cancel => 'បោះបង់';
  @override
  String get edit => 'កែប្រែ';
  @override
  String get gifIndicator => 'GIF';
  @override
  String get livePhotoIndicator => 'LIVE';
  @override
  String get loadFailed => 'ទាញយកបានបរាជ័យ';
  @override
  String get original => 'ដើម';
  @override
  String get preview => 'មើលជាមុន';
  @override
  String get select => 'ជ្រើសរើស';
  @override
  String get emptyList => 'បញ្ជីទទេ';
  @override
  String get unSupportedAssetType => 'ប្រភេទទ្រព្យសម្បត្តិ HEIC មិនគាំទ្រ។';
  @override
  String get unableToAccessAll => 'មិនអាចចូលទៅទ្រព្យសម្បត្តិទាំងអស់នៅលើឧបករណ៍';
  @override
  String get viewingLimitedAssetsTip =>
      'អាចមើលបានតែទ្រព្យសម្បត្តិ និងអាល់ប៊ុមដែលកម្មវិធីអាចចូលដំណើរការបានប៉ុណ្ណោះ។';
  @override
  String get changeAccessibleLimitedAssets =>
      'ចុចដើម្បីអាប់ដេតទ្រព្យសម្បត្តិដែលអាចចូលដំណើរការ';
  @override
  String get accessAllTip =>
      'កម្មវិធីអាចចូលដំណើរការបានតែប៉ុន្មានទ្រព្យសម្បត្តិនៅលើឧបករណ៍។ ចូលទៅការកំណត់ប្រព័ន្ធហើយអនុញ្ញាតឱ្យកម្មវិធីចូលដំណើរការទៅទ្រព្យសម្បត្តិទាំងអស់នៅលើឧបករណ៍។';
  @override
  String get goToSystemSettings => 'ចូលទៅការកំណត់ប្រព័ន្ធ';
  @override
  String get accessLimitedAssets => 'បន្តជាមួយការចូលដំណើរការដែលមានកំណត់';
  @override
  String get accessiblePathName => 'ទ្រព្យសម្បត្តិដែលអាចចូលដំណើរការ';

  @override
  String durationIndicatorBuilder(Duration duration) {
    const String separator = ':';
    final String minute = duration.inMinutes.toString().padLeft(2, '0');
    final String second = (duration - Duration(minutes: duration.inMinutes))
        .inSeconds
        .toString()
        .padLeft(2, '0');
    return '$minute$separator$second';
  }

  @override
  String get sTypeAudioLabel => 'អូឌីយ៉ូ';
  @override
  String get sTypeImageLabel => 'រូបភាព';
  @override
  String get sTypeVideoLabel => 'វីដេអូ';
  @override
  String get sTypeOtherLabel => 'ទ្រព្យសម្បត្តិផ្សេងទៀត';

  @override
  String semanticTypeLabel(AssetType type) {
    switch (type) {
      case AssetType.audio:
        return sTypeAudioLabel;
      case AssetType.image:
        return sTypeImageLabel;
      case AssetType.video:
        return sTypeVideoLabel;
      case AssetType.other:
      default:
        return sTypeOtherLabel;
    }
  }

  @override
  String get sActionPlayHint => 'លេង';
  @override
  String get sActionPreviewHint => 'មើលជាមុន';
  @override
  String get sActionSelectHint => 'ជ្រើសរើស';
  @override
  String get sActionSwitchPathLabel => 'ផ្លាស់ប្តូរផ្លូវ';
  @override
  String get sActionUseCameraHint => 'ប្រើកាមេរ៉ា';
  @override
  String get sNameDurationLabel => 'រយៈពេល';
  @override
  String get sUnitAssetCountLabel => 'ចំនួន';
}
