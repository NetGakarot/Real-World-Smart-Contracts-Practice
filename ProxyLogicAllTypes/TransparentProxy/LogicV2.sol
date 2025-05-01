// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract LogicV2 {
    address public logicContract;
    address public owner;
    uint value;

    function divide(uint a, uint b) public {
        if(b == 0) revert ("Cant be zero. Not defined");
        value = a / b;
    }

    function getResult() public view returns(uint) {
        return value;
    }
}