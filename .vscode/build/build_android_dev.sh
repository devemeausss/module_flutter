#!/bin/bash

cd android
./gradlew -PfinalDev
flutter build apk --flavor dev -t lib/main_dev.dart

VERSION_NAME_DEV=$(awk "/^VERSION_NAME_DEV/{print $NF}" app/version.properties)
RESULT_VERSION_NAME=$(sed "s/VERSION_NAME_DEV=//g" <<< $VERSION_NAME_DEV) 
VERSION_NAME_INC_DEV=$(awk "/^VERSION_NAME_INC_DEV/{print $NF}" app/version.properties)
RESULT_VERSION_NAME_INC_DEV=$(sed "s/VERSION_NAME_INC_DEV=//g" <<< $VERSION_NAME_INC_DEV) 
VERSION_CODE_DEV=$(awk "/^VERSION_CODE_DEV/{print $NF}" app/version.properties)
RESULT_VERSION_CODE_DEV=$(sed "s/VERSION_CODE_DEV=//g" <<< $VERSION_CODE_DEV) 
VERSION="v${RESULT_VERSION_NAME}.${RESULT_VERSION_NAME_INC_DEV}_${RESULT_VERSION_CODE_DEV}"

FILE_NAME=""

while read p; do
if [[ "$p" == *"outputFileName"* ]]; then
    FILE_NAME="$p"
fi
done <app/build.gradle

FILE_NAME=$(sed "s/outputFileName = //g" <<< $FILE_NAME)
SEARCH_STRING="$"
rest=${FILE_NAME#*$SEARCH_STRING}
LAST_CHARACTER_OF_NAME=$(( ${#FILE_NAME} - ${#rest} - ${#SEARCH_STRING} ))
FILE_NAME=${FILE_NAME:1:LAST_CHARACTER_OF_NAME-2}

cd ..
## Automatic upload apk to Firebase Distribution
firebase appdistribution:distribute $PWD/build/app/outputs/apk/dev/release/$FILE_NAME.dev.$VERSION.apk --app 1:1111111:android:111111111 --groups "Testers"