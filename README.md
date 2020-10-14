# almod
Script that helps configure Alacritty terminal.
AME
    almod - Modifes your alacritty's config.

SYNOPSIS
    almod OPTION

DESCRIPTION
   This is a shell script that uses sed to modify your alacritty's config file.
   It is strongly recommended to use the -b option before you use any other option or make a backup manually of your config file.

    -i, --opacity+
        Increase opcity.

    -d, --opacity-
        Decrease opacity.

    --font+
        Increase the font size.

    --font-
        Decrease font's size.

    -d, --download-themes
        Download all the themes from the "https://github.com/eendroroy/alacritty-theme/tree/master/themes" repo inside ".local/share/alacritty_themes".

    -t, --random-theme
        Set a random color scheme.

    -c, --choose-theme
        Use dmenu to pick a theme located in your ".local/share/alacritty_themes".

    -f, --change-font
        Change Alacritty's font using dmenu.

    -b, --backup
        Creates backup (by adding a trailing "~" to your current config file).

    -r, --restore
       Restore backup file.
       
    -h, --help
       Display help message.

   DEPENDENCIES
       Dependencies: grep, sed, mkdir, echo, cut, less (for this message), dmenu (for -c and -f options).
