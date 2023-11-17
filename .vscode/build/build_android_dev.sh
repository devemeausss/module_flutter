#!/bin/bash
cd android
./gradlew -PfinalDev
flutter build apk --flavor dev -t lib/main_dev.dart

cd ..
## Automatic upload apk to Firebase Distribution
firebase appdistribution:distribute /path/to/.apk  \ 
    --app 1:1111111:dev-android:11111111111111 \
    --groups "Testers"