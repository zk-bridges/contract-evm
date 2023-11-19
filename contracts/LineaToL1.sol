//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "./IL2ETHGateway.sol";
import "./IMessageService.sol";

contract LineaToL1{
    // struct of basic infos from the origin of the L2 tx
    struct BridgeInfo {
        uint64  chainId;
        address user;
    }
    address bridgeAddr;
    address l1ContractAddr;
    IMessageService IMessageService_contract;
    // deposit event
    event Deposit(uint64 targetChainId, address indexed _from, address indexed _to, uint256 _value);

    constructor() {
        //L2 to L1 bridge address
        bridgeAddr = 0xC499a572640B64eA1C8c194c43Bc3E19940719dC;
        l1ContractAddr = 0x932F80Fc3d023E8DAC12A3aE2A8611Fdd3cF360f;
        IMessageService_contract = IMessageService(bridgeAddr);
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
        IMessageService_contract.sendMessage{value: msg.value}( _to, 127200001484000, abi.encode(newBridgeInfo));
    }
}
