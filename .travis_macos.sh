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
qmake -version
qmake CONFIG-=debug CONFIG+=release CONFIG+=packaging ../flameshot.pro
make -j$(nproc)

git clone https://github.com/aurelien-rainone/macdeployqtfix.git
pwd && ls

ls /Users/travis/build/ZetaoYang/flameshot

# Package DMG from build/flamshot.app directory
sed -i -e 's/org.yourcompany.Flameshot/org.dharkael.Flameshot/g' ./flameshot.app/Contents/Info.plist
$QTDIR/bin/macdeployqt flameshot.app
python ${project_dir}/build/macdeployqtfix/macdeployqtfix.py flameshot.app/Contents/MacOS/flameshot $QTDIR

cd ${project_dir}/build
mkdir -p distrib/Flameshot
cd distrib/Flameshot
mv ${project_dir}/build/flameshot.app ${project_dir}/build/distrib/Flameshot/
cp "${project_dir}/LICENSE" "LICENSE"
cp "${project_dir}/README.md" "README.md"
echo ${VERSION} > version
echo "${TRAVIS_COMMIT}" >> version

ln -s /Applications ./Applications

cd ..
hdiutil create -srcfolder ./Flameshot -format UDBZ ./flameshot.dmg
mv flameshot.dmg flameshot_X64_$VERSION.dmg
curl --upload-file ./flameshot_X64_$VERSION.dmg "https://transfer.sh/Flameshot_X64_$VERSION.dmg"
cd ..

exit 0