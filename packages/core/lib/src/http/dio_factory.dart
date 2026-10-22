export 'package:tabloide_core/src/http/dio_factory_stub.dart'
    if (dart.library.io) 'package:tabloide_core/src/http/dio_factory_native.dart'
    if (dart.library.js_interop) 'package:tabloide_core/src/http/dio_factory_browser.dart';
