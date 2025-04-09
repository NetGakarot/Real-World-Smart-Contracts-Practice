// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract PiggyBank {

    address public owner;
    uint public constant lockPeriod = 60 days;
    uint public constant leastAmount = 0.01 * (10**18);
    string public APY = "14.6%";

    event Staked(address indexed sender, uint amount,uint timestamp,string note);
    event Withdraw(address indexed caller, uint amount);
    event LockExtend(address indexed caller, uint time, string note);

    mapping(address => uint) public balances;
    mapping(address => uint) public userLockTime;
    mapping(address => uint) nextWithdrawTime;
    mapping(address => uint) depositTime;

    constructor () {
        owner = msg.sender;
    }

    modifier onlyAfter() {
        require(block.timestamp >= userLockTime[msg.sender],"Locked");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender==owner,"Not authorized");
        _;
    }

    function deposit(uint amount) payable public {
        require(amount > leastAmount,"Amount should be greater than 0.01 ETH!");
        require(msg.value==amount,"Amount doesnt match with msg.value");
        balances[msg.sender] += amount;
        userLockTime[msg.sender] = block.timestamp + lockPeriod;
        depositTime[msg.sender] = block.timestamp;
        emit Staked(msg.sender, amount,block.timestamp,"Deposit received");
    }

    fallback() external payable {
        require(msg.value > leastAmount,"Amount should be greater than 0.01 ETH!");
        balances[msg.sender] += msg.value;
        userLockTime[msg.sender] = block.timestamp + lockPeriod;
        depositTime[msg.sender] = block.timestamp;
        emit Staked(msg.sender, msg.value,block.timestamp,"Deposit received");
    }

    receive() external payable {
        require(msg.value > leastAmount,"Amount should be greater than 0.01 ETH!");
        balances[msg.sender] += msg.value;
        userLockTime[msg.sender] = block.timestamp + lockPeriod;
        depositTime[msg.sender] = block.timestamp;
        emit Staked(msg.sender, msg.value,block.timestamp,"Deposit received");
    }

    function extendLockTime(uint _seconds) public {
        userLockTime[msg.sender] += _seconds;
        emit LockExtend(msg.sender, _seconds, "Lock Time Extended");
    }

    function withdrawAll() public payable onlyAfter {
        require(block.timestamp > nextWithdrawTime[msg.sender],"Cooldown period active, Please try again after some time");
        uint amount = balances[msg.sender];
        require(amount > 0,"No Balance");
        uint daysPassed = (block.timestamp - depositTime[msg.sender]) / 1 days;
        uint bonus = (balances[msg.sender] * 4 * daysPassed) / 10000;
        amount = amount + bonus;
        require(address(this).balance > amount,"Contact Admin");
        (bool success, ) = msg.sender.call{value:amount}("");
        require(success,"Failed!");
        balances[msg.sender] = 0;
        userLockTime[msg.sender] = 0;
        nextWithdrawTime[msg.sender] = block.timestamp + 10 minutes;
        emit Withdraw(msg.sender, amount);
    }

    function getBalance() public view returns(uint) {
        return balances[msg.sender];
    }

    function getLeastAmount() public pure returns(uint) {
        return leastAmount;
    }

    function lockTimeRemaining() public view returns(uint) {
        if (block.timestamp >= userLockTime[msg.sender]) return 0;
        return userLockTime[msg.sender] - block.timestamp;
    }


    function AnnualPerYield() public view returns(string memory) {
        return APY;
    }

    function minimumLockPeriod() public pure returns(uint) {
        return lockPeriod/1 days;
    }
    
    function kill() public onlyOwner {
        uint amount = address(this).balance;
        (bool success, ) = owner.call{value:amount}("");
        require(success,"Failed!");
        emit Withdraw(owner, amount);
        
    }

}
