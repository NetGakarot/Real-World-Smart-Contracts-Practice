// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./MinimalProxy.sol";  // import the MinimalProxy contract

contract ProxyFactory {
    address public logicContract;

    // Set the address of the logic contract during deployment
    constructor(address _logicContract) {
        logicContract = _logicContract;
    }

    // Function to deploy a new proxy pointing to the logic contract
    function createProxy() external returns (address) {
        // Create a new MinimalProxy with the sender as the owner
        MinimalProxy proxy = new MinimalProxy(logicContract, msg.sender);
        return address(proxy);
    }
}
