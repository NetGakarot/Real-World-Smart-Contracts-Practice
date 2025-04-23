// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Logic {
    uint256 public num;
    address public sender;
    uint public value;


    function setVars(uint256 _num) public payable {
        num = _num;
        sender = msg.sender;
        value = msg.value;
    }

}
