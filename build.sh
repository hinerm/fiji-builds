#!/bin/sh
set -e

if [ "$CI" = "true" ]
then
	# Running on CI. Use a cache folder off the home directory.
	CACHE_DIR="$HOME/cache"
else
	# Running locally. Use a cache folder in the current directory.
	CACHE_DIR=cache
fi

FIJI_HOME="$CACHE_DIR/Fiji.app"

echo
echo "== Checking whether anything has changed =="

# Fetch the latest timestamps, if not already done.
if [ ! -f new-dates.txt ]
then
	./fetch-datestamps.sh > new-dates.txt
fi

# Compare against previous timestamps, if available.
changes=false
if [ ! -e dates.txt ]
then
	echo "No dates.txt to compare with. Assuming changes exist."
	mkdir -p "$CACHE_DIR"
	changes=true
elif [ "$(git diff --no-index dates.txt new-dates.txt)" != "" ]
then
	echo
	git diff --no-index dates.txt new-dates.txt || true # redo for color highlighting
	echo
	echo "New distros will be generated."
	changes=true
fi

if [ "$changes" = false ]; then
	echo "Nothing has changed. No distros will be generated."
	exit 0
fi

# Initialize the Fiji.app installation if needed.
if [ ! -d "$FIJI_HOME" ]
then
  echo
  echo "== Building Fiji installation =="
  ./bootstrap-fiji.sh "$FIJI_HOME" || exit 1
fi

# Update the Fiji.app installation.
echo
echo "== Updating the Fiji installation =="
./update-fiji.sh "$FIJI_HOME" || exit 2

# Bundle up the installation for each platform.
echo
echo "== Generating archives =="
./generate-archives.sh "$FIJI_HOME" || exit 3

# Upload the application bundles.
echo
echo "== Transferring artifacts =="
./upload-archives.sh || exit 4

# Finally, since everything worked OK, save the new dates.
mv -f new-dates.txt dates.txt
