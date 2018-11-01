Pigeoncoin Core integration or staging tree
=======================================

Official Website: https://pigeoncoin.org

Official Discord Channel: https://discord.gg/SZcf63h

Abstract
--------

Pigeoncoin aims to implement a blockchain which is optimized specifically to complete an altruistic goal: to end data collection in social media. Since Bitcoin has been so extensively developed and tested, Pigeoncoin aims not to reinvent the wheel but to optimize it and as such is built on a fork of the Bitcoin code. Key changes include a faster block reward time (1 minute) and a change in the quantity of coins (21 Billion coins instead of 21 Million coins).

Pigeoncoin is free and open source and will be issued and mined transparently with no pre-mine, developer allocation or any other similar set aside. Pigeoncoin is intended to prioritize user control, privacy and censorship resistance and be jurisdiction agnostic while allowing simple optional additional features for users based on their need.


What is Pigeoncoin?
----------------
Pigeoncoin pioneered the X16S (shuffle) algorithm built from the X16R algorithm and aims to complete an altruistic goal: to end data collection in social media as well as provide an open-source decentralized data layer platform for the development of decentralized community applications.

Pigeoncoin is an experimental digital currency that enables instant payments to
anyone, anywhere in the world. Pigeoncoin is the proof-of-concept network for the X16S algorithm.
We thank the Ravencoin team for their hard work on innovating the X16R algorithm and hope that our efforts are useful to them as well.

Previous to our efforts, the X16R (random) algorithm was launched on the Ravencoin network in early 2018. This new algorithm provided an innovative method of ASIC resistance. Since our new algorithm is building on the Ravencoin team's work, it's important to first understand how it works. X16S randomizes the order based on the previous block hash, but no algorithms are repeated or omitted. This provides all the benefits of X16R while vastly improving the hashrate and power consistency. This makes it much better for small miners, further promoting decentralization.  To dig in further for those that are more technically minded, check out our whitepaper for a more technical presentation at: https://github.com/Pigeoncoin/brand/blob/master/X16S-whitepaper.pdf


For more information, as well as an immediately useable compiled version of
the Pigeoncoin Core software, checkout https://pigeoncoin.org or navigate to our releases tab at https://github.com/Pigeoncoin/pigeoncoin/releases for up-to-date releases and patches of the software.

License
-------

Pigeoncoin Core is released under the terms of the MIT license. See [COPYING](COPYING) for more
information or see https://opensource.org/licenses/MIT.

Development Process
-------------------

The `master` branch is regularly built and tested as per the structure of Github, but is not guaranteed to be
completely stable. [Tags](https://github.com/PigeonProject/Pigeoncoin/tags) are created
regularly to indicate new official, stable release versions of Pigeon Core.

The contribution workflow is described in [CONTRIBUTING.md](CONTRIBUTING.md).

The developer [mailing list](https://lists.linuxfoundation.org/mailman/listinfo/pigeon-dev)
should be used to discuss complicated or controversial changes before working
on a patch set.

Developer IRC can be found on Freenode at #pigeon-core-dev.

Note that most of the above follows the standard development process that most cryptocurrencies follow.

Testing
-------

Testing and code review is the roadblock of development; we get more pull
requests than we can review and test on short notice. Please be patient and help out by testing
other people's pull requests, and remember this is a security-critical project where any mistake might cost people
lots of money.

Testnet is now up and running and available to use during development. There is an issue when connecting to the testnet that requires the use of the -maxtipage parameter in order to connect to the test network initially. After the initial launch the -maxtipage parameter is not required.

Use this command to initially start pigeond on the testnet. <code>./pigeond -testnet -maxtipage=259200</code>

### Automated Testing

Developers are strongly encouraged to write [unit tests](src/test/README.md) for new code, and to
submit new unit tests for old code. Unit tests can be compiled and run
(assuming they weren't disabled in configure) with: `make check`. Further details on running
and extending unit tests can be found in [/src/test/README.md](/src/test/README.md).

There are also [regression and integration tests](/test), written
in Python, that are run automatically on the build server.
These tests can be run (if the [test dependencies](/test) are installed) with: `test/functional/test_runner.py`


High Level Background: A Quick Overview of Blockchain Technology
----------------------------------------------------------------

Please note that the vast majority of these descriptions are based on verbiage from other coin releases like Bitcoin and Ravencoin because at the core, we all built from the initial code base of Bitcoin.  Hence the similarity in the description and verbiage.  For those who are new to blockchain and cryptocurrency in general, here is a high level introduction to the technology that powers our space of innovation.  Here we go:

A blockchain is a ledger showing all transactions made with a currency, including a coin or transaction's value - as well as the ability for that currency to be transferred to other parties. Of all the possible ways that the blockchain can be used, the reporting of who owns what and when and when that ownership was acquired is one of the core uses of the technology.  This is why Bitcoin was the first and most successful use case for blockchain technology to date.

If Henry Ford's Model T was the only option until now, the world of automobiles will be bland and boring.  So new innovations using Ford's ideas of the assembly line grew and today the variety of the landscape of cars including the reimagined assembly space of the Tesla electric cars confirms that as human beings we need variety.  So it was with Bitcoin, because new coins were created using the basic foundations that Bitcoin innovated but improvements were made along the way.  One such improvement and a successful one at that was Ethereum.  But with Ethereum one of its biggest innovations was the ability to build tokens on top of that blockchain and create smart contracts.  These tokens offer many advantages to traditional shares or other participation mechanisms such as faster transfer, possibly increased user control and censorship resistance and reduction or elimination of the need for trusted third parties.

Pigeoncoin is designed to be able to implement a blockchain on top of which we will build a social network which will be optimized specifically to end data collection in social media.  Recent events like Facebook being brought to congress to answer for privacy breaches and other issues demonstrate that it can and it is dangerous for one company or a monopoly of companies to have the power and sole discretion to gather such sensitive information on its user base; sometimes information that you are not even aware is being collected.  These companies then turn around and sell that information to the highest bidder for the purposes of making profit. In the meantime the user gains no real financial benefit from the information they created, but is bombarded with sometimes constant and unwanted advertisements.  Pigeoncoin is here to change that; by being completely community operated.

In the new global economy, physical borders and defined jurisdictions will be less relevant and frictionless transfer of assets and value between parties and individuals anywhere in the world at anytime of the day will be increasingly more important. We are at the dawn of the era when significant amounts of wealth can instantly be moved or transferred using cryptocurrencies like Bitcoin or Pigeoncoin.  This means that global consumers will likely demand the same efficiency for their less tangible assets: their information and their privacy.

For such a global social network to work it will need to be independent of regulatory jurisdictions.  It will need to be decentralized and not controlled by one entity or organization.  It will have to be governed in a democratic manner and at last our forefathers dream of "...government by the people, of the people and for the people.." will finally be realized in part -- at least on social media.  In the old days, pigeons were agents of truth literally in that they were used to send messages just as ravens were.  Pigeoncoin will be as pigeons were: a blockchain where information can be trusted because of consensus. That information is owned and controlled by whoever created it; without worry about whether that information is being accessed by an authorized third party whose aims and intentions are less than noble and good. This is not due to ideological belief but practicality: if the rails for blockchain value and information transfer are not censorship resistant and jurisdiction agnostic, any given jurisdiction may be in conflict with another.  In the outdated system, wealth was generally confined in the jurisdiction of the holder and therefore easy to control based on the policies of that jurisdiction. Because of the global nature of blockchain technology any protocol level ability to control wealth would potentially place jurisdictions in conflict and will not be able to operate fairly.  That is the goal and the vision of Pigeoncoin: to end data collection in social media on a decentralized blockchain that is jurisdiction agnostic and censorship resistant.  Join us to build this together!

Rewritten by Xrawe5885
