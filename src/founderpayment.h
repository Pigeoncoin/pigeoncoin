/*
 * Copyright (c) 2018 The Dash Core developers
 * Distributed under the MIT software license, see the accompanying
 * file COPYING or http://www.opensource.org/licenses/mit-license.php.
 * 
 * founderpayment.h
 */

#ifndef SRC_FOUNDERPAYMENT_H_
#define SRC_FOUNDERPAYMENT_H_
#include <string>
#include "amount.h"
#include "primitives/transaction.h"
#include "script/standard.h"
using namespace std;

static const string DEFAULT_FOUNDER_ADDRESS = "n7YVWJjZhUi5ZepC9nQWX8hzhSFRCpzcNY";
struct FounderRewardStructure {
	int founderFeeEndHeight;
	int rewardPercentage;
};

class FounderPayment {
public:
	FounderPayment(vector<FounderRewardStructure> rewardStructures = {}, int startBlock = 0,
			const string &address = DEFAULT_FOUNDER_ADDRESS, const string &address2 = DEFAULT_FOUNDER_ADDRESS,
			int founder2StartBlock = 0) {
		this->founderAddress = address;
		this->startBlock = startBlock;
		this->rewardStructures = rewardStructures;
		this->founderAddress2 = address2;
		this->address2StartBlock = founder2StartBlock;
	}
	~FounderPayment(){};
	CAmount getFounderPaymentAmount(int blockHeight, CAmount blockReward);
	void FillFounderPayment(CMutableTransaction& txNew, int nBlockHeight, CAmount blockReward, CTxOut& txoutFounderRet);
	bool IsBlockPayeeValid(const CTransaction& txNew, const int height, const CAmount blockReward);
	std::string GetFounderPayeeAddr(int nHeight);
	void LogFounderDebug(const CTxOut& out,int height,CAmount founderReward,CAmount blockReward);
	bool isPossibleFounderReward(CAmount nValPaid,CAmount nFounderRequiredAmount,int nHeight,CAmount blockReward);
	int getStartBlock() {return this->startBlock;}
	bool shouldPayFounder(int nHeight) {return nHeight > this->startBlock;}
	int getAddress2StartBlock() {return this->address2StartBlock;}
	CScript GetFounderPayeeScript(int nHeight);
private:
	string founderAddress;
	string founderAddress2;
	int address2StartBlock;
	int startBlock;
	vector<FounderRewardStructure> rewardStructures;
};



#endif /* SRC_FOUNDERPAYMENT_H_ */