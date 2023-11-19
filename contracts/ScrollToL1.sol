//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "hardhat/console.sol";
import "./IL2ETHGateway.sol";

contract ScrollToL1{
    // struct of basic infos from the origin of the L2 tx
    struct BridgeInfo {
        uint64  chainId;
        address user;
    }
    address bridgeAddr;
    IL2ETHGateway IL2ETHGateway_contract;
    // deposit event
    event Deposit(uint64 targetChainId, address indexed _from, address indexed _to, uint256 _value);

    constructor() {
        //L2 to L1 bridge address
        bridgeAddr = 0x3808d0F2F25839E73e0Fbf711368fC4aE80c7763;
        IL2ETHGateway_contract = IL2ETHGateway(bridgeAddr);
    }

    function deposit(uint64 _targetChainId, address _to) external payable {
        // check if receiver address exist
        require(_to != address(0), "Invalid receiver address");
        //check if chainId is allowed
        require(_targetChainId == 123, "Unsupported target chain id");
        BridgeInfo memory newBridgeInfo = BridgeInfo({
            chainId: _targetChainId,
            user: _to
        });
        // Notify off-chain applications of the deposit.
        emit Deposit(_targetChainId, msg.sender, _to, msg.value);
        // send to bridge
        IL2ETHGateway_contract.withdrawETHAndCall(_to, msg.value, abi.encode(newBridgeInfo), 1000000);
    }
}
