// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract AllowanceWallet{

    address public owner;
    uint public totalSupply;
    mapping(address => mapping(address => uint)) public allowances;

    constructor (uint initialSupply) {
        totalSupply = initialSupply;
        owner=msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender==owner,"Not Authorized");
        _;
    }

    event Approve(address indexed owner, address indexed spender, uint amount);
    event Withdraw(address indexed caller, uint amount);

    function addAllowance(address to,uint amount) public onlyOwner {
        require(amount > 0,"Amount cant be zero");
        require(address(this).balance >= amount,"Insufficient balance");
        allowances[owner][to] += amount;
        emit Approve(owner, to, amount);
    }

    function withdraw(uint amount) public payable {
        require(amount > 0,"Amount cant be zero");
        require(allowances[owner][msg.sender] >= amount,"Insufficient balance");
        require(address(this).balance >=amount,"Insufficient balance");
        (bool success, ) = msg.sender.call{value:amount}("");
        require(success,"Failed!");
        allowances[owner][msg.sender] -= amount;
        emit Withdraw(msg.sender, amount);
    }

    function withdrawAll() public payable onlyOwner {
        uint bal = address(this).balance;
        (bool success, ) = owner.call{value:address(this).balance}("");
        require(success,"Failed!");
        emit Withdraw(owner, bal);
    }


    function getAllowance(address _spender) public view returns (uint) {
    return allowances[owner][_spender];
    }
       

    function getContractBalance() public view returns (uint) {
    return address(this).balance;
    }

}