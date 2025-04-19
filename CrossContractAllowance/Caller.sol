// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

interface IParent {
    
    function deposit(address user) external payable;
    function withdraw(uint amount) external payable;
    function transfer(address to, uint amount) external payable;
    function getDeposits(address user) external view returns(uint);
    function getAllowance(address user) external view returns(uint);
    function getTransfers(address user) external view returns(uint);
}

error NotAuthorized(address sender);
error InvalidAddress();

contract Caller {
    address admin;
    IParent public p;

    event TargetAddressChanged(address indexed newAddress, uint time);

    constructor(address payable _targetAddress) {
        admin = msg.sender;
        p = IParent(_targetAddress);
    }

    function changeOwner(address newAdmin) external {
        if(msg.sender != admin) revert NotAuthorized(msg.sender);
        if(newAdmin == address(0)) revert InvalidAddress();
        admin = newAdmin;
    }

    function changeTargetAddress(address payable _newTargetAddress) external {
        if(msg.sender != admin) revert NotAuthorized(msg.sender);
        if(_newTargetAddress == address(0)) revert InvalidAddress();
        p = IParent(_newTargetAddress);
        emit TargetAddressChanged(_newTargetAddress, block.timestamp);
    }

    function deposit() external payable {
        p.deposit{value:msg.value}(msg.sender);
    }

    fallback() external payable {
        p.deposit{value:msg.value}(msg.sender);
    }

    receive() external payable {
        p.deposit{value:msg.value}(msg.sender);
    }

    function withdraw(uint amount) external payable {
        p.withdraw(amount);
    }
    
    function transfer(address to, uint amount) external payable {
        p.transfer(to,amount);
    }

    function getDeposits(address user) external view returns(uint) {
       return p.getDeposits(user);
    }

    function getAllowance(address user) external view returns(uint) {
        return p.getAllowance(user);
    }

    function getTransfers(address user) external view returns(uint) {
        return p.getTransfers(user);
    }
}