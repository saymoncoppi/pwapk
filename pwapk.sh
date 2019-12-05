#!/usr/bin/env bash
#
# pwapk
# A simple app builder that converts PWA to APK only 
# using the Terminal without any Android Studio :)
#
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

# Random password
RANDOM_PASSWORD_SIZE=10
RANDOM_PASSWORD=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c $RANDOM_PASSWORD_SIZE)

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

# quick mode
    if [ -z $1 ]; then
        show_menu
    else
        QUICKMODE="1"
        PWA_URL_TYPED=$1
        show_menu <<<"1"
    fi

while [ $opt != '' ]
    do
    if [ $opt = '' ]; then
      exit;
    else
      case $opt in
        1) clear;
            echo
            option_picked "                                Convert PWA to APK";
            echo "--------------------------------------------------"
            # Step - Validate the URL
            
            # Is Debug mode?
            if [ -z $PWA_URL_TYPED ]; then
                if [ -z $selected_demo ]; then
                    echo -ne "Inform your PWA url: "; read PWA_URL_TYPED
                else
                    PWA_URL_TYPED=$selected_demo
                fi
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
            #wget --quiet --tries=1 --spider "$PWA_URL" # better with the command below
            LINK_TEST=$(HEAD $PWA_URL | grep '200\ OK' | wc -l)
            if [ $LINK_TEST = 1 ]; then
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
            # manifest.jason Source


            # errors when url ok but application has error 404 or symbols into URL
            # https://domain.com/#!/home 
            # https://domain.com/#/login
            
            # Finding WPA manifest file
            # getting href content for manifest file
            SOURCE_MANIFEST=$(wget -nv -q -O- $PWA_URL | sed -n -e 's/^.*<link rel="manifest" href="//p' | cut -d '"' -f1)
            #echo $SOURCE_MANIFEST
            
            # test for "/"
            SOURCE_MANIFEST_FIRST_CHAR=$(echo "$SOURCE_MANIFEST" | sed -e "{ s/^\(.\).*/\1/ ; q }")
            
            if [ $SOURCE_MANIFEST_FIRST_CHAR = "/" ]; then
                #echo "ops is a /, better remove this / from the string"
                SOURCE_MANIFEST="${SOURCE_MANIFEST:1}"
                
            #else
            #    echo "ok is a letter, nothing to do"
            #    echo $SOURCE_MANIFEST_FIRST_CHAR
            fi

            # testa se é .json
            #if [[ $SOURCE_MANIFEST == *".json"* ]]; then
            #    echo ".json extension found"
            #else
            #    echo ".json extension not found"
            #fi
            echo "Manifest file:    $SOURCE_MANIFEST"
            MANIFEST_FROM_URL="$PWA_URL/$SOURCE_MANIFEST"

            # set manifest url
            #MANIFEST_FROM_URL="$PWA_URL/manifest.json"

            # Simple tst
            #wget --quiet --tries=1 --spider "${MANIFEST_FROM_URL}"
            #    if [ $? -eq 0 ]; then
            #        echo "manifest file found"
            #    else
            #        echo "manifest file not found"
            #    fi
                

            # Reading manifest.jason
                    MANIFEST_FROM_URL_CONTENT=$(wget -nv -q -O- $MANIFEST_FROM_URL)
                     #echo $MANIFEST_FROM_URL_CONTENT | python -m json.tool
                     
                    # Determining APP name
                    if [ -z $PWAPK_APP_NAME ]; then                    # Found error here when "name": " hasnt space like "name":"
                        PWAPK_APP_NAME=$(echo $MANIFEST_FROM_URL_CONTENT | sed -n -e 's/^.*"name": "//p' | cut -d '"' -f1 | sed 's/ //g')
                    fi
                    
                    # Found error here when "name": " hasnt space like "name":"
                    if [ $(echo -n $PWAPK_APP_NAME | wc -c) -eq 0 ]; then                    
                        PWAPK_APP_NAME=$(echo $MANIFEST_FROM_URL_CONTENT | sed -n -e 's/^.*"name":"//p' | cut -d '"' -f1 | sed 's/ //g')
                    fi
                    
                    echo "PWA Name:         $PWAPK_APP_NAME"



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
                KEYTOOL_KEYNAME="$PWAPK_APP_NAME"
                #echo -ne "Keyname: $KEYTOOL_KEYNAME"
                #echo -ne "Alias: "; read KEYTOOL_ALIAS
                KEYTOOL_ALIAS="${PWAPK_APP_NAME}-alias"
                # RECOMMENDED SETHINGS
                KEYTOOL_KEYALG="RSA" 
                KEYTOOL_KEYSIZE=2048
                KEYTOOL_VALIDITY=1000
    
                # Quick Mode for Names
                if [ -z $QUICKMODE ]; then
                    echo -ne "Your Name: "; read KEYTOOL_USERNAME
                else
                    echo "Your Name: $(getent passwd $USER | cut -d ':' -f 5 | sed -e 's/,//g')"
                fi

                # Quick Mode for password
                if [ -z $QUICKMODE ]; then
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
                else
                    #echo "Use the autogenerated key? $RANDOM_PASSWORD"
                    KEYTOOL_PASSWORD_TYPED=$RANDOM_PASSWORD
                    KEYTOOL_PASSWORD_RETYPED=$RANDOM_PASSWORD
                fi

                echo -ne "Business Unit: "; read KEYTOOL_BUSINESS_UNIT
                echo -ne "Company: "; read KEYTOOL_COMPANY


                # Quick Mode for geolocation
                if [ -z $QUICKMODE ]; then
                    echo -ne "City: "; read KEYTOOL_CITY
                    echo -ne "State: "; read KEYTOOL_STATE
                    echo -ne "Country "; read KEYTOOL_COUNTRY
                else
                    # https://www.howtogeek.com/405088/how-to-get-your-systems-geographic-location-from-a-bash-script/
                    # Grab this server's public IP address
                    PUBLIC_IP=`curl -s https://ipinfo.io/ip`

                    # Call the geolocation API and capture the output
                    curl -s https://ipvigilante.com/${PUBLIC_IP} | \
                            jq '.data.latitude, .data.longitude, .data.city_name, .data.subdivision_1_name, .data.country_name' | \
                            while read -r LATITUDE; do
                                read -r LONGITUDE
                                read -r CITY
                                read -r STATE
                                read -r COUNTRY
                                KEYTOOL_CITY=$(echo ${CITY} | sed 's/"//g')
                                KEYTOOL_STATE=$(echo ${STATE} | sed 's/"//g')
                                KEYTOOL_COUNTRY=$(echo ${COUNTRY} | sed 's/"//g')
                                echo "City: $KEYTOOL_CITY"
                                echo "State: $KEYTOOL_STATE"
                                echo "Country: $KEYTOOL_COUNTRY"
                            done
                fi
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
                    
                    echo "$PWAPK_APP_NAME.info" 
                    printf "$KEYTOOL_KEYNAME\n$KEYTOOL_ALIAS\n$KEYTOOL_PASSWORD_TYPED\n$KEYTOOL_PASSWORD_RETYPED\n$KEYTOOL_USERNAME\n$KEYTOOL_BUSINESS_UNIT\n$KEYTOOL_COMPANY\n$KEYTOOL_CITY\n$KEYTOOL_STATE\n$KEYTOOL_COUNTRY\n$KEYTOOL_IS_CURRECT" > $PWAPK_APP_NAME.info
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
            # TODO extract during download       
            sh -c 'wget -q --show-progress https://github.com/saymoncoppi/pwapk/raw/master/resources.tar.xz -O pwapk_resources.tar.xz'
            tar -xJf pwapk_resources.tar.xz

            # Rewrite AndroidManifest.xml and BuildConfig.smali
            DATA_ANDROID_HOST="pwapk.URL"
            echo
            printf "${bold}Inflating new APK files:${normal}\n"   
            echo $DIR/resources/AndroidManifest.xml
            echo '<?xml version="1.0" encoding="utf-8" standalone="no"?><manifest xmlns:android="http://schemas.android.com/apk/res/android" android:compileSdkVersion="28" android:compileSdkVersionCodename="9" package="insert_DATA_ANDROID_HOST_here" platformBuildVersionCode="341" platformBuildVersionName="1">
    <application android:allowBackup="true" android:icon="@mipmap/ic_launcher" android:label="insert_PWAPK_APP_NAME_here" android:supportsRtl="true" android:theme="@style/Theme.TwaSplash">
        <meta-data android:name="asset_statements" android:value="[{ &quot;relation&quot;: [&quot;delegate_permission/common.handle_all_urls&quot;], &quot;target&quot;: {&quot;namespace&quot;: &quot;web&quot;, &quot;site&quot;: &quot;insert_PWA_URL_here&quot;}}]"/>
        <activity android:label="insert_PWAPK_APP_NAME_here" android:name="android.support.customtabs.trusted.LauncherActivity">
            <meta-data android:name="android.support.customtabs.trusted.DEFAULT_URL" android:value="insert_PWA_URL_here"/>
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
            <intent-filter>
                <action android:name="android.intent.action.VIEW"/>
                <category android:name="android.intent.category.DEFAULT"/>
                <category android:name="android.intent.category.BROWSABLE"/>
                <data android:host="insert_DATA_ANDROID_HOST_here" android:scheme="https"/>
            </intent-filter>
        </activity>
    </application>
</manifest>' | sed -e 's/insert_PWAPK_APP_NAME_here/'"$PWAPK_APP_NAME"'/g' -e 's|insert_PWA_URL_here|'"$PWA_URL"'|g' -e 's/insert_DATA_ANDROID_HOST_here/'"$DATA_ANDROID_HOST"'/g' > $DIR/resources/AndroidManifest.xml



            echo $DIR/resources/smali/com/placeholder/BuildConfig.smali
            echo '.class public final Lcom/placeholder/BuildConfig;
.super Ljava/lang/Object;
.source "BuildConfig.java"


# static fields
.field public static final APPLICATION_ID:Ljava/lang/String; = "insert_DATA_ANDROID_HOST_here"

.field public static final BUILD_TYPE:Ljava/lang/String; = "release"

.field public static final DEBUG:Z = false

.field public static final FLAVOR:Ljava/lang/String; = ""

.field public static final VERSION_CODE:I = 0x155

.field public static final VERSION_NAME:Ljava/lang/String; = "1"


# direct methods
.method public constructor <init>()V
    .locals 0

    .line 6
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method
' | sed -e 's/insert_DATA_ANDROID_HOST_here/'"$DATA_ANDROID_HOST"'/g' > $DIR/resources/smali/com/placeholder/BuildConfig.smali #$DIR/resources/smali/com/placeholder/BuildConfig.smali



            # Repack apk
            echo
            printf "${bold}Packing $PWAPK_APP_NAME.apk${normal}\n"
            apktool b resources $PWAPK_APP_NAME.apk 2>/dev/null

            # COPY APK FILE TO CURRENT folder
            cp $DIR/resources/dist/*.apk $DIR   
            mv *.apk unligned.apk
            rm -rf resources pwapk_resources.tar.xz
            sleep 1
            echo "Success!"

            echo
            printf "${bold}Aligning $PWAPK_APP_NAME.apk${normal}\n"
            # zipalign (https://developer.android.com/studio/command-line/zipalign)
            zipalign -p 4 unligned.apk $PWAPK_APP_NAME.apk
            rm -rf unligned.apk
            sleep 1
            echo "Success!"
            
            # zipalign verify
            # zipalign -c 4 $PWAPK_APP_NAME.apk
            echo
            printf "${bold}Signing $PWAPK_APP_NAME.apk${normal}\n"
            echo "Signing using $KEYTOOL_KEYNAME.keystore"; sleep 1
            # apksigner (https://developer.android.com/studio/publish/app-signing.html#signing-manually)
            printf "$KEYTOOL_PASSWORD_TYPED\n" | apksigner sign --ks $KEYTOOL_KEYNAME.keystore $PWAPK_APP_NAME.apk >> /dev/null
            # apksigner verify
            #apksigner verify $PWAPK_APP_NAME.apk
            echo
            printf "${fgred}${bold}Congratulation Hero!${normal}\n"
            echo -e "Check your new file $DIR/$PWAPK_APP_NAME.apk"
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
                
                # TODO !!!
                #echo "Checking dependencies...java"
                #=======================================================
                #PYTHON_VER=$(python --version 2>&1 >/dev/null | egrep "\S+\s+version" | awk '{print $3}' | tr -d '"')
                #PYTHON_SHORTV=$(echo $PYTHON_VER | cut -d "." -f1-2)
                


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
            
            # TODO!!! make a function to prevent empty results
            DEMO_LIST_PWA_ROCKS_SITE=$(wget -nv -q -O- https://raw.githubusercontent.com/pwarocks/pwa.rocks/master/src/index.html | grep -o 'href="[^"]*' | sed -e 's/^http:\/\///g' -e 's/^https:\/\///g')
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
            echo "Fetching data from pwa.rocks"
            sleep 1
            printf "${number}Selected demo Url:     ${normal}${arr[$selected_demo_url]}\n"
            echo
            
            # TODO: ask if the user wanna see more option
            # For now its ok to move forward
            # --------------------------------------------------------
            # printf "${bold}Check other Apps from pwa.rocks:${normal}\n"
            # for i in ${!arr[*]}; do
            #     echo -e "${arr[$i]}"
            # done
            #read -p "Press ENTER"
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