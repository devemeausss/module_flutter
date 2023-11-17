#!/bin/bash

cd android
./gradlew -PfinalStage
flutter build apk --flavor stage -t lib/main_stage.dart
cd ..

## Automatic upload apk to Firebase Distribution
firebase appdistribution:distribute /path/to/.apk  \ 
    --app 1:1111111:stage-android:11111111111111 \
    --groups "Testers"