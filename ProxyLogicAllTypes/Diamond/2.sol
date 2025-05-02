// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FacetB {
    uint256 public valueB;

    function setB(uint256 _val) external {
        valueB = _val;
    }

    function getB() external view returns (uint256) {
        return valueB;
    }
}
