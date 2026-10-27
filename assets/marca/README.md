# Arte da marca (fonte)

Fonte dos ícones e splashes do app e da web. **Não** entra no bundle (não está em `flutter: assets:`).

> Arte **provisória** (T branco + selo amarelo nas cores `AppCores`). Troque pelos arquivos finais mantendo nomes e tamanhos.

| Arquivo | Tamanho | Uso |
|---|---|---|
| `icone.png` | 1024×1024, sem transparência | Ícone iOS, Android legado, web e favicon |
| `icone_frente.png` | 1024×1024, fundo transparente | Primeiro plano do ícone adaptativo (Android 8+); o gerador aplica 16% de margem |
| `icone_monocromatico.png` | 1024×1024, branco em transparente | Ícone temático (Android 13+) |
| `splash.png` | 512×512, transparente | Splash (Android legado, iOS, web) |
| `splash_android12.png` | 1152×1152, conteúdo no círculo central de 768 | Splash Android 12+ |

O logo do app (`packages/core/assets/logo.png` 64 px, `2.0x/` 128 px e `3.0x/` 192 px) é a mesma arte com cantos arredondados.

## Regenerar

Na raiz:

```sh
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

Depois, desfaça o que os geradores fazem contra as regras do projeto (só tema claro):

```sh
git checkout -- ios/Runner.xcodeproj/project.pbxproj ios/Runner/Info.plist
git rm -rqf android/app/src/main/res/values-night
rm -rf android/app/src/main/res/values-night-v31 android/app/src/main/res/drawable-night-* web/splash/img/dark-*
sips -z 48 48 assets/marca/icone.png --out web/favicon.png
sips -z 180 180 assets/marca/icone.png --out web/icons/apple-touch-icon.png
```

E no `web/index.html` remova o `<source … dark-*.png …>` do `#splash` e confira se `<title>`, `description` e `apple-touch-icon` continuam como estavam.
