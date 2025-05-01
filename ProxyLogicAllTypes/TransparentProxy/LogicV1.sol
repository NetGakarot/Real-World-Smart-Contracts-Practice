// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract LogicV1 {
    uint result;

    function multiply(uint a, uint b) public {
        result = a * b;
    }

    function getResult() public view returns(uint) {
        return result;
    }
}
