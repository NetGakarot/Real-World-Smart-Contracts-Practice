// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Logic {
    uint public number;

    function setNumber(uint _num) public {
        number = _num;
    }

    function getNumber() public view returns (uint) {
        return number;
    }
}
