// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract Airdrop {

    address owner;
    address tokenAddr;

    mapping(address => uint) public tokenPerUser;
    mapping(address => bool) public userRecord;
    mapping(address => bool) public claimRecord;

    event userRegistered(address indexed _user, uint _amount);
    event incAmount(address indexed _user, uint _amount,string note);
    event decAmount(address indexed _user, uint _amount,string note);
    event Claimed(address indexed _user, uint _amount);

    constructor(address _token) {
        owner = msg.sender;
        tokenAddr = _token;
    }

    modifier onlyBy() {
        require(msg.sender==owner,"Not Authorized");
        _;
    }

    function changeOwner(address newOwner) public onlyBy {
        require(newOwner != address(0),"New owner passed is not valid");
        owner = newOwner;
    }

    function addUser(address user,uint amount) public onlyBy {
        require(!userRecord[user],"Already added");
        tokenPerUser[user] = amount;
        userRecord[user] = true;
        emit userRegistered(user, amount);
    }

    function incBalance(address user, uint amount) public onlyBy {
        require(userRecord[user],"User does not exist");
        tokenPerUser[user] += amount;
        emit incAmount(user, amount, "increased");
    }

    function decBalance(address user, uint amount) public onlyBy {
        require(userRecord[user],"User does not exist");
        require(tokenPerUser[user] >= amount, "Insufficient allocated tokens");
        tokenPerUser[user] -= amount;
        emit decAmount(user, amount, "decreased");
    }

    function claim() public {
        require(userRecord[msg.sender],"No airdrop for u Bitch!");
        require(!claimRecord[msg.sender],"Already claimed");
        claimRecord[msg.sender] = true;
        uint token = tokenPerUser[msg.sender];
        IERC20(tokenAddr).transfer(msg.sender,token);
        emit Claimed(msg.sender, token);
    }

    function getBalance() public view returns(uint) {
        return IERC20(tokenAddr).balanceOf(msg.sender);
    }

    function getTokenAlloted(address user) public view returns(uint) {
        return tokenPerUser[user];    
    }

    function getUserStatus(address user) public view returns(bool) {
        return userRecord[user];
    }

    function getClaimStatus(address user) public view returns(bool) {
        return claimRecord[user];
    }
}