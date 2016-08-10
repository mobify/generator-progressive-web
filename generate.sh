#!/bin/bash
set -o pipefail

MYDIR=$(pwd)
SCAFFOLD_VERSION_OR_BRANCH="develop"
SCAFFOLD_URL="https://github.com/mobify/progressive-web-scaffold/archive/$SCAFFOLD_VERSION_OR_BRANCH.zip"

# Prompt license and do not proceed unless user has accepted
read -p"--> We have a license you must read and agree to. Read license? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]] ; then
    exit 1
fi

curl -s -O -L https://raw.githubusercontent.com/mobify/progressive-web-scaffold/develop/LICENSE
trap 'rm -f LICENSE' EXIT
less LICENSE

read -p"--> I have read, understand, and accept the terms and conditions stated in the license above. (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]] ; then
    exit 1
fi

# Get the project slug from the user
read -p'--> What is your project slug? (should match slug on Mobify Cloud) ' project_slug

# Get the project url from the user
read -p'--> What is the project url? ' project_url

# Prepare new project directory
project_dir="$MYDIR/$project_slug"
echo "Setting up new project in $project_dir"
mkdir "$project_dir"
cd "$project_dir" || exit

printf "\nDownloading Progressive Web project scaffold\n"
WORKING_DIR=$(mktemp -d /tmp/progressive-web-scaffold.XXXXX)
trap 'rm -rf "$WORKING_DIR"' EXIT
curl --progress-bar -L "$SCAFFOLD_URL" -o "$WORKING_DIR/progressive-web-scaffold-$SCAFFOLD_VERSION_OR_BRANCH.zip"
cd "$WORKING_DIR" || exit
unzip -q "$WORKING_DIR/progressive-web-scaffold-$SCAFFOLD_VERSION_OR_BRANCH.zip"
cp -R $WORKING_DIR/progressive-web-scaffold-$SCAFFOLD_VERSION_OR_BRANCH/. "$project_dir"
cd "$project_dir" || exit

# Remove files that are specific to the scaffold but not to projects
rm CONTRIBUTING.md

# Replace "progressive-web-scaffold" with $project_slug inside of files.
egrep -lR "progressive-web-scaffold" . | tr '\n' '\0' | xargs -0 -n1 sed -i '' "s/progressive-web-scaffold/$project_slug/g" 2>/dev/null

# Set site url
egrep -lR "siteUrl" . | tr '\n' '\0' | xargs -0 -n1 sed -i '' "s/\"siteUrl\": \"\"/\"siteUrl\": \"$project_url\"/g" 2>/dev/null

printf "\nInstalling project dependencies\n"
npm install

# Make first commit
git init
git add .
git commit -am 'Your first Progressive Web commit - Congrats! 🌟 👍🏽'

echo "Your project is now ready to go."
echo "Follow the steps in README.md to run the app."
echo "You must still set up a remote for Git: https://help.github.com/articles/adding-a-remote/"
