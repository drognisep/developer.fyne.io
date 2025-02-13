#!/bin/sh

ROOT="`go env GOPATH`/src/fyne.io/fyne/v2"
VERSION="v2.1"

cd "$(dirname "$0")"
cd ..
go get -u github.com/andydotxyz/godocdown/godocdown

# make non-version redirects

function redirect() {
  cat <<EOT >  "$1"
---
permalink: /api/$2
redirect_to: /api/$VERSION/$2
---
EOT
}


# generate API docs

DIRS=`find $ROOT -type d | grep -v .git | grep -v vendor | grep -v internal | grep -v testdata | grep -v cmd`
PREFIX="api/$VERSION"
mkdir $PREFIX 2>&1 > /dev/null

redirect "api/index.md" ""

godocdown -template="_gen/api.md" -outputDir "$PREFIX/" $ROOT 2>&1 | grep -v "Could not find package"
for DIR in $DIRS; do
  PKG=`echo $DIR | cut -c$((${#ROOT}+2))-`

  if [[ ! -z "$PKG" ]]; then
    mkdir -p `dirname "api/$PKG"`
    redirect "api/$PKG.md" "$PKG/"
  fi
  mkdir -p "$PREFIX/$PKG"
 
  godocdown -template="_gen/api.md" -outputDir "$PREFIX/$PKG/" $DIR 2>&1 | grep -v "Could not find package"
done
