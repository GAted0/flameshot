#!/bin/bash
project_dir=$(pwd)

brew update > /dev/null
brew install qt
QTDIR="/usr/local/opt/qt"
PATH="$QTDIR/bin:$PATH"
LDFLAGS=-L$QTDIR/lib
CPPFLAGS=-I$QTDIR/include

# Build your app
cd ${project_dir}
mkdir build
cd build
qmake -v
qmake CONFIG-=debug CONFIG+=release CONFIG+=packaging ../flameshot.pro
make -j2

git clone https://github.com/aurelien-rainone/macdeployqtfix.git

# Package DMG from build/src/Flamshot.app directory
cd src/

sed -i -e 's/org.yourcompany.Flameshot/org.dharkael.Flameshot/g' Flameshot.app/Contents/Info.plist
$QTDIR/bin/macdeployqt Flameshot.app
python ../macdeployqtfix/macdeployqtfix.py Flameshot.app/Contents/MacOS/Flameshot $QTDIR

# Fix Helpers/QtWebEngineProcess.app
cd Flameshot.app/Contents/Frameworks/QtWebEngineCore.framework/Versions/5/Helpers
$QTDIR/bin/macdeployqt QtWebEngineProcess.app
python ${project_dir}/build/macdeployqtfix/macdeployqtfix.py QtWebEngineProcess.app/Contents/MacOS/QtWebEngineProcess $QTDIR

cd ${project_dir}/build
mkdir -p distrib/Flameshot
cd distrib/Flameshot
mv ../../src/Flameshot.app ./
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