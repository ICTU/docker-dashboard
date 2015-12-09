#!/bin/bash

git config --global push.default current

echo ""
echo "Create and push a new tag for the Dashboard"

git tag -ln | sort -V

echo "The list above shows all current tags, please enter the new tag: [ENTER]"
printf "tag: "
read tag

lastversion=$(printf "`git tag -ln`\n$tag" | sort -V | awk '/./{line=$0} END{print line}')

if [[ "$lastversion" != "$tag" ]]; then
  echo "Aborting; tag $tag is not successive to $lastversion"
  exit 1
fi

echo "@version = '$tag'" > ./client/version.coffee
git add ./client/version.coffee
git commit -m "bumping version to $tag"

git tag $tag
git push
git push --tag

echo "Tag $tag pushed, done!"
