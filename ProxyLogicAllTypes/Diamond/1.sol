// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FacetA {
    uint256 public valueA;

    function setA(uint256 _val) external {
        valueA = _val;
    }

    function getA() external view returns (uint256) {
        return valueA;
    }
}
