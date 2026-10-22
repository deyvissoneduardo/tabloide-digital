// Cada build compila só o bootstrap da sua plataforma; com `kIsWeb` o mobile
// compilaria código de navegador e quebraria.
export 'package:tabloide_front/bootstrap/bootstrap_stub.dart'
    if (dart.library.io) 'package:tabloide_front/bootstrap/bootstrap_app.dart'
    if (dart.library.js_interop) 'package:tabloide_front/bootstrap/bootstrap_web.dart';
