#!/bin/bash

# almod : change alacritty's config file
CONFIG="$HOME/.config/alacritty/alacritty.yml"
[ ! -f "$CONFIG" ] && "Couldn't find the config file" && exit 1
TPATH=".local/share/alacritty_themes"

# use this to customize dmenu or replace it with rofi
cmd () {
   dmenu -i -l 5 -fn "Noto Sans Mono Black" -sb "#16a085"
}

# set opacity value
set_value () {
  sed -Ei "s/^(background_opacity: )(.*)/\1$1/" "$CONFIG"
}

# get opacity value 
opacity () {
  ! grep -q '^background_opacity:' "$CONFIG" && echo "background_opacity: 0.8" >> "$CONFIG" && exit
  VALUE=$(grep '^background_opacity:' "$CONFIG" | sed 's/^background_opacity: //')
  SET="$VALUE $1"
case $SET in
  1.0" "+1) set_value 0.0;; 
  1.0" "-1) set_value 0.9;;
  0.9" "+1) set_value 1.0;;
  0.0" "-1) set_value 1.0;;
  *) set_value 0.$((${VALUE/0./}$1));;
esac
}

# download themes
get_themes () {
  [ ! -d $TPATH ] && mkdir -p $TPATH && echo "$TPATH sucessfully created."
  THEMES=$(curl -s https://github.com/eendroroy/alacritty-theme/tree/master/themes)
  DW_THEMES="$(grep -Eo '/eendroroy/alacritty-theme/blob/master/themes/[_[:alnum:]-]*.(yaml|yml)' <<< "$THEMES" |
  sed 's|^|https://raw.githubusercontent.com|; s|/blob||')"
  while read -r LINE; do
   echo "Downloading $(cut -d "/" -f8 <<< "$LINE")"
   wget -q "$LINE" -O "$TPATH/$(cut -d "/" -f8 <<< "$LINE")"
   sed -i '/^  *$/d; /^$/d; /^ *#/d' "$TPATH/$(cut -d "/" -f8 <<< "$LINE")"
  done <<< "$DW_THEMES"
}

# set random theme
set_theme () {
  [ -z "$1" ] && FILE="$(cat "$(find $TPATH -mindepth 1| shuf -n1)")" || FILE=$(cat "$@")
  ! grep -q '^colors:' "$CONFIG" && add_theme && exit
while IFS= read -r LINE; do
  VALUE="${LINE/:*/:}"
  while IFS= read -r VAL; do
    sed -i "s|^$VAL.*$|$LINE|" "$CONFIG"
  done <<< "$VALUE"
done <<< "$FILE"
}

# choose a theme
pick_theme () {
  set_theme "$(find $TPATH -type f | sed -E 's|^.*/(.*)\.y.*|\1|' | cmd | xargs -I '{}' find "$TPATH" -name '*{}*')"
}

# add theme for the first time
add_theme () {
  cat "$(find $TPATH -mindepth 1| shuf -n1)" >> "$CONFIG"
}

# change font
font () {
  IFS=$'\t'
  read -r FONT STYLE <<< "$(fc-list | sed -E 's|^.*\.[a-z]*: ||; s|:style=(.*)| (\1)|' |
  sort | uniq | cmd | sed 's/)//; s/(/	/')"
  [ -z "$FONT" ] && exit 1
  ! grep -q '^font:' "$CONFIG" && enable_font "$FONT"	"$STYLE" && exit
  LINE=$(grep -n '^    style:' .config/alacritty/alacritty.yml | cut -d ":" -f1 | head -1)
  sed -i "s/^    family:.*/    family: $FONT/" "$CONFIG"
  sed -i "${LINE}s/^    style:.*/    style: $STYLE/" "$CONFIG"
}

# enable font field
enable_font () {
  echo -e "font:\n  normal:\n    family: $1\n    style: $2\n  bold:\n    family: $1\n    style: Bold\n  italic:\n    family: $1\n    style: Ialic\n  bold_italic:\n    family: $1\n    style: Bold Italic\n" >> "$CONFIG"
}

# change font size
font_size () {
  ! grep -q '^  size:' "$CONFIG" && echo "  size: 11.0" >> "$CONFIG"
  read -r FONT_S FONT_W <<< "$(grep -o '  size: .*$'  "$CONFIG" | sed -E 's/^  size: ([0-9]*).([0-9])/\1 \2/')"
  SIZE=$((${FONT_S}$1))
  sed -i "s/^  size: .*$/  size: ${SIZE}\.${FONT_W}/" "$CONFIG"
}

size () {
  ! grep -q '^size:' "$CONFIG" && echo "size: 11.0" >> "$CONFIG" && exit
}

get_help () {
echo -e "NAME\n    almod - Modifes your alacritty's config.\n\nSYNOPSIS\n    almod OPTION\n
DESCRIPTION\n    This is a shell script that uses sed to modify your alacritty's config file.\n    It is strongly recommended to use the -b option before you use any other option or make a backup manually of your config file.\n
    -i, --opacity+
        Increase opcity.\n
    -d, --opacity-
        Decrease opacity.\n
    --font+
        Increase the font size.\n
    --font-
        Decrease font's size.\n
    -d, --download-themes
        Download all the themes from this repo insde \$TPATH:\n        https://github.com/eendroroy/alacritty-theme/tree/master/themes\n
    -t, --random-theme
        Set a random color scheme.\n
    -c, --choose-theme
        Use dmenu to pick a theme located in your \$TPATH.\n
    -f, --change-font
        Change Alacritty's font using dmenu.\n
    -b, --backup
        Creates backup (by adding a trailing \"~\" to your current config file).\n
    -r, --restore
       Restore backup file.\n
    -h, --help
       Display help message.\n
   DEPENDENCIES
       Dependencies: bash, grep, sed, mkdir, echo, cut, less (for this message), dmenu (for -c and -f options)." | less
}
case $1 in
  -i|--opacity+) opacity +1;;
  -d|--opacity-) opacity -1;;
  --font+) font_size +1;;
  --font-) font_size -1;;
  --download-themes) get_themes;;
  -t|--random-theme) set_theme;;
  -c|--choose-theme) pick_theme;;
  -b|--backup) cp "$CONFIG"{,~};;
  -r|--restore) cp "$CONFIG"{~,};;
  -f|--change-font) font;;
  -h|--help) get_help;;
esac
