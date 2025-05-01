// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

error NotAuthorized();
error InvalidAddress();

contract Proxy {
    address public logicContract;
    address public owner;

    event LogicUpgraded(address newImplementation);
    event OwnerChanged(address newOwner);

    constructor(address _logicContract) {
        owner = msg.sender;
        logicContract = _logicContract;
    }

    function changeOwner(address newOwner) public {
        if(msg.sender != owner) revert NotAuthorized();
        if(newOwner == address(0)) revert InvalidAddress();
        owner = newOwner;
        emit OwnerChanged(newOwner);
    }

    function changeLogicAddress(address _logicContract) public {
        if(msg.sender != owner) revert NotAuthorized();
        if(_logicContract == address(0)) revert InvalidAddress();
        logicContract = _logicContract;
        emit LogicUpgraded(_logicContract);
    }

    function _delegate(address _implementation) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    fallback() external payable {_delegate(logicContract);}
    receive() external payable {_delegate(logicContract);}
}