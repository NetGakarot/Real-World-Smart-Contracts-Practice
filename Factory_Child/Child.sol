// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*13.Factory + Child Contracts (Clone Pattern)
Factory creates new child contracts. Users can interact with their own instance. 
Store user ↔ deployed contract mapping.
*/

error InsufficientBalance(uint balance, uint amount);
error AmountZero();
error NotAuthorized(address sender);
error InvalidAddress(address _address);
error Locked(uint time);

contract Child {
    address owner;
    uint public constant timeLockedFixed = 1 days;
    string public constant fixedBonus = "1%";

    mapping(address => Record) public dataOf;

    event Deposit(address indexed user, uint amount, uint time);
    event Withdraw(address indexed user, uint amount);

    struct Record {
        uint timeLocked;
        uint amount;
    }

    constructor(address _owner) {
        owner = _owner;
    }

    function changeOwner(address newOwner) public {
        if (msg.sender != owner) revert NotAuthorized(msg.sender);
        if(newOwner == address(0)) revert InvalidAddress(address(0));
        owner = newOwner;
    }

    function _deposit() public payable {
        if (msg.value <= 0) revert AmountZero();
        Record storage r = dataOf[msg.sender];
        r.timeLocked += block.timestamp + 1 days;
        r.amount += msg.value;
        emit Deposit(msg.sender, msg.value, block.timestamp);
    }

    function depositOwner() public payable {
        if (msg.sender != owner) revert NotAuthorized(msg.sender);
        if (msg.value <= 0) revert AmountZero();
    }
    function deposit() public payable {
        _deposit();
    }
    fallback() external payable {
        _deposit();
    }
    receive() external payable {
        _deposit();
    }

    function withdraw() public {
        Record storage r = dataOf[msg.sender];
        if(r.timeLocked > block.timestamp) revert Locked(block.timestamp);
        if (r.amount <= 0) revert AmountZero();
        uint bonus = (r.amount * 1) / 100;
        uint amount = r.amount + bonus;
        if (address(this).balance < amount)
            revert InsufficientBalance(address(this).balance, amount);
        r.amount = 0;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Failed!");
        emit Withdraw(msg.sender, amount);
    }

    function withdrawAll() public {
        if(msg.sender != owner) revert NotAuthorized(msg.sender);
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "Failed!");
        emit Withdraw(msg.sender, address(this).balance);
    }

    function getRecord(address user) public view returns(uint,uint) {
        Record storage r = dataOf[user];
        return (r.amount,r.timeLocked);
    }
}

