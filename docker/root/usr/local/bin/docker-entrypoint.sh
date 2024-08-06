#!/usr/bin/env sh

cmd="${1}"
weboneInstallPath="$(dirname "$(readlink -f "$(which webone)")")"
weboneUserConfigDir="$HOME/.config/webone"


if [ ! -d "$weboneUserConfigDir" ]; then
    mkdir -p "$weboneUserConfigDir"
fi

i=1
while IFS= read -r -d '' file; do
    ln -s "$file" "$weboneUserConfigDir/$(printf '%03d' $i)_$(basename "$file")"
    i=$((i + 1))
done < <(find "$weboneInstallPath" -type f -maxdepth 1 -name '*.conf' ! -name 'webone.conf' -print0)


ifaceName="$(ip route | awk '/default/ { print $5 }')"
defaultHostName="$(ip -o -4 addr show "$ifaceName" | awk '{print $4}' | awk -F'/' '{ print $1 }')"

dockerConfig="$weboneUserConfigDir/$(printf '%03d' $i)_docker.conf"
echo -e "[Server]\nDefaultHostName=$defaultHostName" >> "$dockerConfig"
echo -e "[Include:$weboneInstallPath/webone.conf.d/*.conf]" >> "$dockerConfig"


# Run command with webone if the first argument contains a "-" or is not a system command.
# The last part inside the "{}" is a workaround for the following bug in ash/dash:
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=874264
if [ -z "$cmd" ] || [ "${cmd#-}" != "$cmd" ] || [ -z "$(command -v "$cmd")" ] || { [ -f "$cmd" ] && ! [ -x "$cmd" ]; }
then
    set -- webone "$@"
fi

exec "$@"
