#!/usr/bin/env bash

set -euo pipefail

force=false

POSITIONAL=()
while [[ $# -gt 0 ]]; do
  case "$1" in
  -f | --force)
    force=true
    shift # shift once since flags have no values
    ;;
  --display-name)
    display_name=$2
    shift 2 # shift twice to bypass switch and its value
    ;;
  *) # unknown flag/switch
    POSITIONAL+=("$1")
    shift
    ;;
  esac
done

set -- "${POSITIONAL[@]}" # restore positional params

default_profile_name='Profile 1'
if [ -z "${1+x}" ]; then
  echo "The Google Chrome profile name was not provided. Falling back to '$default_profile_name'."
  echo "You can provide the profile name as argument."
  echo
fi
profile_name=${1-$default_profile_name}

if [ -z "${display_name+x}" ]; then
  echo "The display name was not provided. Falling back to '$profile_name'."
  echo "You can set the display name in app launcher with '--display-name <display-name>'."
  echo
  display_name=${profile_name}
fi

default_chrome_desktop=/usr/share/applications/google-chrome.desktop
if [ ! -f "$default_chrome_desktop" ]; then
  echo "Could not find the file $default_chrome_desktop. Are you sure that Google Chrome is installed?"
  exit 1
fi

profile_folder="$HOME/.config/google-chrome/$profile_name"
if [ ! -d "$profile_folder" ]; then
  echo "This profile doesn't seems to exist. It will be created automatically by Google Chrome on first start."
  echo
fi

safe_profile_name=${profile_name,,}           # Make lowercase
safe_profile_name=${safe_profile_name//[ ]/-} # Replace spaces with dashes
binary_name="chrome-$safe_profile_name"
binary_folder="$HOME/.local/bin"
binary="$binary_folder/$binary_name"
shortcut="$HOME/.local/share/applications/$binary_name.desktop"

echo
echo "We will:"
echo "CREATE: $binary"
echo "CREATE: $shortcut"
echo "USE display name: $display_name"
echo "USE profile name: $profile_name"
echo
if [ "$force" = false ]; then
  read -p "Do you confirm? Run with '--force' to prevent this confirmation. (Yy)" -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

## Create the binary
mkdir -p "$binary_folder"
printf '%s\n' '#!/usr/bin/env bash' \
  'google-chrome --profile-directory="'"$profile_name"'" "$@" & disown' \
  >"$binary"
chmod +x "$binary"

## Create the shortcut
cp -f $default_chrome_desktop "$shortcut"
sed -i "s/Name=Google Chrome/Name=Google Chrome ($display_name)/g" "$shortcut"
chrome_binary="/usr/bin/google-chrome-stable"
sed -i "s/Exec=${chrome_binary//\//\\/}/Exec=${binary//\//\\/}/g" "$shortcut" # The //\//\\/ is used to escape forward slashes

echo
echo "All done."
echo "If $binary_folder is in your PATH variable, you'll be able"
echo "to start this Chrome instance from the command line with:"
echo "  $ $binary_name"
echo "Run the following command to revert the changes made (uninstall):"
echo "  $ rm -f $binary $shortcut"
echo
