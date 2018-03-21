#!/bin/sh

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

PIGEOND=${PIGEOND:-$SRCDIR/pigeond}
PIGEONCLI=${PIGEONCLI:-$SRCDIR/pigeon-cli}
PIGEONTX=${PIGEONTX:-$SRCDIR/pigeon-tx}
PIGEONQT=${PIGEONQT:-$SRCDIR/qt/pigeon-qt}

[ ! -x $PIGEOND ] && echo "$PIGEOND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
PGNVER=($($PIGEONCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for pigeond if --version-string is not set,
# but has different outcomes for pigeon-qt and pigeon-cli.
echo "[COPYRIGHT]" > footer.h2m
$PIGEOND --version | sed -n '1!p' >> footer.h2m

for cmd in $PIGEOND $PIGEONCLI $PIGEONTX $PIGEONQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${PGNVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${PGNVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
