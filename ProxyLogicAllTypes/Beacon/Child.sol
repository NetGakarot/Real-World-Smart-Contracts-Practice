// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Child {
    uint public value;
    address public owner;

    function initialize(uint _value) external {
        require(owner == address(0), "Already initialized");
        owner = msg.sender;
        value = _value;
    }

    function updateValue(uint _newValue) external {
        require(msg.sender == owner, "Not owner");
        value = _newValue;
    }
}
