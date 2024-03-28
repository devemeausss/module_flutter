#!/bin/bash

options=("OK" "Cancel")
echo "Do you want to build to Testflight?"

selected_options=2;
select option in "${options[@]}"; do
    case $option in
        "OK")
            selected_options=1
            break
            ;;
        "Cancel")
            selected_options=2
            break
            ;;
        *) # Handle invalid options
            echo "Invalid option. Please select a number from 1 to 2."
            ;;
    esac
done

if [ -d "build/ios" ]; then
    cd build/ios
    rm -rf ipa
    cd ..
    cd ..
fi

cd ios
BUILD_NUMBER=$(awk "/^BUILD_NUMBER/{print $NF}" config/dev/Version.txt)
RESULT=$(sed "s/BUILD_NUMBER = //g" <<< $BUILD_NUMBER) 
INCREASE_NUMBER=$((RESULT + 1)) 
sed -i "" "s/BUILD_NUMBER = ${RESULT}/BUILD_NUMBER = ${INCREASE_NUMBER}/g" config/dev/Version.txt 
VERSION_STRING=$(awk "/^VERSION_STRING/{print $NF}" config/dev/Version.txt) 
RESULT_VERSION_STRING=$(sed "s/VERSION_STRING = //g" <<< $VERSION_STRING) 
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $INCREASE_NUMBER" "Runner/Info.plist" 
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $RESULT_VERSION_STRING" "Runner/Info.plist" 
flutter build ipa --export-method ad-hoc --flavor dev -t lib/main_dev.dart

cd ..
FILE_PATH=""
for path in "build/ios/ipa"/*; do
  if [[ "$path" == *".ipa"* ]]; then
    FILE_PATH=$path
  fi
done

## Automatic upload ipa to Firebase Distribution
firebase appdistribution:distribute "$PWD/$FILE_PATH" --app 1:1111111:ios:1111111111 --groups "Testers" --release-notes "Version: $RESULT_VERSION_STRING ($INCREASE_NUMBER)"

if [[ $selected_options = 1 ]]; then 
    flutter build ipa --flavor dev -t lib/main_dev.dart
fi