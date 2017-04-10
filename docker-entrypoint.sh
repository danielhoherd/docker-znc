#! /usr/bin/env bash

# Options.
DATADIR="/znc-data"

mkdir -p "${DATADIR}/modules"

# Download some External Modules

# colloquy
if [ ! -f "${DATADIR}/modules/colloquy.so" ]; then
  wget -O "${DATADIR}/modules/colloquy.cpp" http://github.com/wired/colloquypush/raw/master/znc/colloquy.cpp
  wget https://patch-diff.githubusercontent.com/raw/wired/colloquypush/pull/46.patch
  patch -p2 "${DATADIR}/modules/colloquy.cpp" 46.patch
  rm -f 46.patch
fi

# push
if [ ! -f "${DATADIR}/modules/push.so" ]; then
  wget -O "${DATADIR}/modules/push.cpp" http://github.com/jreese/znc-push/raw/master/push.cpp
fi

# part_detach
if [ ! -f "${DATADIR}/modules/part_detach.py" ]; then
  wget -O "${DATADIR}/modules/part_detach.py" http://github.com/Nothing4You/znc-modules/raw/master/part_detach.py
fi

# Aka
if [ ! -f "${DATADIR}/modules/aka.py" ]; then
  wget -O "${DATADIR}/modules/aka.py" https://github.com/AwwCookies/ZNC-Modules/raw/master/Aka/aka.py
fi

# Clientaway
if [ ! -f "${DATADIR}/modules/clientaway.so" ]; then
  wget -O "${DATADIR}/modules/clientaway.cpp" https://github.com/kylef/znc-contrib/raw/master/clientaway.cpp
fi

# Build modules from source.
# Store current directory.
cwd="$(pwd)"

# Find module sources.
modules=$(find "${DATADIR}/modules" -name "*.cpp")

# Build modules.
for module in $modules; do
  cd "$(dirname "$module")"
  znc-buildmod "$module"
done

# Go back to original directory.
cd "$cwd"

# Create default config if it doesn't exist
if [ ! -f "${DATADIR}/configs/znc.conf" ]; then
  mkdir -p "${DATADIR}/configs"
  cp /znc.conf.default "${DATADIR}/configs/znc.conf"
fi

# Make sure $DATADIR is owned by znc user. This effects ownership of the
# mounted directory on the host machine too.
chown -R znc:znc "$DATADIR"

# Start ZNC.
exec sudo -u znc znc --foreground --datadir="$DATADIR" $@ | while read -r line ; do echo "$(date "+%F %T%z") $line" ; done ;
