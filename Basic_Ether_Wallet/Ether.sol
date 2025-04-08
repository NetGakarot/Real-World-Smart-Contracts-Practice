// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract EtherWallet {

    address public owner;
    mapping(address => uint) public balances;

    constructor () {
        owner=msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender==owner,"Not Authorized");
        _;
    }

    event Transfer(address indexed sender, address indexed receiver, uint amount);
    event Withdraw(address indexed caller, uint amount);
    event Deposit(address indexed sender, uint amount);
    event Balance(address indexed caller, uint amount);

    fallback() external payable {
        emit Deposit(msg.sender,msg.value);
        balances[msg.sender] += msg.value;
        }
    receive() external payable {
        emit Deposit(msg.sender,msg.value);
        balances[msg.sender] += msg.value;
        }

    function deposit() public payable {
        require(msg.value > 0,"Amount cant be zero");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender,msg.value);
    }

    function transfer(address payable _to, uint amount) public payable {
        require(amount > 0,"Amount cant be zero");
        require(balances[msg.sender] >= amount,"Insufficient balance");
        balances[msg.sender] -= amount;
        balances[_to] += amount;
        emit Transfer(msg.sender, _to, amount);
    }

    function withdraw(uint amount) public payable {
        require(amount > 0,"Amount cant be zero");
        require(balances[msg.sender] >= amount,"Insufficient balance");
        (bool success, ) = msg.sender.call{value:amount}("");
        require(success,"Failed!");
        balances[msg.sender] -= amount;
        emit Withdraw(msg.sender, amount);

    }

    function withdrawAll() public payable onlyOwner {
        uint bal = address(this).balance;
        (bool success, ) = owner.call{value:address(this).balance}("");
        require(success,"Failed!");
        emit Withdraw(owner, bal);
    }

    function getBalance() public returns(uint) {
        uint balance = balances[msg.sender];
        emit Balance(msg.sender, balance);
        return balance;
    }


}