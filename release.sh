#!/usr/bin/env sh

VERSION=$1
if node_modules/.bin/semver $VERSION; then
  echo Releasing BigBoat version $VERSION
  npm version -m "Bumped version to %s for release." $VERSION
  git push
  git push --tags
else
  echo $VERSION is not a valid semantic version.
fi
