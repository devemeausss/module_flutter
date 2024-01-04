#!/bin/bash

if [ -f "lib/widgets/phone_number_custom.dart" ]; then rm -Rf lib/widgets/phone_number_custom.dart; fi 
git clone https://github.com/devemeausss/module_flutter.git module_flutter 
cp -R module_flutter/authentication/widgets/phone_number_custom.dart lib/widgets/ 
sudo rm -R module_flutter