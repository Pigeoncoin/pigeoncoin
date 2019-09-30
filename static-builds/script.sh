#!/usr/bin/env bash
# Set DISTNAME, BRANCH and MAKEOPTS to the desired settings
DISTNAME=pigeoncoin-0.17.0
MAKEOPTS="-j4"
BRANCH=0.17
BUILD_DR=/mnt/development/workspace
clear
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo"
   exit 1
fi
if [[ $PWD != $BUILD_DR ]]; then
   echo "This script must be run from $BUILD_DR/"
   exit 1
fi
if [ ! -f $BUILD_DR/MacOSX10.11.sdk.tar.gz ]
then
	echo "Before executing script.sh transfer MacOSX10.11.sdk.tar.gz to $BUILD_DR/"
	exit 1
fi
export PATH_orig=$PATH

echo @@@
echo @@@"Installing Dependecies"
echo @@@

apt install -y curl g++-aarch64-linux-gnu g++-7-aarch64-linux-gnu gcc-7-aarch64-linux-gnu binutils-aarch64-linux-gnu g++-arm-linux-gnueabihf g++-7-arm-linux-gnueabihf gcc-7-arm-linux-gnueabihf binutils-arm-linux-gnueabihf g++-7-multilib gcc-7-multilib binutils-gold git pkg-config autoconf libtool automake bsdmainutils ca-certificates python g++ mingw-w64 g++-mingw-w64 nsis zip rename librsvg2-bin libtiff-tools cmake imagemagick libcap-dev libz-dev libbz2-dev python-dev python-setuptools fonts-tuffy
cd $BUILD_DR/

# Removes any existing builds and starts clean WARNING
rm $BUILD_DR/sign $BUILD_DR/release

cd $BUILD_DR/pigeoncoin

git fetch
git pull
cd $BUILD_DR/pigeoncoin
git checkout -b $BRANCH origin/$BRANCH


echo @@@
echo @@@"Building linux 64 binaries"
echo @@@

mkdir -p $BUILD_DR/release
cd $BUILD_DR/pigeoncoin/depends
make HOST=x86_64-linux-gnu $MAKEOPTS
cd $BUILD_DR/pigeoncoin
export PATH=$PWD/depends/x86_64-linux-gnu/native/bin:$PATH
./autogen.sh
CONFIG_SITE=$PWD/depends/x86_64-linux-gnu/share/config.site ./configure --prefix=/ --disable-ccache --disable-maintainer-mode --disable-dependency-tracking --enable-glibc-back-compat --enable-reduce-exports --disable-bench --disable-gui-tests CFLAGS="-O2 -g" CXXFLAGS="-O2 -g" LDFLAGS="-static-libstdc++"
make $MAKEOPTS 
make -C src check-security
make -C src check-symbols 
mkdir $BUILD_DR/linux64
make install DESTDIR=$BUILD_DR/linux64/$DISTNAME
cd $BUILD_DR/linux64
find . -name "lib*.la" -delete
find . -name "lib*.a" -delete
rm -rf $DISTNAME/lib/pkgconfig
find ${DISTNAME}/bin -type f -executable -exec ../pigeoncoin/contrib/devtools/split-debug.sh {} {} {}.dbg \;
find ${DISTNAME}/lib -type f -exec ../pigeoncoin/contrib/devtools/split-debug.sh {} {} {}.dbg \;
find $DISTNAME/ -not -name "*.dbg" | sort | tar --no-recursion --mode='u+rw,go+r-w,a+X' --owner=0 --group=0 -c -T - | gzip -9n > $BUILD_DR/release/$DISTNAME-x86_64-linux-gnu.tar.gz
cd $BUILD_DR/pigeoncoin
rm -rf $BUILD_DR/linux64
make clean
export PATH=$PATH_orig


echo @@@
echo @@@"Building general sourcecode"
echo @@@

cd $BUILD_DR/pigeoncoin
export PATH=$PWD/depends/x86_64-linux-gnu/native/bin:$PATH
./autogen.sh
CONFIG_SITE=$PWD/depends/x86_64-linux-gnu/share/config.site ./configure --prefix=/
make dist
SOURCEDIST=`echo pigeoncoin-*.tar.gz`
mkdir -p $BUILD_DR/pigeoncoin/temp
cd $BUILD_DR/pigeoncoin/temp
tar xf ../$SOURCEDIST
find pigeoncoin-* | sort | tar --no-recursion --mode='u+rw,go+r-w,a+X' --owner=0 --group=0 -c -T - | gzip -9n > ../$SOURCEDIST
cd $BUILD_DR/pigeoncoin
mv $SOURCEDIST $BUILD_DR/release
rm -rf temp
make clean
export PATH=$PATH_orig


echo @@@
echo @@@"Building linux 32 binaries"
echo @@@

cd $BUILD_DR/
mkdir -p $BUILD_DR/wrapped/extra_includes/i686-pc-linux-gnu
ln -s /usr/include/x86_64-linux-gnu/asm $BUILD_DR/wrapped/extra_includes/i686-pc-linux-gnu/asm

for prog in gcc g++; do
rm -f $BUILD_DR/wrapped/${prog}
cat << EOF > $BUILD_DR/wrapped/${prog}
#!/usr/bin/env bash
REAL="`which -a ${prog} | grep -v $PWD/wrapped/${prog} | head -1`"
for var in "\$@"
do
  if [ "\$var" = "-m32" ]; then
    export C_INCLUDE_PATH="$PWD/wrapped/extra_includes/i686-pc-linux-gnu"
    export CPLUS_INCLUDE_PATH="$PWD/wrapped/extra_includes/i686-pc-linux-gnu"
    break
  fi
done
\$REAL \$@
EOF
chmod +x $BUILD_DR/wrapped/${prog}
done

export PATH=$PWD/wrapped:$PATH
export HOST_ID_SALT="$PWD/wrapped/extra_includes/i386-linux-gnu"
cd $BUILD_DR/pigeoncoin/depends
make HOST=i686-pc-linux-gnu $MAKEOPTS
unset HOST_ID_SALT
cd $BUILD_DR/pigeoncoin
export PATH=$PWD/depends/i686-pc-linux-gnu/native/bin:$PATH
./autogen.sh
CONFIG_SITE=$PWD/depends/i686-pc-linux-gnu/share/config.site ./configure --prefix=/ --disable-ccache --disable-maintainer-mode --disable-dependency-tracking --enable-glibc-back-compat --enable-reduce-exports --disable-bench --disable-gui-tests CFLAGS="-O2 -g" CXXFLAGS="-O2 -g" LDFLAGS="-static-libstdc++"
make $MAKEOPTS 
make -C src check-security
make -C src check-symbols 
mkdir -p $BUILD_DR/linux32
make install DESTDIR=$BUILD_DR/linux32/$DISTNAME
cd $BUILD_DR/linux32
find . -name "lib*.la" -delete
find . -name "lib*.a" -delete
rm -rf $DISTNAME/lib/pkgconfig
find ${DISTNAME}/bin -type f -executable -exec ../pigeoncoin/contrib/devtools/split-debug.sh {} {} {}.dbg \;
find ${DISTNAME}/lib -type f -exec ../pigeoncoin/contrib/devtools/split-debug.sh {} {} {}.dbg \;
find $DISTNAME/ -not -name "*.dbg" | sort | tar --no-recursion --mode='u+rw,go+r-w,a+X' --owner=0 --group=0 -c -T - | gzip -9n > $BUILD_DR/release/$DISTNAME-i686-pc-linux-gnu.tar.gz
cd $BUILD_DR/pigeoncoin
rm -rf $BUILD_DR/linux32
rm -rf $BUILD_DR/wrapped
make clean
export PATH=$PATH_orig


echo @@@
echo @@@ "Building linux ARM binaries"
echo @@@

cd $BUILD_DR/pigeoncoin/depends
make HOST=arm-linux-gnueabihf $MAKEOPTS
cd $BUILD_DR/pigeoncoin
export PATH=$PWD/depends/arm-linux-gnueabihf/native/bin:$PATH
./autogen.sh
CONFIG_SITE=$PWD/depends/arm-linux-gnueabihf/share/config.site ./configure --prefix=/ --disable-ccache --disable-maintainer-mode --disable-dependency-tracking --enable-glibc-back-compat --enable-reduce-exports --disable-bench --disable-gui-tests CFLAGS="-O2 -g" CXXFLAGS="-O2 -g" LDFLAGS="-static-libstdc++"
make $MAKEOPTS 
make -C src check-security
mkdir -p $BUILD_DR/linuxARM
make install DESTDIR=$BUILD_DR/linuxARM/$DISTNAME
cd $BUILD_DR/linuxARM
find . -name "lib*.la" -delete
find . -name "lib*.a" -delete
rm -rf $DISTNAME/lib/pkgconfig
find ${DISTNAME}/bin -type f -executable -exec ../pigeoncoin/contrib/devtools/split-debug.sh {} {} {}.dbg \;
find ${DISTNAME}/lib -type f -exec ../pigeoncoin/contrib/devtools/split-debug.sh {} {} {}.dbg \;
find $DISTNAME/ -not -name "*.dbg" | sort | tar --no-recursion --mode='u+rw,go+r-w,a+X' --owner=0 --group=0 -c -T - | gzip -9n > $BUILD_DR/release/$DISTNAME-arm-linux-gnueabihf.tar.gz
cd $BUILD_DR/pigeoncoin
rm -rf $BUILD_DR/linuxARM
make clean
export PATH=$PATH_orig


echo @@@
echo @@@ "Building linux aarch64 binaries"
echo @@@

cd $BUILD_DR/pigeoncoin/depends
make HOST=aarch64-linux-gnu $MAKEOPTS
cd $BUILD_DR/pigeoncoin
export PATH=$PWD/depends/aarch64-linux-gnu/native/bin:$PATH
./autogen.sh
CONFIG_SITE=$PWD/depends/aarch64-linux-gnu/share/config.site ./configure --prefix=/ --disable-ccache --disable-maintainer-mode --disable-dependency-tracking --enable-glibc-back-compat --enable-reduce-exports --disable-bench --disable-gui-tests CFLAGS="-O2 -g" CXXFLAGS="-O2 -g" LDFLAGS="-static-libstdc++"
make $MAKEOPTS 
make -C src check-security
mkdir -p $BUILD_DR/linuxaarch64
make install DESTDIR=$BUILD_DR/linuxaarch64/$DISTNAME
cd $BUILD_DR/linuxaarch64
find . -name "lib*.la" -delete
find . -name "lib*.a" -delete
rm -rf $DISTNAME/lib/pkgconfig
find ${DISTNAME}/bin -type f -executable -exec ../pigeoncoin/contrib/devtools/split-debug.sh {} {} {}.dbg \;
find ${DISTNAME}/lib -type f -exec ../pigeoncoin/contrib/devtools/split-debug.sh {} {} {}.dbg \;
find $DISTNAME/ -not -name "*.dbg" | sort | tar --no-recursion --mode='u+rw,go+r-w,a+X' --owner=0 --group=0 -c -T - | gzip -9n > $BUILD_DR/release/$DISTNAME-aarch64-linux-gnu.tar.gz
cd $BUILD_DR/pigeoncoin
rm -rf $BUILD_DR/linuxaarch64
make clean
export PATH=$PATH_orig


echo @@@
echo @@@ "Building windows 64 binaries"
echo @@@

update-alternatives --set x86_64-w64-mingw32-g++ /usr/bin/x86_64-w64-mingw32-g++-posix 
mkdir -p $BUILD_DR/release/unsigned/
mkdir -p $BUILD_DR/sign/win64
PATH=$(echo "$PATH" | sed -e 's/:\/mnt.*//g') # strip out problematic Windows %PATH% imported var
cd $BUILD_DR/pigeoncoin/depends
make HOST=x86_64-w64-mingw32 $MAKEOPTS
cd $BUILD_DR/pigeoncoin
export PATH=$PWD/depends/x86_64-w64-mingw32/native/bin:$PATH
./autogen.sh
CONFIG_SITE=$PWD/depends/x86_64-w64-mingw32/share/config.site ./configure --prefix=/ --disable-ccache --disable-maintainer-mode --disable-dependency-tracking --enable-reduce-exports --disable-bench --disable-gui-tests CFLAGS="-O2 -g" CXXFLAGS="-O2 -g"
make $MAKEOPTS 
make -C src check-security
make deploy
rename 's/-setup\.exe$/-setup-unsigned.exe/' *-setup.exe
cp -f pigeoncoin-*setup*.exe $BUILD_DR/release/unsigned/
mkdir -p $BUILD_DR/win64
make install DESTDIR=$BUILD_DR/win64/$DISTNAME
cd $BUILD_DR/win64
mv $BUILD_DR/win64/$DISTNAME/bin/*.dll $BUILD_DR/win64/$DISTNAME/lib/
find . -name "lib*.la" -delete
find . -name "lib*.a" -delete
rm -rf $DISTNAME/lib/pkgconfig
find $DISTNAME/bin -type f -executable -exec x86_64-w64-mingw32-objcopy --only-keep-debug {} {}.dbg \; -exec x86_64-w64-mingw32-strip -s {} \; -exec x86_64-w64-mingw32-objcopy --add-gnu-debuglink={}.dbg {} \;
find ./$DISTNAME -not -name "*.dbg"  -type f | sort | zip -X@ ./$DISTNAME-x86_64-w64-mingw32.zip
mv ./$DISTNAME-x86_64-*.zip $BUILD_DR/release/$DISTNAME-win64.zip
cd $BUILD_DR/
rm -rf win64
cp -rf pigeoncoin/contrib/windeploy $BUILD_DR/sign/win64
cd $BUILD_DR/sign/win64/windeploy
mkdir -p unsigned
mv $BUILD_DR/pigeoncoin/pigeoncoin-*setup-unsigned.exe unsigned/
find . | sort | tar --no-recursion --mode='u+rw,go+r-w,a+X' --owner=0 --group=0 -c -T - | gzip -9n > $BUILD_DR/sign/$DISTNAME-win64-unsigned.tar.gz
cd $BUILD_DR/sign
rm -rf win64
cd $BUILD_DR/pigeoncoin
rm -rf release
make clean
export PATH=$PATH_orig


echo @@@
echo @@@ "Building windows 32 binaries"
echo @@@

update-alternatives --set i686-w64-mingw32-g++ /usr/bin/i686-w64-mingw32-g++-posix 
mkdir -p $BUILD_DR/sign/win32
PATH=$(echo "$PATH" | sed -e 's/:\/mnt.*//g') 
cd $BUILD_DR/pigeoncoin/depends
make HOST=i686-w64-mingw32 $MAKEOPTS
cd $BUILD_DR/pigeoncoin
export PATH=$PWD/depends/i686-w64-mingw32/native/bin:$PATH
./autogen.sh
CONFIG_SITE=$PWD/depends/i686-w64-mingw32/share/config.site ./configure --prefix=/ --disable-ccache --disable-maintainer-mode --disable-dependency-tracking --enable-reduce-exports --disable-bench --disable-gui-tests CFLAGS="-O2 -g" CXXFLAGS="-O2 -g"
make $MAKEOPTS 
make -C src check-security
make deploy
rename 's/-setup\.exe$/-setup-unsigned.exe/' *-setup.exe
cp -f pigeoncoin-*setup*.exe $BUILD_DR/release/unsigned/
mkdir -p $BUILD_DR/win32
make install DESTDIR=$BUILD_DR/win32/$DISTNAME
cd $BUILD_DR/win32
mv $BUILD_DR/win32/$DISTNAME/bin/*.dll $BUILD_DR/win32/$DISTNAME/lib/
find . -name "lib*.la" -delete
find . -name "lib*.a" -delete
rm -rf $DISTNAME/lib/pkgconfig
find $DISTNAME/bin -type f -executable -exec i686-w64-mingw32-objcopy --only-keep-debug {} {}.dbg \; -exec i686-w64-mingw32-strip -s {} \; -exec i686-w64-mingw32-objcopy --add-gnu-debuglink={}.dbg {} \;
find ./$DISTNAME -not -name "*.dbg"  -type f | sort | zip -X@ ./$DISTNAME-i686-w64-mingw32.zip
mv ./$DISTNAME-i686-w64-*.zip $BUILD_DR/release/$DISTNAME-win32.zip
cd $BUILD_DR/
rm -rf win32
cp -rf pigeoncoin/contrib/windeploy $BUILD_DR/sign/win32
cd $BUILD_DR/sign/win32/windeploy
mkdir -p unsigned
mv $BUILD_DR/pigeoncoin/pigeoncoin-*setup-unsigned.exe unsigned/
find . | sort | tar --no-recursion --mode='u+rw,go+r-w,a+X' --owner=0 --group=0 -c -T - | gzip -9n > $BUILD_DR/sign/$DISTNAME-win32-unsigned.tar.gz
cd $BUILD_DR/sign
rm -rf win32
cd $BUILD_DR/pigeoncoin
rm -rf release
make clean
export PATH=$PATH_orig


echo @@@
echo @@@ "Building OSX binaries"
echo @@@

mkdir -p $BUILD_DR/pigeoncoin/depends/SDKs
cp $BUILD_DR/MacOSX10.11.sdk.tar.gz $BUILD_DR/pigeoncoin/depends/SDKs/MacOSX10.11.sdk.tar.gz
cd $BUILD_DR/pigeoncoin/depends/SDKs && tar -xf MacOSX10.11.sdk.tar.gz 
rm -rf MacOSX10.11.sdk.tar.gz 
cd $BUILD_DR/pigeoncoin/depends
make $MAKEOPTS HOST="x86_64-apple-darwin14"
cd $BUILD_DR/pigeoncoin
./autogen.sh
CONFIG_SITE=$PWD/depends/x86_64-apple-darwin14/share/config.site ./configure --prefix=/ --disable-ccache --disable-maintainer-mode --disable-dependency-tracking --enable-reduce-exports --disable-bench --disable-gui-tests GENISOIMAGE=$PWD/depends/x86_64-apple-darwin14/native/bin/genisoimage
make $MAKEOPTS 
mkdir -p $BUILD_DR/OSX
export PATH=$PWD/depends/x86_64-apple-darwin14/native/bin:$PATH
make install-strip DESTDIR=$BUILD_DR/OSX/$DISTNAME
make osx_volname
make deploydir
mkdir -p unsigned-app-$DISTNAME
cp osx_volname unsigned-app-$DISTNAME/
cp contrib/macdeploy/detached-sig-apply.sh unsigned-app-$DISTNAME
cp contrib/macdeploy/detached-sig-create.sh unsigned-app-$DISTNAME
cp $PWD/depends/x86_64-apple-darwin14/native/bin/dmg $PWD/depends/x86_64-apple-darwin14/native/bin/genisoimage unsigned-app-$DISTNAME
cp $PWD/depends/x86_64-apple-darwin14/native/bin/x86_64-apple-darwin14-codesign_allocate unsigned-app-$DISTNAME/codesign_allocate
cp $PWD/depends/x86_64-apple-darwin14/native/bin/x86_64-apple-darwin14-pagestuff unsigned-app-$DISTNAME/pagestuff
mv dist unsigned-app-$DISTNAME
cd unsigned-app-$DISTNAME
find . | sort | tar --no-recursion --mode='u+rw,go+r-w,a+X' --owner=0 --group=0 -c -T - | gzip -9n > $BUILD_DR/sign/$DISTNAME-osx-unsigned.tar.gz
cd $BUILD_DR/pigeoncoin
make deploy
$PWD/depends/x86_64-apple-darwin14/native/bin/dmg dmg "pigeoncoin-Core.dmg" $BUILD_DR/release/unsigned/$DISTNAME-osx-unsigned.dmg
rm -rf unsigned-app-$DISTNAME dist osx_volname dpi36.background.tiff dpi72.background.tiff
cd $BUILD_DR/OSX
find . -name "lib*.la" -delete
find . -name "lib*.a" -delete
rm -rf $DISTNAME/lib/pkgconfig
find $DISTNAME | sort | tar --no-recursion --mode='u+rw,go+r-w,a+X' --owner=0 --group=0 -c -T - | gzip -9n > $BUILD_DR/release/$DISTNAME-osx64.tar.gz
cd $BUILD_DR/pigeoncoin
rm -rf $BUILD_DR/OSX
make clean
export PATH=$PATH_orig
