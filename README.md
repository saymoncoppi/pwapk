# pwapk
A simple app builder that converts PWA to APK only using the Terminal without any Android Studio :)
<br />
<p align="center"><img src="https://raw.githubusercontent.com/saymoncoppi/pwapk/master/pwapk.png" height="50%" width="50%"></p>
<div align="right">Artwork by <a href="https://www.canva.com/">Canva</a></div>

## How it works
This script builds a brand new <a href="https://en.wikipedia.org/wiki/Android_application_package">Android Package (APK)</a> based on original <a href="https://en.wikipedia.org/wiki/Progressive_web_application">Progressive Web Application (PWA)</a>. \
It gets the base files from a new one project, create resourse files, keystores, pack, align, assign and deliver the APK for you, for free and using no Android Studio to do the Magic.

Seems a bit silly I know but I hope you enjoy. 

## Howto
Get the script file, make it executable
$ sudo chmod +x pwapk.sh \
Run
$ ./pwapk.sh

Or use the quickmode \
$ ./pwapk.sh https://www.YOUR-PWA-URL.com

## TODO
- Create curl version for each wget command. Useful to make MACOS compatible. \
- Fix main menu failover. \
- Insert reverse URL to $DATA_ANDROID_HOST. \
- Fix password retry verification. \
- Fix function to extract manifest.json location. Prevent errors when /# or /#! inside domains. \
- Fix demo function avoiding empty results. \
- Fix demo function to get data from new link (raw.git.../.../pwa-samples.txt). \
- Improve manifest searching function. \
- Extract icon information from manifest and apply to APK. \
- Create assetlinks.json to generated files. \
- Refacturing and clean code. \
- Quickmode auto-fills also Company and Business Unit fields. \

