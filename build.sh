#!/bin/sh
compileSource()
{
    echo "Depends built, preping build."

    bash autogen.sh
    clear

    echo "autogen complete"

    ./configure --prefix=$(pwd)/depends/x86_64-pc-linux-gnu

    echo "configure complete"

    make

    echo "compile complete"

}

depends()
{
    echo "depends not built, building now"
    cd depends/
    make
    cd ..
}

if [ -d $PWD"/depends/x86_64-pc-linux-gnu/" ]
then
compileSource
else
depends
compileSource
fi