import "package:easy_localization/easy_localization.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:hydrated_bloc/hydrated_bloc.dart";
import "package:path_provider/path_provider.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";

import "core/configs/adapter/adapter_conf.dart";
import "core/configs/injector/injector_conf.dart";
import "core/constants/list_translation_locale.dart";
import "core/utils/observer.dart";
import "features/flutter_core_app.dart";
import "firebase_options.dart";

const _kAppConfigBox = "_app_config";
const _kFirstRunKey = "_is_first_run_done";

Future<void> _clearOldKeychainOnFirstRun() async {
  final box = await Hive.openBox(_kAppConfigBox);
  final isFirstRun = !(box.get(_kFirstRunKey, defaultValue: false) as bool);

  if (isFirstRun) {
    // On iOS, Keychain persists after uninstall, so we clear it on fresh install
    // to prevent stale tokens from previous installs.
    await const FlutterSecureStorage(
      aOptions: AndroidOptions(),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    ).deleteAll();

    await box.put(_kFirstRunKey, true);
  }
}

// Test: CI/CD trigger - $(date)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Hive.initFlutter();

  await _clearOldKeychainOnFirstRun();

  await Future.wait([
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    getTemporaryDirectory().then((dir) async {
      HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: kIsWeb
            ? HydratedStorageDirectory.web
            : HydratedStorageDirectory(dir.path),
      );
    }),
  ]);

  configureAdapter();

  // Đợi cấu hình dependency (bao gồm việc kéo SSL Pins từ Remote Config) hoàn tất
  await configureDepedencies();

  Bloc.observer = AppBlocObserver();
  debugRepaintRainbowEnabled = true;
  runApp(
    EasyLocalization(
      supportedLocales: const [vietnameseLocale, englishLocale],
      path: "assets/translations",
      startLocale: vietnameseLocale,
      child: const FlutterCoreApp(),
    ),
  );
}
