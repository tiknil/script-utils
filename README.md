# Script-utils

## `genloc`

E' uno script che semplifica la gestione dei file delle stringhe localizzate per le piattaforme Android e iOS.

Modalità di utilizzo:

1. Rendere eseguibile il file `genloc.rb` con il comando:
   ```
   chmod +x genloc.rb
   ```
2. Eseguire il comando passando tutti gli argomenti secondo le specifiche:
   ```
   >>> GENerate LOCalizations: genloc.rb [options]

   Attenzione: per funzionare correttamente per i progetti iOS è necessario che le cartelle
   di localizzazione (en.lproj, it.lproj, etc) siano già presenti nella cartella /Resources

    -t, --twine twine file path      Path del file twine

    -p, --path project path          Path del progetto
                                    (es: ~/App/Android/ProjectName ovvero la cartella che contiene "app" |
                                    ~/App/iOS/ProjectName/ProjectName ovvero la cartella che contiene "Resources")

    -o, --os [OS]                    Sistema operativo (ios, android)

    -l, --languages en, it           Lista di lingue dei file localizzati (es: en, it, es) -
                                      Valido solo per Android.
                                      Per iOS vengono controllate le cartelle en.lproj etc. presenti nella cartella "Resources"
    -f, --force                      Per non attendere la conferma interattiva dell'utente ma eseguire direttamente il comando.
                                     Utile per utilizzarlo nei tool automatici
    -h, --help                       Visualizza help
   ```

### Esempi:

#### iOS
```
./genloc.rb -t ~/App/Localizations/appname-localization/twine.txt -p ~/App/iOS/AppName/AppName -o ios
```

#### Android
```
./genloc.rb -t ~/App/Localizations/appname-localization/twine.txt -p ~/App/Android/AppName -o android
```

## `twine2xls`

E' uno script che permette di tradurre i file twine in `xlsx` e viceversa.

Scaricare il sorgente e renderlo eseguibile con il comando:

`chmod +x twine2xls.rb`

Per eseguire l'importazione (da `xlsx` a twine):

`./twine2xls.rb import -i [path file excel di input] -o [path file twine di output]`

Per eseguire l'esportazione (da twine a `xlsx`):

`./twine2xls.rb export -i [path file twine di input] -o [path file excel di output]`
