// Copyright (c)  The Bitcoin Core developers
// Copyright (c) 2017 The Raven Core developers
// Copyright (c) 2018 The Rito Core developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.
#pragma once

#include <cstdint>
#include <streams/hash/hash_interface.h>

namespace sha3 {

using BitSequence = hash::BitSequence;
using DataLength = hash::DataLength;

struct sha3_interface : hash::hash_interface {};

} // namespace sha3
