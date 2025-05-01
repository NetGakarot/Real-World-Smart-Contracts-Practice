// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Beacon {
    address public implementation;
    address public admin;

    constructor(address _impl) {
        implementation = _impl;
        admin = msg.sender;
    }

    function updateImplementation(address _newImpl) external {
        require(msg.sender == admin, "Not admin");
        implementation = _newImpl;
    }
}
