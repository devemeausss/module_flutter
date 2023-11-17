#!/bin/bash

options=("OK" "Cancel")
echo "All settings in .vscode folder will be reset. Do you want to continue?"

select option in "${options[@]}"; do
    case $option in
        "OK")
            echo "Reseting..."
            break
            ;;
        "Cancel")
            echo "Cancelled"
            exit 0
            break
            ;;
        *) # Handle invalid options
            echo "Invalid option. Please select a number from 1 to 2."
            ;;
    esac
done

git clone https://github.com/devemeausss/module_flutter.git module_flutter 
rm -r .vscode
cp -R module_flutter/.vscode .vscode
sudo rm -R module_flutter