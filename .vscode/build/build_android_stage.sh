#!/bin/bash

cd android
./gradlew -PfinalStage
flutter build apk --flavor stage -t lib/main_stage.dart

VERSION_NAME_STAGE=$(awk "/^VERSION_NAME_STAGE/{print $NF}" app/version.properties)
RESULT_VERSION_NAME=$(sed "s/VERSION_NAME_STAGE=//g" <<< $VERSION_NAME_STAGE) 
VERSION_NAME_INC_STAGE=$(awk "/^VERSION_NAME_INC_STAGE/{print $NF}" app/version.properties)
RESULT_VERSION_NAME_INC_STAGE=$(sed "s/VERSION_NAME_INC_STAGE=//g" <<< $VERSION_NAME_INC_STAGE) 
VERSION_CODE_STAGE=$(awk "/^VERSION_CODE_STAGE/{print $NF}" app/version.properties)
RESULT_VERSION_CODE_STAGE=$(sed "s/VERSION_CODE_STAGE=//g" <<< $VERSION_CODE_STAGE) 
VERSION="v${RESULT_VERSION_NAME}.${RESULT_VERSION_NAME_INC_STAGE}_${RESULT_VERSION_CODE_STAGE}"

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
firebase appdistribution:distribute $PWD/build/app/outputs/apk/stage/release/$FILE_NAME.stage.$VERSION.apk --app 1:1111111:android:111111111 --groups "Testers"