// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract CrowdFund {

    address public owner;
    uint public deadline;
    uint public goal;
    uint public constant minAmount = 0.1 ether;

    mapping(address => uint) public balances;
    

    event Deposit(address indexed sender, uint amount);
    event Withdraw(address indexed caller, uint amount);

    constructor() {
        owner = msg.sender;
        goal = 9999 ether;
        deadline = block.timestamp + 60 days;
    }

    modifier onlyOwner() {
        require(msg.sender==owner,"Not Authorized");
        _;
    }

    modifier onlyIf() {
        require(address(this).balance >= goal,"Goal not reached yet, cannot withdraw");
        require(deadline >= block.timestamp," Deadline is over, cannot withdraw");
        _;
    }

    modifier beforeDeadline() {
        require(block.timestamp < deadline, "Deadline passed");
        _;
    }


    function _deposit(uint _amount) internal {
        require(_amount >= minAmount,"Minimum amount is 0.1ETH!");
        require(deadline >= block.timestamp,"Deadline is over");
        require(goal > address(this).balance ,"Goal has been met");
        balances[msg.sender] += _amount;
        emit Deposit(msg.sender, _amount);
    }

    function deposit(uint amount) public payable {
        require(msg.value==amount,"Amount does not match value sent");
        _deposit(amount);
    }

    fallback() external payable {
        _deposit(msg.value);
    }

    receive() external payable {
        _deposit(msg.value);
    }

    function updateGoal(uint _newGoal) public onlyOwner beforeDeadline {
        require(_newGoal > 0, "Goal must be positive");
        goal = _newGoal;
    }

    function extendDeadline(uint extraTimeInSeconds) public onlyOwner beforeDeadline {
        deadline += extraTimeInSeconds;
    }


    function withdrawAll() public payable onlyIf onlyOwner {
        uint amount = address(this).balance;
        (bool success, ) = owner.call{value:amount}("");
        require(success,"Failed!");
        emit Withdraw(owner,amount);
    }

    function withdraw() public payable {
        require(block.timestamp > deadline,"Cannot withdraw deadline is not met");
        require(goal > address(this).balance,"Cannot withdraw goal has been met");
        require(balances[msg.sender] > 0,"Cannot withdraw zero ETH! Bitch");
        uint amount = balances[msg.sender];
        (bool success, ) = msg.sender.call{value:amount}("");
        require(success,"Failed!");
        balances[msg.sender] = 0;
        emit Withdraw(msg.sender,amount);
    }

    function getBalance() public view returns(uint) {
        return balances[msg.sender];
    }

    function deadlineLeft() public view returns(uint) {
        if(block.timestamp >= deadline) return 0;
        return deadline - block.timestamp;
    }

    function getGoal() public view returns(uint) {
        return goal;
    }

    function minEther() public pure returns(uint) {
        return minAmount;
    }

}