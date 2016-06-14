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
