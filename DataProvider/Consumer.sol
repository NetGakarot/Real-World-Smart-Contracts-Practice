// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IOracle {
    function getPrice(string memory symbol) external view returns(uint256 price, uint256 updatedAt);
}

error NotAuthorized();
error InvalidAddress();

contract Consumer {

    address admin;
    IOracle public oracle;
    uint public maxDelay = 1 minutes;

    constructor(address _targetAddress) {
        admin = msg.sender;
        oracle = IOracle(_targetAddress);
    }

    function changeAdmin(address newAdmin) external {
        if(msg.sender != admin) revert NotAuthorized();
        if(newAdmin == address(0)) revert InvalidAddress();
        admin = newAdmin;
    }

    function isContract(address _addr) internal view returns (bool) {
        uint32 size;
        assembly {
        size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function changeTargetAddress(address newTargetAddress) external {
        if(msg.sender != admin) revert NotAuthorized();
        if(newTargetAddress == address(0)) revert InvalidAddress();
        if(!isContract(newTargetAddress)) revert InvalidAddress();
        oracle = IOracle(newTargetAddress);
    }

    function setMaxDelay(uint newDelay) external {
        if(msg.sender != admin) revert NotAuthorized();
        maxDelay = newDelay;
    }

    function getFreshPrice(string memory symbol) external view returns(uint) {
        (uint price, uint updatedAt) = oracle.getPrice(symbol);
        require(block.timestamp - updatedAt <= maxDelay,"Stale price");
        return price;
    }
}

