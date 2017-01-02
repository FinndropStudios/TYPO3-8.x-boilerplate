#!/bin/bash

#
# include config arrays
#
source ingredients/status.sh
source ingredients/globals.sh

#
# set sys_ext to be enabled when generating PackageStates.php
#
# TYPO3_ACTIVE_FRAMEWORK_EXTENSIONS="info,info_pagetsconfig"

#
# check wether running in TYPO3-docker-boilerplate or not
#
function checkDockermode {
    if [ -e "dockermode" ]; then
        echo -e "${ORANGE}You are running this instance in dockermode${NC}"
        DOCKERMODE=true
    else
        DOCKERMODE=false
    fi
}

#
# check requirements
#
function checkComposer {
    # check for composer
    echo -e "Checking wether composer is installed or not"
    composer -v > /dev/null 2>&1
    COMPOSER_IS_INSTALLED=$?
    if [[ ${COMPOSER_IS_INSTALLED} -ne 0 ]] && [ "${DOCKERMODE}" = false ]; then
        # install composer locally
        echo -e "${RED}Composer is not installed globally. Composer will get installed locally${NC}"
        mkdir composer
        EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig)
        php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
        ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');")
        if [ "${EXPECTED_SIGNATURE}" != "${ACTUAL_SIGNATURE}" ]
        then
            >&2 echo -e '${RED}ERROR: Invalid installer signature${NC}'
            rm composer-setup.php
            exit 1
        fi
        php composer-setup.php --install-dir=composer --quiet
        rm composer-setup.php
        echo -e "${GREEN}Composer is now installed locally${NC}"
        COMPOSERINSTALL="php composer/composer.phar install"
        COMPOSERINSTALLNODEV="php composer/composer.phar install --no-dev"
        COMPOSERUPDATE="php composer/composer.phar update"
        COMPOSERSELFUPDATE="php composer/composer.phar self-update"
    else
        echo -e "${GREEN}Composer is installed globally${NC}"
        COMPOSERINSTALL="composer install"
        COMPOSERINSTALLNODEV="composer install --no-dev"
        COMPOSERUPDATE="composer update"
        COMPOSERSELFUPDATE="composer self-update"
    fi
}

#
# run composer
#
function runComposer {
    case "$1" in
    "install")
        echo -e "Starting 'composer install'"
        eval ${COMPOSERINSTALL}
        echo -e "${GREEN}Finished 'composer install'${NC}"
        ;;
    "installnodev")
        echo -e "Starting 'composer install --no-dev'"
        eval ${COMPOSERINSTALLNODEV}
        echo -e "${GREEN}Finished 'composer install --no-dev'${NC}"
        ;;
    "update")
        echo -e "Starting 'composer update'"
        eval ${COMPOSERUPDATE}
        echo -e "${GREEN}Finished 'composer update'${NC}"
        ;;
    "selfupdate")
        if [[ $COMPOSER_IS_INSTALLED -ne 1 ]]; then
            echo -e "Starting 'composer self-update'"
            eval ${COMPOSERSELFUPDATE}
            echo -e "${GREEN}Finished 'composer self-update'${NC}"
        else
            if [ "${DOCKERMODE}" = true ] ; then
                echo -e "Starting 'composer self-update'"
                eval ${COMPOSERSELFUPDATE}
                echo -e "${GREEN}Finished 'composer self-update'${NC}"
            else
                echo -e "${RED}'composer self-update' not possible. Please perform this step manually${NC}"
            fi
        fi
        ;;
    *)
        ;;
    esac
}

#
# redefine origin of repository
#
function reInitRepository {
    read -r -p $'Do you want to remove the .git folder and set up the project as a new one \e[31m(recommended but needed if not done yet)\e[0m? [y/N] ' response
    case ${response} in
        [yY][eE][sS]|[yY])
            rm .git/
            git init
            read -r -p "Set git remote: " remote
            git remote add origin ${remote}
            echo -e "${GREEN}Repository initialised with new origin:${NC}"
            echo -e "${remote}"
            ;;
        *)
            ;;
    esac
}

#
# grab individual project settings
#
function promptSettings {
    rm ingredients/status.sh
    echo "INSTALLED=false" >> ingredients/status.sh
    file=ingredients/database.sh
    if [ "${DOCKERMODE}" = true ] ; then
        echo "DATABASENAME=typo3" >> ${file}
        echo "DATABASEUSERNAME=dev" >> ${file}
        echo "DATABASEUSERNAME=dev" >> ${file}
        echo "DATABASEHOSTNAME=mysql" >> ${file}
        echo "DATABASEPORT=" >> ${file}
        source ${file}
    else
        if [ -e "${file}" ]; then
            rm ${file}
        fi
        touch ${file}
        echo -e "${ORANGE}Database settings:${NC}"
        read -r -p "Database name: " DATABASENAME
        echo "DATABASENAME=${DATABASENAME}" >> ${file}
        read -r -p "Database user name: " DATABASEUSERNAME
        echo "DATABASEUSERNAME=${DATABASEUSERNAME}" >> ${file}
        read -r -p "Database password: " DATABASEUSERPASSWORD
        echo "DATABASEUSERNAME=${DATABASEUSERPASSWORD}" >> ${file}
        read -r -p "Database host name: " DATABASEHOSTNAME
        echo "DATABASEHOSTNAME=${DATABASEHOSTNAME}" >> ${file}
        read -r -p "Database port: " DATABASEPORT
        echo "DATABASEPORT=${DATABASEPORT}" >> ${file}
        echo -e "${ORANGE}Path settings:${NC}"
    fi
    file=ingredients/paths.sh
    if [ -e "${file}" ]; then
        rm ${file}
    fi
    touch ${file}
    read -r -p "Deployment path on staging environment: " STAGINGPATH
    echo "STAGINGPATHS=${STAGINGPATH}" >> ${file}
    read -r -p "Deployment path on production environment: " PRODUCTIONPATH
    echo "PRODUCTIONPATH=${PRODUCTIONPATH}" >> ${file}
}

#
# handle project settings
#
function grabSettings {
    if [ "${INSTALLED}" = true ] ; then
        echo -e "${RED}Seems you already ran this installer.${NC}"
        read -r -p "Do you want to overwrite settings? [y/N] " response
        case $response in
            [yY][eE][sS]|[yY])
                promptSettings
                ;;
            *)
                source ingredients/database.sh
                source ingredients/paths.sh
                ;;
        esac
    else
        promptSettings
    fi
}

#
# running TYPO3 first install routine via TYPO3 console
#
function typo3Install {
    ./vendor/bin/typo3cms install:fixfolderstructure
    echo -e "${GREEN}Folderstructure checked and fixed${NC}"
    # when using TYPO3_ACTIVE_FRAMEWORK_EXTENSIONS remove --activate-default=true
    ./vendor/bin/typo3cms install:generatepackagestates --activate-default=true
    echo -e "${GREEN}PackageStates.php generated${NC}"
    echo -e "Starting TYPO3 setup routine using your provided settings"
    # needs debug
    ./vendor/bin/typo3cms install:setup --non-interactive --database-user-name=${DATABASEUSERNAME} --database-user-password=${DATABASEUSERPASSWORD} --database-host-name=${DATABASEHOSTNAME} --database-port=${DATABASEPORT} --use-existing-database=${DATABASENAME} --admin-user-name=temp --admin-password=temp --site-setup-type=no
    echo -e "${GREEN}TYPO3 successfully installed${NC}"
    echo -e "Removing file 'FIRST_INSTALL'"
    rm "web/typo3conf/FIRST_INSTALL"
    echo -e "${GREEN}'FIRST_INSTALL' removed successfully${NC}"

}

#
# importing database with general data (including admin user and some default pages)
#
function importDatabase {
    echo -e "Importing initial data to database"
    mysql -u ${DATABASEUSERNAME} -h ${DATABASEHOSTNAME} -p ${DATABASEUSERPASSWORD} ${DATABASENAME} < initialdump.sql
    if [ "$?" -eq 0 ]; then
        echo -e "${GREEN}Data successfully imported${NC}"
    else
        echo -e "${RED}An error occured while importing data.${NC}"
        read -r -p "Do you want to try again? [y/N] " response
        case ${response} in
            [yY][eE][sS]|[yY])
                importDatabase
                ;;
            *)
                ;;
        esac
    fi
}

#
# get language list from file
#
function showLanguageList {
    while IFS='' read -r line || [[ -n "${line}" ]]; do
        echo ${line}
    done < "ingredients/languages.sh"
    installFurtherLanguages
}

#
# preinstall further languages
#
function installFurtherLanguages {
    read -r -p $'Which language do you want to install (key needed, type \e[33mlist\e[0m for a full list of available languages or \e[33mdone\e[0m when you are done)?' language
    case ${language} in
        af|sq|ar|eu|bs|pt_BR|bg|ch|zh|da|eo|et|fi|fr|fr_CA|fo|ka|el|kl|gl|he|hl|is|it|ja|ca|km|ko|hr|lv|lt|ms|nl|no|fa|pl|pt|ro|ru|sv|sr|sk|sl|es|th|cs|tr|uk|hu|vi)
            echo -e "Installing language (${language})"
            ./vendor/bin/typo3cms language:update ${language}
            echo -e "${GREEN}Installed language (${language})${NC}"
            installFurtherLanguages
            ;;
        list)
            showLanguageList
            ;;
        *)
            ;;
    esac
}

#
# preinstall different languages
#
function installLanguages {
    echo -e "Installing german"
    ./vendor/bin/typo3cms language:update de
    echo -e "${GREEN}Installed german${NC}"
    read -r -p "Do you want to install english language pack? [y/N] " response
    case ${response} in
        [yY][eE][sS]|[yY])
            echo -e "Installing english"
            ./vendor/bin/typo3cms language:update en
            echo -e "${GREEN}Installed english${NC}"
            ;;
        *)
            ;;
    esac
    read -r -p "Do you want to install any further languages? [y/N] " response
    case ${response} in
        [yY][eE][sS]|[yY])
            installFurtherLanguages
            ;;
        *)
            ;;
    esac
}


#
# check if command exists
#
function checkCommand {
    command -v $1 >/dev/null 2>&1
    COMMAND_IS_INSTALLED=$?
    if [[ ${COMMAND_IS_INSTALLED} -ne 0 ]]; then
        echo -e "${RED}$1 is not installed. Aborting.${NC}"
        exit 1
    fi
}

#
# check general dev commands
#
function checkDevCommands {
    checkCommand "npm";
    checkCommand "bower";
    checkCommand "gulp"
}

#
# select desired packages
#
function setPackages {
    bootstrap-sass-official
    echo -e "${ORANGE}Choose your css framework:${NC}"
    echo -e "  1)  Bootstrap 3"
    echo -e "  2)  Bootstrap 4"
    echo -e "  3)  MaterializeCSS"
    echo -e ""
    read -r -p "Enter the number of the desired option: " SELECTEDDATABASE
    case ${response} in
        1)
            bower install bootstrap-sass-official --save
            FRAMEWORK=bootstrap3
            ;;
        2)
            bower install bootstrap#4.0 --force-latest --save
            FRAMEWORK=bootstrap4
            ;;
        3)
            bower install materialize --save
            FRAMEWORK=materializecss
            ;;
        *)
            ;;
    esac
    bower install fontawesome --save
}

#
# perform setup of different requirements such as npm and bower
#
function installRequirements {
    checkDevCommands
    cd web
    npm install
    bower install
    cd ..
}

#
# initial project setup
#
function firstInstall {
    read -r -p $'\e[31mAre you sure to run inital setup?\e[0m [y/N] ' response
    case ${response} in
        [yY][eE][sS]|[yY])
            echo -e "###############################################################################"
            echo -e "${GREEN}Welcome to the typo3-8.x-composer installer!${NC}"
            echo -e "Please follow the instructions and provide the requested information when asked"
            echo -e "###############################################################################"
            file=web/typo3conf/FIRST_INSTALL
            if [ ! -e "${file}" ]; then
                touch ${file}
            fi
            echo -e "${ORANGE}### STEP 1 - Reinitialize repository ###${NC}"
            reInitRepository
            echo -e "${ORANGE}### STEP 2 - Set project settings ###${NC}"
            grabSettings
            echo -e "${ORANGE}### STEP 3 - Check if composer is installed ###${NC}"
            checkComposer
            echo -e "${ORANGE}### STEP 4 - Run 'composer install' ###${NC}"
            runComposer update
            echo -e "${ORANGE}### STEP 5 - Initial TYPO3 Setup ###${NC}"
            typo3Install
            echo -e "${ORANGE}### STEP 6 - Import default data ###${NC}"
            importDatabase
            echo -e "${ORANGE}### STEP 7 - Install languages ###${NC}"
            installLanguages
            echo -e "${ORANGE}### STEP 8 - Set packages ###${NC}"
            setPackages
            echo -e "${ORANGE}### STEP 9 - NPM/Bower install ###${NC}"
            installRequirements
            echo -e "${ORANGE}### STEP 10 - Generate ssh key for deployment ###${NC}"
            generateSshKey -v
            echo -e "${GREEN}### DONE - TYPO3 initial setup finished ###${NC}"
            rm ingredients/status.sh
            echo "INSTALLED=true" >> ingredients/status.sh
            ;;
        *)
            ;;
    esac
}

#
# deploy function
#
function publish {
    exit 1
}

#
# update unit tests
#
function updateUnitTests {
    exit 1
}

#
# run unit tests
#
function runUnitTests {
    exit 1
}

#
# generate SSH key for the user which runs php
#
function generateSshKey {
    if [[ $1 = "-v" ]]; then
        read -r -p $'\e[33mSet the home directory of user running php (without trailing slash):\e[0m ' SSHKEYUSERHOME
    else
        echo -e "###############################################################################"
        echo -e "${GREEN}ssh-key generator!${NC}"
        echo -e "###############################################################################"
        SSHKEYUSERHOME=$1
    fi
    php ingredients/php/ssh-keygen.php -- ${SSHKEYUSERHOME}
    echo -e "${GREEN}Use this key for deployment (set it in GitHub, GitLab, ...):${NC}"
    cat ${SSHKEYUSERHOME}/id_rsa.pub
    echo -e ""
}

#
# main task switch
#
function main {
    checkDockermode
    case "$1" in
        "firstinstall")
            firstInstall
            ;;
        "unittests")
            case "$2" in
                "update")
                    updateUnitTests
                    ;;
                "run")
                    runUnitTests
                    ;;
                *)
                    echo -e "USAGE: ./boil.sh unittests [update|run]"
            esac
            ;;
        "publish")
            case "$2" in
                "staging")
                    publish $2
                    ;;
                "production")
                    publish $2
                    ;;
                *)
                    echo -e "USAGE: ./boil.sh publish [staging|production]"
            esac
            ;;
        "keygen")
            if [ -z "$2" ]; then
                echo -e "USAGE: ./boil.sh keygen [\$homedir]"
            else
                generateSshKey $2
            fi
            ;;
        *)
            echo -e "USAGE: ./boil.sh firstinstall"
            echo -e "OR:    ./boil.sh unittests [update|run]"
            echo -e "OR:    ./boil.sh publish [staging|production]"
            echo -e "OR:    ./boil.sh keygen [\$homedir]"
            ;;
    esac
}

#
# run script
#
# $1 = task (firstinstall, unittests, publish, keygen)
# $2 = environment // subtask (empty (if firstinstall), staging, production, update, run, homedir)
main $1 $2;
