// Copyright (c)  The Bitcoin Core developers
// Copyright (c) 2017 The Raven Core developers
// Copyright (c) 2018 The Rito Core developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.
#pragma once

#include <cstdint>

namespace hash {

using BitSequence = unsigned char;
using DataLength = unsigned long long;

struct hash_interface {
    virtual ~hash_interface() = default;

    virtual int Init(int hash_bitsize) = 0;
    virtual int Update(const BitSequence *data, DataLength data_bitsize) = 0;
    virtual int Final(BitSequence *hash) = 0;

    virtual int
    Hash(int hash_bitsize, const BitSequence *data, DataLength data_bitsize, BitSequence *hash) = 0;
};

} // namespace hash
