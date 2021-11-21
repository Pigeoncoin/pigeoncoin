#!/bin/sh
compileSource()
{
    echo "Depends built, preping build."

    bash autogen.sh
    clear

    echo "autogen complete"

    ./configure --prefix=$(pwd)/depends/x86_64-w64-mingw32

    echo "configure complete"

    make $*

    echo "compile complete"

}

depends()
{
    echo "depends not built, building now"
    cd depends/
    make HOST=x86_64-w64-mingw32 -j4 $*
    cd ..
}
if [ -d $PWD"/depends/x86_64-w64-mingw32/" ]
then
compileSource
else
depends
compileSource
fi
