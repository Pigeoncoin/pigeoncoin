// Copyright (c) 2009-2010 Satoshi Nakamoto
// Copyright (c) 2009-2015 The Bitcoin Core developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#include "primitives/block.h"
#include "algo/hashx21s.h"

#include "hash.h"
#include "streams.h"
#include "tinyformat.h"
#include "utilstrencodings.h"
#include "crypto/common.h"

static const uint32_t MAINNET_X21SACTIVATIONTIME = 1571097600;//10-15-2019 00:00:00GMT
static const uint32_t TESTNET_X21SACTIVATIONTIME = 1568851200;//09-19-2019 00:00:00GMT
static const uint32_t REGTEST_X21SACTIVATIONTIME = 1568951200;

BlockNetwork bNetwork = BlockNetwork();

BlockNetwork::BlockNetwork()
{
    fOnTestnet = false;
    fOnRegtest = false;
}

void BlockNetwork::SetNetwork(const std::string& net)
{
    if (net == "test") {
        fOnTestnet = true;
    } else if (net == "regtest") {
        fOnRegtest = true;
    }
}

uint256 CBlockHeader::GetHash() const
{
    uint32_t nTimeToUse = MAINNET_X21SACTIVATIONTIME;
	if (bNetwork.fOnTestnet) {
		nTimeToUse = TESTNET_X21SACTIVATIONTIME;
	} else if (bNetwork.fOnRegtest) {
		nTimeToUse = REGTEST_X21SACTIVATIONTIME;
	}
	if (nTime >= nTimeToUse) {
        // printf("Using x21s\n");
		return HashX21S(BEGIN(nVersion), END(nNonce), hashPrevBlock);
	}
            // printf("Using x16r\n");

    return HashX16R(BEGIN(nVersion), END(nNonce), hashPrevBlock);
}

std::string CBlock::ToString() const
{
    std::stringstream s;
    s << strprintf("CBlock(hash=%s, ver=0x%08x, hashPrevBlock=%s, hashMerkleRoot=%s, nTime=%u, nBits=%08x, nNonce=%u, vtx=%u)\n",
        GetHash().ToString(),
        nVersion,
        hashPrevBlock.ToString(),
        hashMerkleRoot.ToString(),
        nTime, nBits, nNonce,
        vtx.size());
    for (const auto& tx : vtx) {
        s << "  " << tx->ToString() << "\n";
    }
    return s.str();
}
