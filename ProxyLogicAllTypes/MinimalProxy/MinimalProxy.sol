// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MinimalProxy {
    address public implementation;
    address public owner;

    // The constructor accepts the implementation address and owner address
    constructor(address _implementation, address _owner) {
        implementation = _implementation;
        owner = _owner;
    }

    // Fallback function to delegate calls to the logic contract
    fallback() external payable {
        (bool success, ) = implementation.delegatecall(msg.data);
        require(success, "Delegatecall failed");
    }

    // Modifier to restrict access to the owner only
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    receive() external payable {
        (bool success, ) = implementation.delegatecall("");
        require(success, "Delegatecall failed");
    }
}
