// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract P2 {
    address public logic;
    uint256 public number; // Yeh proxy ke storage me hoga, delegatecall isko update karega

    function setImplementation(address _logic) external {
        logic = _logic;
    }

    fallback() external payable {
        (bool success, bytes memory data) = logic.delegatecall(msg.data);
        require(success, "Delegatecall failed");
    }

    receive() external payable {
        (bool success, bytes memory data) = logic.delegatecall("");
        require(success, "Delegatecall failed");
    }
}
