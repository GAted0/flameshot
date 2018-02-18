#!/bin/bash
project_dir=$(pwd)

brew update > /dev/null
brew install qt
brew install dbus
QTDIR="/usr/local/opt/qt"
PATH="$QTDIR/bin:$PATH"
LDFLAGS=-L$QTDIR/lib
CPPFLAGS=-I$QTDIR/include

# Build your app
cd ${project_dir}
mkdir build
cd build
qmake -version
qmake CONFIG-=debug CONFIG+=release CONFIG+=packaging ../flameshot.pro
make -j$(nproc)

git clone https://github.com/aurelien-rainone/macdeployqtfix.git
pwd && ls

# Package DMG from build/app/Flamshot.app directory
mkdir app
cd app/

sed -i -e 's/org.yourcompany.Flameshot/org.dharkael.Flameshot/g' Flameshot.app/Contents/Info.plist
$QTDIR/bin/macdeployqt Flameshot.app
python ${project_dir}/build/macdeployqtfix/macdeployqtfix.py Flameshot.app/Contents/MacOS/Flameshot $QTDIR

cd ${project_dir}/build
mkdir -p distrib/Flameshot
cd distrib/Flameshot
mv ${project_dir}/build/app/Flameshot.app ./
cp "${project_dir}/LICENSE" "LICENSE"
cp "${project_dir}/README.md" "README.md"
echo "${VERSION}" > version
echo "${TRAVIS_COMMIT}" >> version

ln -s /Applications ./Applications

cd ..
hdiutil create -srcfolder ./Flameshot -format UDBZ ./Flameshot.dmg
mv Flameshot.dmg Flameshot_X64_${VERSION}.dmg
cd ..

exit 0