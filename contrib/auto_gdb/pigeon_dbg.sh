#!/bin/bash
# use testnet settings,  if you need mainnet,  use ~/.pigeoncore/pigeond.pid file instead
pigeon_pid=$(<~/.pigeoncore/testnet3/pigeond.pid)
sudo gdb -batch -ex "source debug.gdb" pigeond ${pigeon_pid}
