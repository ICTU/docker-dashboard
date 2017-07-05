#!/usr/bin/env sh

VERSION=$1
echo Releasing BigBoat version $VERSION
npm version -m "Bumped version to %s for release." $VERSION
git push
git push --tags
