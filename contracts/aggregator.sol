//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";


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
        uint64  originChainId;
        address to;
        uint256 amount;
        bytes32 merkleRoot;
    }

    // deposit event
    event Deposit(uint64 targetChainId, address indexed _from, address indexed _to, uint256 _value);

    constructor(address _operator, address _bridgeAddr, uint64 _chainId) {
        bridgeinfo.amount = 0;
        bridgeinfo.originChainId = _chainId;
        _grantRole(OPERATOR_ROLE, _operator);
        //L2 to L1 bridge address
        address bridgeAddr = _bridgeAddr;
    }

    function deposit(uint64 _targetChainId, address _to) external payable {
        // check if receiver address exist
        require(_to != address(0), "Invalid receiver address");
        //check if chainId is allowed
        require(_targetChainId == 123, "Unsupported target chain id");
        Transfert memory newTransfert = Transfert({
            to: msg.sender,
            value: msg.value,
            targetChainId: _targetChainId
        });
        // log for hardhat
        console.log(
            "Transferring %s eth from %s to %s on chain id %s.",
            msg.sender,
            _to,
            _targetChainId
        );
        // Notify off-chain applications of the deposit.
        emit Deposit(_targetChainId, msg.sender, _to, msg.value);
        
    }

    function createMerkel() internal {

    }

    function sendToL1() public onlyRole(OPERATOR_ROLE) {

    }
    /*
     * Read only function to retrieve the Merkel Root.
     */
    function getMerkleRoot() external view returns (bytes32) {
        return bridgeinfo.merkleRoot;
    }
}
