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

# Get the project name from the user
read -p'--> What is the name of your project? ' project_name

# $project_name must not contain special characters.
project_name=$(echo "$project_name" | tr -dc '[:alnum:]\n\r' | tr '[:upper:]' '[:lower:]' | tr -d ' ')

read -p"--> Continue with the project name '$project_name'? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]] ; then
    exit 1
fi

# Prepare new project directory
project_dir="$MYDIR/$project_name"
echo "Setting up new project in $project_dir"
mkdir "$project_dir"
cd "$project_dir" || exit

printf "\nDownloading Progressive Web project scaffold\n"
WORKING_DIR=$(mktemp -d /tmp/progressive-web-scaffold.XXXXX)
trap 'rm -rf "$WORKING_DIR"' EXIT
curl --progress-bar -L "$SCAFFOLD_URL" -o "$WORKING_DIR/progressive-web-scaffold-$SCAFFOLD_VERSION_OR_BRANCH.zip"
cd "$WORKING_DIR" || exit
unzip -q "$WORKING_DIR/progressive-web-scaffold-$SCAFFOLD_VERSION_OR_BRANCH.zip" -d "$product_dir"
cp -R "$WORKING_DIR/progressive-web-scaffold-$SCAFFOLD_VERSION_OR_BRANCH/" "$project_dir"
cd "$project_dir" || exit

# Remove files that are specific to the scaffold but not to projects
rm CONTRIBUTING.md

# Replace "progressive-web-scaffold" with $project_name inside of files.
egrep -lR "progressive-web-scaffold" . | tr '\n' '\0' | xargs -0 -n1 sed -i '' "s/progressive-web-scaffold/$project_name/g" 2>/dev/null

printf "\nInstalling project dependencies\n"
npm install

# Make first commit
git init
git add .
git commit -am 'Your first Progressive Web commit - Congrats! 🌟 👍🏽'

echo "Your project is now ready to go."
echo "Follow the steps in README.md to run the app."
echo "You must still set up a remote for Git: https://help.github.com/articles/adding-a-remote/"
