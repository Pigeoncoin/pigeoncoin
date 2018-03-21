// Copyright (c) 2011-2014 The Bitcoin Core developers
// Copyright (c) 2017 The Pigeon Core developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#ifndef PIGEON_QT_PIGEONADDRESSVALIDATOR_H
#define PIGEON_QT_PIGEONADDRESSVALIDATOR_H

#include <QValidator>

/** Base58 entry widget validator, checks for valid characters and
 * removes some whitespace.
 */
class PigeonAddressEntryValidator : public QValidator
{
    Q_OBJECT

public:
    explicit PigeonAddressEntryValidator(QObject *parent);

    State validate(QString &input, int &pos) const;
};

/** Pigeon address widget validator, checks for a valid pigeon address.
 */
class PigeonAddressCheckValidator : public QValidator
{
    Q_OBJECT

public:
    explicit PigeonAddressCheckValidator(QObject *parent);

    State validate(QString &input, int &pos) const;
};

#endif // PIGEON_QT_PIGEONADDRESSVALIDATOR_H
