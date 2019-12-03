#!/usr/bin/env bash
#
# pwapk
# a simple pwa converter
# https://github.com/saymoncoppi/pwapk
#
# Author:     Saymon Coppi <saymoncoppi@gmail.com>
# Maintainer: Saymon Coppi <saymoncoppi@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Text styles 
bold=$(tput bold)
normal=$(tput sgr0)

# Base URLs
GIT_URL="https://github.com/saymoncoppi/pwapk"

# Base LANGUAGE
CURRENT_LANGUAGE=$(locale | grep LANGUAGE | sed -e "s/^LANGUAGE=//" | sed -r 's/(.{2}).*/\1/')

# Base DIR
set -e
DIR=`realpath --no-symlinks $PWD`

# Check connection
function check_connection {
    wget --quiet --tries=1 --spider "${GIT_URL}"
    if [ $? -eq 0 ]; then
        echo "Checking connection..."
    else
        echo "Ops! No Internet Connection!"
        exit
    fi
}

show_menu(){
    normal=`echo "\033[m"`
    menu=`echo "\033[m"` #old color `echo "\033[36m"`
    number=`echo "\033[33m"` #yellow
    bgred=`echo "\033[41m"`
    fgred=`echo "\033[31m"`
    #begin convert
    clear
    echo -e "\n\n"
    printf "                                            ${bold}mpwapk${normal}\n"
    echo "--------------------------------------------------"
    echo "A simple app builder that converts PWA to APK only" 
    echo "using the Terminal without any Android Studio :)"
    echo 
    printf "${menu}     ${number} 1)${menu} Convert PWA to APK ${normal}\n"
    printf "${menu}     ${number} 2)${menu} Check requirements ${normal}\n"
    printf "${menu}     ${number} 3)${menu} Demo ${normal}\n"
    printf "${normal}\n--------------------------------------------------\n"
    printf "Please enter a menu option, ${number}h${normal} for help or ${fgred}x to exit. ${normal}"
    read opt
}

show_back_menu(){
    normal=`echo "\033[m"`
    fgred=`echo "\033[31m"`
    echo 
    printf "Press ${number}b${normal} to back to main menu or ${fgred}x to exit. ${normal}"
    read opt
}

option_picked(){
    msgcolor=`echo "\033[01;31m"` # bold red
    normal=`echo "\033[00;00m"` # normal white
    message=${@:-"${normal}Error: No message passed"}
    printf "${msgcolor}${message}${normal}\n"
}


show_menu
while [ $opt != '' ]
    do
    if [ $opt = '' ]; then
      exit;
    else
      case $opt in
        1) clear;
            echo
            option_picked "                                Convert PWA to APK";
            echo "--------------------------------------------------"echo $CURRENT_LANGUAGE
            # Step - Validate the URL
            
            # Is Debug mode?
            if [ -z $selected_demo ]; then
                echo -ne "Inform your PWA url: "; read PWA_URL_TYPED
            else
                PWA_URL_TYPED=$selected_demo
            fi
            
            # URL PATTERN TEST
            PWA_URL=$(echo $PWA_URL_TYPED | awk '{print tolower($0)}')
            
            # Remove last Char "/" if contains
            PWA_URL_LAST_CHAR=$(echo $PWA_URL | awk '{print substr($0,length,1)}')
            if [ $PWA_URL_LAST_CHAR == "/" ]; then
                PWA_URL=$(echo $PWA_URL | sed 's/\/$//g')
            fi
            # Regex for https
            URL_REGEX='^(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]\.[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]$'

            echo
            printf "${bold}Checking $PWA_URL:${normal}\n"
            if [[ $PWA_URL =~ $URL_REGEX ]]; then
                echo "Url is valid"
            else
                echo "Url is NOT valid"
            fi
            
            # LINK CONENCTION TEST
            wget --quiet --tries=1 --spider "$PWA_URL"
            if [ $? -eq 0 ]; then
                echo "Url is reacheable"
            else
                echo "Url is unreacheable"
                exit
            fi
            
            # PWA analisys
            # https://developers.google.com/web/progressive-web-apps/checklist
            echo
            printf "${bold}PWA analisys${normal}\n"
            printf "${number}Manifest${normal}\n"
            #MANIFEST_FROM_URL=$(wget -nv -q -O- $PWA_URL | grep -o 'rel="[^"]*' | sed -e 's/^manifest//g' | grep -o 'manifest.json')
            MANIFEST_FROM_URL=$(wget -nv -q -O- $PWA_URL | grep -o 'manifest.json')

            #if [[ $MANIFEST_FROM_URL == *"manifest.json"* ]]; then
            if [ -z $MANIFEST_FROM_URL ]; then
                echo "sem manifest"
            else
                echo "Oba manifesto"
                #echo $MANIFEST_FROM_URL
            fi




            echo -e "123.xml\n456.xml\nabc.xml\n..."
            #echo -e "Web Manifest properly attached\ndisplay property utilized\nLists icons for add to home screen\nContains name property\nContains short_name property\nDesignates a start_url\n"
            printf "${number}Service Worker${normal}\n"
            echo -e "123.xml\n456.xml\nabc.xml\n..."
            #echo -e "Has a Service Worker\nService Worker has cache handlers\nService Worker has the correct scope\nService Worker has a pushManager registration\n"
            printf "${number}Security${normal}\n"
            echo -e "123.xml\n456.xml\nabc.xml\n..."
            #echo -e "Uses HTTPS URL\nValid SSL certificate is use\nNo mixed content on page\n"
            printf "            ...this session isnt ready${fgred} :( ${normal}goahead\n"
            

            # Step - Create Certificate
            function fill_certificate {
                echo
                printf "${bold}Certificate informations:${normal}\n"
                echo -ne "Keyname: "; read KEYTOOL_KEYNAME
                echo -ne "Alias: "; read KEYTOOL_ALIAS
                # RECOMMENDED SETHINGS
                KEYTOOL_KEYALG="RSA" 
                KEYTOOL_KEYSIZE=2048
                KEYTOOL_VALIDITY=1000
                
                echo -ne "Type a password: "; read -s KEYTOOL_PASSWORD_TYPED; echo
                echo -ne "Retype the password: "; read -s KEYTOOL_PASSWORD_RETYPED; echo
                # INSERT TEST FOR PASSWORDS
                if [ $KEYTOOL_PASSWORD_TYPED != $KEYTOOL_PASSWORD_RETYPED ];then
                    echo
                    echo "Ops! You typed different passwords. Try again."
                    echo -ne "Type a password: "; read -s KEYTOOL_PASSWORD_TYPED; echo
                    echo -ne "Retype the password: "; read -s KEYTOOL_PASSWORD_RETYPED; echo
                    # there's an issue here. maybe a function solve.
                fi
                echo -ne "Your Name: "; read KEYTOOL_USERNAME
                echo -ne "Business Unit: "; read KEYTOOL_BUSINESS_UNIT
                echo -ne "Company: "; read KEYTOOL_COMPANY
                echo -ne "City: "; read KEYTOOL_CITY
                echo -ne "State: "; read KEYTOOL_STATE
                echo -ne "Country "; read KEYTOOL_COUNTRY
            }

            # call Fill Certificate function
            fill_certificate

            function write_certificate {
            read -r -p "Confirm your certificate data? [yes/no] " response
            case "$response" in
                [yY][eE][sS]|[yY]) 
                    echo
                    printf "${number}Writing certificate files${normal}\n"
                    echo "$KEYTOOL_KEYNAME.keystore"

                    if [ $CURRENT_LANGUAGE == "pt" ]; then # a tiny fix to locale "yes" or "sim" 
                        KEYTOOL_IS_CURRECT="sim" 
                    else
                        KEYTOOL_IS_CURRECT="yes"
                    fi

                    printf "$KEYTOOL_PASSWORD_TYPED\n$KEYTOOL_PASSWORD_RETYPED\n$KEYTOOL_USERNAME\n$KEYTOOL_BUSINESS_UNIT\n$KEYTOOL_COMPANY\n$KEYTOOL_CITY\n$KEYTOOL_STATE\n$KEYTOOL_COUNTRY\n$KEYTOOL_IS_CURRECT" | keytool -genkey -keystore $KEYTOOL_KEYNAME.keystore -alias $KEYTOOL_ALIAS -keyalg $KEYTOOL_KEYALG -keysize $KEYTOOL_KEYSIZE -validity $KEYTOOL_VALIDITY 2>/dev/null
                    
                    echo "$KEYTOOL_ALIAS.info" 
                    printf "$KEYTOOL_KEYNAME\n$KEYTOOL_ALIAS\n$KEYTOOL_PASSWORD_TYPED\n$KEYTOOL_PASSWORD_RETYPED\n$KEYTOOL_USERNAME\n$KEYTOOL_BUSINESS_UNIT\n$KEYTOOL_COMPANY\n$KEYTOOL_CITY\n$KEYTOOL_STATE\n$KEYTOOL_COUNTRY\n$KEYTOOL_IS_CURRECT" > $KEYTOOL_ALIAS.info
                    ;;
                [nN][oO])
                    echo "Let's go again..."
                    response=""
                    fill_certificate
                    ;;
                    *)
                    echo "Ops! Could you fill properly? use yes/no"
                    response=""
                    write_certificate
                    ;;
            esac
            }
            # call Write certificate Function
            write_certificate
        
            # Verify the keystore file
            # echo "verify $KEYTOOL_KEYNAME.keystore"; keytool -list -v -keystore $KEYTOOL_KEYNAME.keystore


            # Step - Get the resources
            set -eu
            echo
            printf "${bold}Getting Resource Files:${normal}\n"            
            sh -c 'wget -q --show-progress https://github.com/saymoncoppi/pwapk/raw/master/resources.tar.xz -O pwapk_resources.tar.xz'
            tar -xJf pwapk_resources.tar.xz

            # rewrite Android Manifest
            echo
            printf "${bold}Inflating new APK files:${normal}\n"   
            echo -e "123.xml\n456.xml\nabc.xml\n..."

            # Repack apk
            echo
            printf "${bold}Packing $KEYTOOL_ALIAS.apk${normal}\n"
            apktool b resources $KEYTOOL_ALIAS.apk 2>/dev/null

            # COPY APK FILE TO CURRENT folder
            cp $DIR/resources/dist/*.apk $DIR   
            mv *.apk unligned.apk
            rm -rf resources pwapk_resources.tar.xz
            sleep 1
            echo "Success!"

            echo
            printf "${bold}Aligning $KEYTOOL_ALIAS.apk${normal}\n"
            # zipalign (https://developer.android.com/studio/command-line/zipalign)
            zipalign -p 4 unligned.apk $KEYTOOL_ALIAS.apk
            rm -rf unligned.apk
            sleep 1
            echo "Success!"
            
            # zipalign verify
            # zipalign -c 4 $KEYTOOL_ALIAS.apk
            echo
            printf "${bold}Signing $KEYTOOL_ALIAS.apk${normal}\n"
            echo "Signing using $KEYTOOL_KEYNAME.keystore"; sleep 1
            # apksigner (https://developer.android.com/studio/publish/app-signing.html#signing-manually)
            printf "$KEYTOOL_PASSWORD_TYPED\n" | apksigner sign --ks $KEYTOOL_KEYNAME.keystore $KEYTOOL_ALIAS.apk >> /dev/null
            # apksigner verify
            #apksigner verify $KEYTOOL_ALIAS.apk
            echo
            printf "${fgred}${bold}Congratulation Hero!${normal}\n"
            echo -e "Check your new file $DIR/$KEYTOOL_ALIAS.apk"
            echo -e "\n\n"

            # Show menu
            show_back_menu;

        ;;
        2) clear;
            echo
            option_picked "                                Check requirements";
            echo "--------------------------------------------------"
            
            # ISSUE : Sometimes fail when the first time, maybe something related to sudo pass.IDK
            
            ROOT_UID=0
            # check command avalibility
            function has_command() {
                command -v $1 > /dev/null
            }
            if [ "$UID" -eq "$ROOT_UID" ]; then
                echo -e "\nChecking pwapk required packages...\n"
                #echo "Checking dependencies...java"
                #=======================================================
                JAVA_VER=$(java -version 2>&1 >/dev/null | egrep "\S+\s+version" | awk '{print $3}' | tr -d '"')
                JAVA_SHORTV=$(echo $JAVA_VER | cut -d "." -f1-2)
                
                if [ -n "$JAVA_VER" ]; then
                    echo "Java $JAVA_SHORTV ...ok"
                    JAVA_INSTALLED="YES"
                else
                    echo "java ...fail"
                    JAVA_INSTALLED="NO"
                    REQUIRES_INSTALL_PROCESS=$((REQUIRES_INSTALL_PROCESS+1))
                fi
                
                #echo "Checking dependencies...apktool"
                #=======================================================
                if [ -f "/usr/local/bin/apktool" ]; then
                    echo "apktool wrapper script ...ok"
                    APKTOOL_SCRIPT_INSTALLED="YES"
                else
                    echo "apktool wrapper script ...fail"
                    APKTOOL_SCRIPT_INSTALLED="NO"
                    REQUIRES_INSTALL_PROCESS=$((REQUIRES_INSTALL_PROCESS+1))
                fi
                
                #echo "Checking dependencies...apktool.jar"
                #=======================================================
                if [ -f "/usr/local/bin/apktool.jar" ]; then
                    echo "apktool.jar ...ok"
                    APKTOOL_JAR_INSTALLED="YES"
                else
                    echo "apktool.jar ...fail"
                    APKTOOL_JAR_INSTALLED="NO"
                    REQUIRES_INSTALL_PROCESS=$((REQUIRES_INSTALL_PROCESS+1))
                fi
                
                #echo "Checking dependencies...zipalign"
                #=======================================================
                if [ $(dpkg-query -W -f='${Status}' zipalign 2>/dev/null | grep -c "ok installed") -eq 0 ];then
                    echo "zipalign ...fail"
                    ZIPALIGN_INSTALLED="NO"
                    REQUIRES_INSTALL_PROCESS=$((REQUIRES_INSTALL_PROCESS+1))
                else
                    echo "zipalign ...ok"
                    ZIPALIGN_INSTALLED="YES"
                fi
                
                #echo "Checking dependencies...apksigner"
                #=======================================================
                if [ $(dpkg-query -W -f='${Status}' apksigner 2>/dev/null | grep -c "ok installed") -eq 0 ];then
                    echo "apksigner ...fail"
                    APKSIGNER_INSTALLED="NO"
                    REQUIRES_INSTALL_PROCESS=$((REQUIRES_INSTALL_PROCESS+1))
                else
                    echo "apksigner ...ok"
                    APKSIGNER_INSTALLED="YES"
                fi
                echo -e "\nNothing to do!\n"
                
                #echo $REQUIRES_INSTALL_PROCESS
                if [ -n "$REQUIRES_INSTALL_PROCESS" ]; then
                    # check_connection()
                    check_connection
                    
                    #echo "Installing...java"
                    #=======================================================
                    if [ $JAVA_INSTALLED == "NO" ];then
                        echo "Installing java"
                        apt-get install -qq -o=Dpkg::Progress-Fancy=1 --no-install-recommends -y --yes default-jre
                        # Other suggestions "default-jre-headless java-common openjdk-8-jre-headless"
                    fi
                    
                    #echo "Installing...apktool"
                    #=======================================================
                    if [ $APKTOOL_SCRIPT_INSTALLED == "NO" ];then
                        echo "Installing apktool wrapper script"
                        sh -c 'wget -q --show-progress https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool -O /usr/local/bin/apktool'
                        chmod +x /usr/local/bin/apktool
                        echo ""
                    fi
                    
                    #echo "Installing...apktool.jar"
                    #=======================================================
                    if [ $APKTOOL_JAR_INSTALLED == "NO" ];then
                        echo "Installing apktool.jar"
                        export apktool_version=$(wget -nv -q -O- https://bitbucket.org/iBotPeaches/apktool/downloads/ | grep -o 'apktool_*.*.*.jar' | sort | tail -n1 | sed -n -e 's/^.*apktool_//p' | sed 's/.jar//g')
                        sh -c 'wget -q --show-progress https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_$apktool_version.jar -O /usr/local/bin/apktool.jar'
                        chmod +r /usr/local/bin/apktool.jar
                        echo ""
                    fi
                    
                    #echo "Installing...zipalign"
                    #=======================================================
                    if [ $ZIPALIGN_INSTALLED == "NO" ];then
                        echo "Installing zipalign"
                        apt-get install -qq -o=Dpkg::Progress-Fancy=1 --no-install-recommends -y --yes zipalign
                        echo ""
                    fi
                    
                    #echo "Installing...apksigner"
                    #=======================================================
                    if [ $APKSIGNER_INSTALLED == "NO" ];then
                        echo "Installing apksigner"
                        apt-get install -qq -o=Dpkg::Progress-Fancy=1 --no-install-recommends -y --yes apksigner
                        echo ""
                    fi
                fi
            else
                # Asking for sudo password
                [ "$UID" -eq 0 ] || exec sudo "$0" "$@"
            fi
            # Show menu
            show_back_menu;
        ;;
        3) clear;
            echo 
            option_picked "                                              Demo";
            echo "--------------------------------------------------"
            DEMO_LIST_PWA_ROCKS_SITE=$(wget -nv -q -O- https://raw.githubusercontent.com/pwarocks/pwa.rocks/master/src/index.html | grep -o 'href="[^"]*' | sed -e 's/^http:\/\///g' -e 's/^https:\/\///g')
            # https://www.linuxjournal.com/content/bash-arrays
            for demo_url in $DEMO_LIST_PWA_ROCKS_SITE; do       
                if [[ $demo_url == *"https://"* ]]; then
                    if [[ $demo_url != *"https://github.com/pwarocks/pwa.rocks"* ]]; then
                    arr[$COUNTER]="$(echo $demo_url | sed 's/href="//g')"
                    COUNTER=$[$COUNTER +1]
                    fi
                fi
            done
            selected_demo_url=$(( ( RANDOM % $COUNTER )  + 7 ))
            selected_demo=${arr[$selected_demo_url]}

            printf "${number}Selected demo Url:     ${normal}${arr[$selected_demo_url]}\n"
            sleep 3
            echo
            printf "${bold}Check other Apps from pwa.rocks:${normal}\n"
            for i in ${!arr[*]}; do
                echo -e "${arr[$i]}"
            done
            read
            # Show Menu again
            show_menu <<<"1"
        ;;
        h) clear;
            echo 
            option_picked "                                             Help";
            echo "--------------------------------------------------"
            echo -e "\n\nCheck here pls\n${GIT_URL}\n\n"

            # Show Menu again
            show_back_menu;
        ;;
        b)clear;show_menu;
        ;;
        x)exit;
        ;;
        *)clear;
            option_picked "Pick an option from the menu";
            show_menu;
        ;;
      esac
    fi
done