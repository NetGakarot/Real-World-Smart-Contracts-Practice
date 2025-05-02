// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MyLogic {
    uint256 public number;

    function setNumber(uint256 _num) external {
        number = _num;
    }

    function getNumber() external view returns (uint256) {
        return number;
    }
}
