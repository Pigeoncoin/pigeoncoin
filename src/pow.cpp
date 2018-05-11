// Copyright (c) 2009-2010 Satoshi Nakamoto
// Copyright (c) 2009-2016 The Bitcoin Core developers
// Copyright (c) 2017 The Pigeon Core developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#include "pow.h"

#include "arith_uint256.h"
#include "chain.h"
#include "primitives/block.h"
#include "uint256.h"

unsigned int GetNextWorkRequired(const CBlockIndex* pindexLast, const CBlockHeader *pblock, const Consensus::Params& params) {
    assert(pindexLast != nullptr);
    int nHeight = pindexLast->nHeight + 1;
    bool postLWMA = nHeight >= params.zawyLWMAHeight;

    if (postLWMA == false) {
        //Original diff
        return PreLWMAGetNextWorkRequired(pindexLast, pblock, params);
    }
    else {
        //Zawy LWMA
        return LwmaGetNextWorkRequired(pindexLast, pblock, params);
    }

}

unsigned int PreLWMAGetNextWorkRequired(const CBlockIndex* pindexLast, const CBlockHeader *pblock, const Consensus::Params& params)
{
    assert(pindexLast != nullptr);
    unsigned int nProofOfWorkLimit = UintToArith256(params.powLimit).GetCompact();

    // Only change once per difficulty adjustment interval
    if ((pindexLast->nHeight+1) % params.DifficultyAdjustmentInterval() != 0)
    {
        if (params.fPowAllowMinDifficultyBlocks)
        {
            // Special difficulty rule for testnet:
            // If the new block's timestamp is more than 2* 10 minutes
            // then allow mining of a min-difficulty block.
            if (pblock->GetBlockTime() > pindexLast->GetBlockTime() + params.nPowTargetSpacing*2)
                return nProofOfWorkLimit;
            else
            {
                // Return the last non-special-min-difficulty-rules-block
                const CBlockIndex* pindex = pindexLast;
                while (pindex->pprev && pindex->nHeight % params.DifficultyAdjustmentInterval() != 0 && pindex->nBits == nProofOfWorkLimit)
                    pindex = pindex->pprev;
                return pindex->nBits;
            }
        }
        return pindexLast->nBits;
    }

    // Go back by what we want to be 14 days worth of blocks
    int nHeightFirst = pindexLast->nHeight - (params.DifficultyAdjustmentInterval()-1);
    assert(nHeightFirst >= 0);
    const CBlockIndex* pindexFirst = pindexLast->GetAncestor(nHeightFirst);
    assert(pindexFirst);

    return CalculateNextWorkRequired(pindexLast, pindexFirst->GetBlockTime(), params);
}

unsigned int CalculateNextWorkRequired(const CBlockIndex* pindexLast, int64_t nFirstBlockTime, const Consensus::Params& params)
{
    if (params.fPowNoRetargeting)
        return pindexLast->nBits;

    // Limit adjustment step
    int64_t nActualTimespan = pindexLast->GetBlockTime() - nFirstBlockTime;
    if (nActualTimespan < params.nPowTargetTimespan/4)
        nActualTimespan = params.nPowTargetTimespan/4;
    if (nActualTimespan > params.nPowTargetTimespan*4)
        nActualTimespan = params.nPowTargetTimespan*4;

    // Retarget
    const arith_uint256 bnPowLimit = UintToArith256(params.powLimit);
    arith_uint256 bnNew;
    bnNew.SetCompact(pindexLast->nBits);
    bnNew *= nActualTimespan;
    bnNew /= params.nPowTargetTimespan;

    if (bnNew > bnPowLimit)
        bnNew = bnPowLimit;

    return bnNew.GetCompact();
}

bool CheckProofOfWork(uint256 hash, unsigned int nBits, const Consensus::Params& params)
{
    bool fNegative;
    bool fOverflow;
    arith_uint256 bnTarget;

    bnTarget.SetCompact(nBits, &fNegative, &fOverflow);

    // Check range
    if (fNegative || bnTarget == 0 || fOverflow || bnTarget > UintToArith256(params.powLimit))
        return false;

    // Check proof of work matches claimed amount
    if (UintToArith256(hash) > bnTarget)
        return false;

    return true;
}

unsigned int LwmaGetNextWorkRequired(const CBlockIndex* pindexLast, const CBlockHeader *pblock, const Consensus::Params& params)
{
    // Special difficulty rule for testnet:
    // If the new block's timestamp is more than 2 * 10 minutes
    // then allow mining of a min-difficulty block.
    if (params.fPowAllowMinDifficultyBlocks &&
        pblock->GetBlockTime() > pindexLast->GetBlockTime() + params.nPowTargetSpacing * 2) {
        return UintToArith256(params.PowLimit(true)).GetCompact();
    }
    return LwmaCalculateNextWorkRequired(pindexLast, params);
}

unsigned int LwmaCalculateNextWorkRequired(const CBlockIndex* pindexLast, const Consensus::Params& params)
{
    if (params.fPowNoRetargeting) {
        return pindexLast->nBits;
    }

    //remove this check when we apply to mainnet.  We will have to reset testnet at this time
    int nHeight = pindexLast->nHeight + 1;
    const int N = (nHeight >= 45000 && nHeight < 49000)? 45 : 45;
    const int k = (nHeight >= 45000 && nHeight < 49000) ? 13632 : 2 * 60 * 60; 

    const int height = pindexLast->nHeight + 1;
    assert(height > N);

    arith_uint256 sum_target;
    int t = 0, j = 0;

    // Loop through N most recent blocks.
    for (int i = height - N; i < height; i++) {
        const CBlockIndex* block = pindexLast->GetAncestor(i);
        const CBlockIndex* block_Prev = block->GetAncestor(i - 1);
        int64_t solvetime = block->GetBlockTime() - block_Prev->GetBlockTime();

        j++;
        t += solvetime * j;  // Weighted solvetime sum.

        // Target sum divided by a factor, (k N^2).
        // The factor is a part of the final equation. However we divide sum_target here to avoid
        // potential overflow.
        arith_uint256 target;
        target.SetCompact(block->nBits);
        sum_target += target / (k * N * N);
    }
    // Keep t reasonable in case strange solvetimes occurred.
    if (t < N * k / 3) {
        t = N * k / 3;
    }

    const arith_uint256 pow_limit = UintToArith256(params.PowLimit(true));
    arith_uint256 next_target = t * sum_target;
    if (next_target > pow_limit) {
        next_target = pow_limit;
    }

    return next_target.GetCompact();
}

