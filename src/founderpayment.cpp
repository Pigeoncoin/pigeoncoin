/*
 * Copyright (c) 2018 The Dash Core developers
// Copyright (c) 2021-2022 The Pigeoncoin Core developers
 * Distributed under the MIT software license, see the accompanying
 * file COPYING or http://www.opensource.org/licenses/mit-license.php.
 *
 * founderpayment.cpp
 */

#include "founderpayment.h"
#include "util.h"
#include "chainparams.h"
#include "base58.h"
#include "validation.h"

CAmount FounderPayment::getFounderPaymentAmount(int blockHeight, CAmount blockReward) {
	 if (blockHeight <= startBlock){
		 return 0;
	 }
	 for(int i = 0; i < rewardStructures.size(); i++) {
		 FounderRewardStructure rewardStructure = rewardStructures[i];
		 if(blockHeight <= rewardStructure.founderFeeEndHeight) {
			 return blockReward * rewardStructure.rewardPercentage / 100;
		 }
	 }
	 return 0;
}

CScript FounderPayment::GetFounderPayeeScript(int nHeight){
	string payeeaddr = GetFounderPayeeAddr(nHeight);
	return GetScriptForDestination(DecodeDestination(payeeaddr));
}

//Start Extra helper functions

std::string FounderPayment::GetFounderPayeeAddr(int nHeight){
	return nHeight >= address2StartBlock ? founderAddress2 : founderAddress;
}

bool FounderPayment::isPossibleFounderReward(CAmount nValPaid,CAmount nFounderRequiredAmount,int nHeight,CAmount blockReward){
	bool fPossible = nValPaid >= nFounderRequiredAmount;
	CAmount mnReward = GetMasternodePayment(nHeight,blockReward);
	//Handle mainnet switchover
	if(mnReward > 0)
		fPossible = fPossible && nValPaid < mnReward;
	return  fPossible;
}

void FounderPayment::LogFounderDebug(const CTxOut& out,int height,CAmount founderReward,CAmount blockReward){
	CTxDestination addressCurr;
	std::string addrCurr,addrExpected;
	addrExpected = GetFounderPayeeAddr(height);
	//Check if the address is convertable to a addr
	if (ExtractDestination(out.scriptPubKey, addressCurr)){
		addrCurr = EncodeDestination(addressCurr);
		//Log this only if addrs doesnt match for founder payment
		if(addrCurr != addrExpected)
				LogPrintf("Amount paid %d,Current Addr %s,Expected Addr %s\n",out.nValue / COIN,addrCurr,addrExpected);
	}
}

//End Extra helper functions

void FounderPayment::FillFounderPayment(CMutableTransaction& txNew, int nBlockHeight, CAmount blockReward, CTxOut& txoutFounderRet) {
    // GET FOUNDER PAYMENT VARIABLES SETUP
	txoutFounderRet = CTxOut();
    CAmount founderPayment = getFounderPaymentAmount(nBlockHeight, blockReward);
    // split reward between miner ...
    txNew.vout[0].nValue -= founderPayment;
    txoutFounderRet = CTxOut(founderPayment, GetFounderPayeeScript(nBlockHeight));
    txNew.vout.push_back(txoutFounderRet);
    LogPrintf("FounderPayment::FillFounderPayment -- Founder payment %lld to %s\n", founderPayment,
    		GetFounderPayeeAddr(nBlockHeight));
}

bool FounderPayment::IsFounderPayeeValid(const CTransaction& txNew, const int height, const CAmount blockReward) {
	CAmount founderReward = getFounderPaymentAmount(height, blockReward);
	CScript payee = GetFounderPayeeScript(height);

	for(const CTxOut& out : txNew.vout) {
		if(isPossibleFounderReward(out.nValue,founderReward,height,blockReward)){
			// LogFounderDebug(out,height,founderReward,blockReward);
			if(out.scriptPubKey == payee && out.nValue >= founderReward) {
				return true;
			}
		}
	}
    for(int blockHeight, i = 0; i < rewardStructures.size(); i++) {
        FounderRewardStructure rewardStructure = rewardStructures[i];
        if(blockHeight >= rewardStructure.founderFeeEndHeight){
            if(founderReward == 0){
                return true;
            }
        }
	}
	return false;
}