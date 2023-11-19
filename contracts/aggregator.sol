//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./IL2ETHGateway.sol";

contract Aggregator is AccessControl{
    // array of deposits / BridgeInfo
    Transfert[] public deposits;
    BridgeInfo[] public bridgeinfo;

    // struct for the storage of the deposits
    struct Transfert {
        address to;
        uint256 value;
        uint64 targetChainId;
    }
    // struct of basic infos from the origin of the L2 batch
    struct BridgeInfo {
        uint64  chainId;
        address user;
    }

    // deposit event
    event Deposit(uint64 targetChainId, address indexed _from, address indexed _to, uint256 _value);

    constructor(address _user, uint64 _chainId, address _bridgeAddr) {
        bridgeinfo.amount = 0;
        bridgeinfo.chainId = _chainId;
        //L2 to L1 bridge address
        address bridgeAddr = _bridgeAddr;
    }

    function deposit(uint64 _targetChainId, address _to) external payable {
        // check if receiver address exist
        require(_to != address(0), "Invalid receiver address");
        //check if chainId is allowed
        require(_targetChainId == 123, "Unsupported target chain id");
        BridgeInfo memory newBridgeInfo = BridgeInfo({
            to: _to,
            chainId: _targetChainId
        });
        // log for hardhat
        console.log(
            "Transferring %s eth from %s to %s on chain id %s.",
            msg.value,
            msg.sender,
            _to,
            _targetChainId
        );
        // Notify off-chain applications of the deposit.
        emit Deposit(_targetChainId, msg.sender, _to, msg.value);
        // create call data
        bytes memory callPayload = abi.encodeWithSignature("onScrollGatewayCallback(bytes)", newBridgeInfo);
        // send to bridge
        IL2ETHGateway.withdrawETHAndCall(_to, msg.sender, callPayload, 1000000);
        sendToL1();
    }

}
