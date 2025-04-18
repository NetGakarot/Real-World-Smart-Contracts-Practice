// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Child.sol";


contract Factory {

    address public owner;

    mapping(address => address[]) public userToChildren;

    event ChildCreated(address indexed user, address childAddress);


    constructor(address _owner) {
        owner = _owner;
    }

    function changeOwner(address newOwner) public {
        if (msg.sender != owner) revert NotAuthorized(msg.sender);
        if(newOwner == address(0)) revert InvalidAddress(address(0));
        owner = newOwner;
    }

    function createChildContract() public {
        Child child = new Child(msg.sender);
        userToChildren[msg.sender].push(address(child));
        emit ChildCreated(msg.sender, address(child));
    }

    function getChildren(address user) public view returns (address[] memory) {
        return userToChildren[user];
    }

}
