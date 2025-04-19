// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

/*16.1.	Cross-Contract Allowance System
One contract maintains allowances. Other contracts use those allowances via instance or interface.
*/

error AmountZero();
error InsufficientBalance(string note);
error NotAuthorized(address sender);
error InvalidAddress();

contract MyContract {
    address public owner;

    mapping(address => uint) deposits;
    mapping(address => mapping(address => uint)) allowances;
    mapping(address => uint) transfers;

    event Deposit(address indexed _sender, uint _amount);
    event SetAllowance(address indexed _spender, uint _amount);
    event Withdraw(address indexed _spender, uint _amount);
    event Transfer(address indexed _sender, address indexed _to, uint _amount);

    constructor() {
        owner = msg.sender;
    }

    function changeOwner(address newOwner) external {
        if(msg.sender != owner) revert NotAuthorized(msg.sender);
        if(newOwner == address(0)) revert InvalidAddress();
        owner = newOwner;
    }

    function _deposit() private {
        if (msg.value <= 0) revert AmountZero();
        deposits[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function deposit(address user) external payable {
        if (msg.value <= 0) revert AmountZero();
        deposits[user] += msg.value;
        emit Deposit(user, msg.value);
    }

    fallback() external payable {
        _deposit();
    }

    receive() external payable {
        _deposit();
    }

    function setAllowance(address spender, uint amount) external {
        if(msg.sender != owner) revert NotAuthorized(msg.sender);
        if (address(this).balance < amount)
            revert InsufficientBalance("Contract balance is low");
        allowances[msg.sender][spender] += amount;
        emit SetAllowance(spender, amount);
    }

    function withdraw(uint amount) external {
        if (allowances[owner][msg.sender] < amount)
            revert InsufficientBalance("Allowance is low");
        if (address(this).balance < amount)
            revert InsufficientBalance("Contract balance is low");
        allowances[owner][msg.sender] -= amount;
        transfers[msg.sender] += amount;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Failed!");
        emit Withdraw(msg.sender, amount);
    }

    function transfer(address to, uint amount) external {
        if(to == address(0)) revert InvalidAddress();
        if (allowances[owner][msg.sender] < amount)
            revert InsufficientBalance("Allowance is low");
        if (address(this).balance < amount)
            revert InsufficientBalance("Contract balance is low");
        allowances[owner][msg.sender] -= amount;
        transfers[to] += amount;
        (bool success, ) = to.call{value: amount}("");
        require(success, "Failed!");
        emit Transfer(msg.sender, to, amount);
    }

    function getDeposits(address user) external view returns(uint) {
        return deposits[user];
    }

    function getAllowance(address user) external view returns(uint) {
        return allowances[owner][user];
    }

    function getTransfers(address user) external view returns(uint) {
        return transfers[user];
    }

    function getContractBalance() external view returns(uint) {
        if(msg.sender != owner) revert NotAuthorized(msg.sender);
        return address(this).balance;
    }

    function withdrawAll() external payable {
        if(msg.sender != owner) revert NotAuthorized(msg.sender);
        uint _amount = address(this).balance;
        if (_amount == 0) revert AmountZero();
        (bool success, ) = owner.call{value:_amount}("");
        require(success,"Failed!");
        emit Withdraw(owner, _amount);
    }

}
