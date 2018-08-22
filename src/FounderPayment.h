/*
 * Copyright (c) 2018 The Pigeon Core developers
 * Distributed under the MIT software license, see the accompanying
 * file COPYING or http://www.opensource.org/licenses/mit-license.php.
 * 
 * FounderPayment.h
 *
 *  Created on: Jun 24, 2018
 *      Author: Tri Nguyen
 */

#ifndef SRC_FOUNDERPAYMENT_H_
#define SRC_FOUNDERPAYMENT_H_
#include <string>
#include "amount.h"
#include "primitives/transaction.h"
#include "script/standard.h"
using namespace std;

static const string DEFAULT_FOUNDER_ADDRESS = "XQfwRdDEsndtoYLPrYahi4sc1KgLztpgnJ";

class FounderPayment {
public:
	FounderPayment(int startBlock = 0, const string &address = DEFAULT_FOUNDER_ADDRESS, int rewardPercentage = 0.01) {
		this->founderAddress = address;
		this->startBlock = startBlock;
		this->rewardPercentage = rewardPercentage;
	}
	~FounderPayment(){};
	CAmount getFounderPaymentAmount(int blockHeight, CAmount blockReward);
	void FillFounderPayment(CMutableTransaction& txNew, int nBlockHeight, CAmount blockReward, CTxOut& txoutFounderRet);
	bool IsBlockPayeeValid(const CTransaction& txNew, const int height, const CAmount blockReward);
	int getStartBlock() {return this->startBlock;}
private:
	string founderAddress;
	int startBlock;
	int rewardPercentage;
};



#endif /* SRC_FOUNDERPAYMENT_H_ */
