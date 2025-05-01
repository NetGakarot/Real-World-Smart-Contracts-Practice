// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


contract LogicV1 {
    address public logicContract;
    address public owner;
    uint256 public value;


    function setValue(uint256 _value) public {
        value = _value;
    }

    function getValue() public view returns (uint256) {
        return value;
    }
}
