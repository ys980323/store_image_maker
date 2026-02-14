import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'src/app/store_image_maker_app.dart';

export 'src/app/store_image_maker_app.dart';
export 'src/models/store_image_models.dart';
export 'src/pages/store_image_maker_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeAds();
  runApp(const StoreImageMakerApp());
}

Future<void> _initializeAds() async {
  if (kIsWeb || bool.fromEnvironment('FLUTTER_TEST')) {
    return;
  }

  if (defaultTargetPlatform != TargetPlatform.android &&
      defaultTargetPlatform != TargetPlatform.iOS) {
    return;
  }

  await MobileAds.instance.initialize();
}
