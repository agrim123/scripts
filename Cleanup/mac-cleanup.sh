#!/bin/bash bash

bytesToHuman() {
    b=${1:-0}; d=''; s=0; S=(Bytes {K,M,G,T,E,P,Y,Z}iB)
    while ((b > 1024)); do
        d="$(printf ".%02d" $((b % 1024 * 100 / 1024)))"
        b=$((b / 1024))
        (( s++ ))
    done
    echo "$b$d ${S[$s]} of space was cleaned up."
}

SECONDS=0

cleanup() {
    # ensure root level
    root=$(sudo -n uptime 2>&1 | grep -c "load")
    if [ "$root" -eq 0 ]
    then
        printf "Root Access Required \n"
        sudo -v
        printf "\n"
    fi

    # Keep-alive sudo until finished
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

    echo "Starting cleanup in 5 seconds..."
    sleep 5

    oldSpace=$(df / | tail -1 | awk '{print $4}')

    # Install Updates.
    printf "Installing needed updates.\n"
    softwareupdate -i -a > /dev/null

    # Delete Saved SSIDs For Security
    printf "Deleting saved wireless networks.\n"
    IFS=$'\n'
    for ssid in $(networksetup -listpreferredwirelessnetworks en0 | grep -v "Preferred networks on en0:" | sed "s/[\	]//g")
    do
        networksetup -removepreferredwirelessnetwork en0 "$ssid"  > /dev/null 2>&1
    done

    echo 'Empty the Trash on all mounted volumes and the main SSD...'
    sudo rm -rfv /Volumes/*/.Trashes/* &>/dev/null
    sudo rm -rfv ~/.Trash/* &>/dev/null

    echo 'Clear System Log Files...'
    sudo rm -rfv /private/var/log/asl/*.asl &>/dev/null
    sudo rm -rfv /Library/Logs/DiagnosticReports/* &>/dev/null
    sudo rm -rfv /Library/Logs/Adobe/* &>/dev/null
    rm -rfv ~/Library/Containers/com.apple.mail/Data/Library/Logs/Mail/* &>/dev/null
    rm -rfv ~/Library/Logs/CoreSimulator/* &>/dev/null
    sudo rm -rfv /private/var/log/*  > /dev/null 2>&1

    echo 'Clear Adobe Cache Files...'
    sudo rm -rfv ~/Library/Application\ Support/Adobe/Common/Media\ Cache\ Files/* &>/dev/null

    echo 'Cleanup iOS Applications...'
    rm -rfv ~/Music/iTunes/iTunes\ Media/Mobile\ Applications/* &>/dev/null

    echo 'Remove iOS Device Backups...'
    rm -rfv ~/Library/Application\ Support/MobileSync/Backup/* &>/dev/null

    printf "Deleting the quicklook files.\n"
    sudo rm -rf /private/var/folders/ > /dev/null 2>&1

    echo 'Cleanup XCode Derived Data and Archives...'
    rm -rfv ~/Library/Developer/Xcode/DerivedData/* &>/dev/null
    rm -rfv ~/Library/Developer/Xcode/Archives/* &>/dev/null

    echo 'Cleanup pip cache...'
    rm -rfv ~/Library/Caches/pip

    if type "brew" &>/dev/null; then
        echo 'Update Homebrew Recipes...'
        brew update
        echo 'Upgrade and remove outdated formulae'
        brew upgrade
        echo 'Cleanup Homebrew Cache...'
        brew cleanup -s &>/dev/null
        brew cask cleanup &>/dev/null
        rm -rfv $(brew --cache) &>/dev/null
        brew tap --repair &>/dev/null
    fi

    if type "gem" &> /dev/null; then
        echo 'Cleanup any old versions of gems'
        gem cleanup &>/dev/null
    fi

    if type "docker" &> /dev/null; then
        echo 'Cleanup Docker'
        docker rmi -f "$(docker images -q --filter 'dangling=true')" > /dev/null 2>&1
        docker system prune -af
    fi

    if [ "$PYENV_VIRTUALENV_CACHE_PATH" ]; then
        echo 'Removing Pyenv-VirtualEnv Cache...'
        rm -rfv $PYENV_VIRTUALENV_CACHE_PATH &>/dev/null
    fi

    if type "npm" &> /dev/null; then
        echo 'Cleanup npm cache...'
        npm cache clean --force
    fi

    if type "yarn" &> /dev/null; then
        echo 'Cleanup Yarn Cache...'
        yarn cache clean --force
    fi

    #Removing Known SSH Hosts
    printf "Removing known ssh hosts.\n"
    sudo rm -f /Users/"$(whoami)"/.ssh/known_hosts > /dev/null 2>&1

    echo 'Purge inactive memory...'
    sudo purge

    echo "Cleaning up bash history..."
    sudo rm /Users/"$(whoami)"/.zsh_history
    sudo rm -rf /Users/"$(whoami)"/.cache
    sudo rm -rf /Users/"$(whoami)"/zsh

    echo "Cleaning up private folders..."
    sudo rm -rf /Users/"$(whoami)"/Movies/* /Users/"$(whoami)"/Music/* /Users/"$(whoami)"/Pictures/*

    currentSpace=$(df / | tail -1 | awk '{print $4}')
    count=$((oldSpace - currentSpace))
    bytesToHuman $count

    timed="$((SECONDS / 3600)) Hours $(((SECONDS / 60) % 60)) Minutes $((SECONDS % 60)) seconds"

    echo "Completed in $timed"
}

while true; do
    read -p "Perform cleanup?[Y/N] " yn
    case $yn in
        [Yy]* ) cleanup; break;;
        * ) echo "aborting"; exit;;
    esac
done