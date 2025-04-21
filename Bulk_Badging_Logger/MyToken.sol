// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

error InsufficientBalance(uint balance, uint amount);
error AmountZero();

contract MyToken{

    string public name = "Gakarot";
    string public symbol = "$Gak";
    uint constant decimals = 18;
    uint public totalSupply;
    address public owner;

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event AllowanceStatus(address indexed from, address indexed to, uint256 amount, string status);
    event SupplyChanged(uint256 amount, string status);

    constructor(uint _initialSupply) {
        owner = msg.sender;
        totalSupply = _initialSupply * 10 ** 18;
        balanceOf[msg.sender] = totalSupply;
    }

    modifier onlyOwner() {
        require(msg.sender==owner,"Not Authorized");
        _;
    }

    function getdecimals() public pure returns (uint8) {
    return 18;
    }

    function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0), "Invalid owner");
    owner = newOwner;
    }

    function transfer(address _to, uint _amount) public returns(bool) {
        if (_amount == 0) {revert AmountZero();}
        if (balanceOf[msg.sender] < _amount) revert InsufficientBalance(balanceOf[msg.sender],_amount);
        balanceOf[msg.sender] -= _amount;
        balanceOf[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    function approve(address _spender, uint _amount) public returns(bool) {
        if (_amount == 0) {revert AmountZero();}
        allowance[msg.sender][_spender] += _amount;
        emit AllowanceStatus(msg.sender, _spender, _amount, "Increased");
        return true;
    }

    function increaseAllowance(address _spender, uint _amount) public returns(bool) {
        if (_amount == 0) {revert AmountZero();}
        allowance[msg.sender][_spender] += _amount;
        emit AllowanceStatus(msg.sender, _spender, _amount, "Increased");
        return true;
    }

    function decreaseAllowance(address _spender, uint _amount) public returns(bool) {
        if (_amount == 0) {revert AmountZero();}
        if (allowance[msg.sender][_spender] < _amount) {revert InsufficientBalance(allowance[msg.sender][_spender],_amount);}
        allowance[msg.sender][_spender] -= _amount;
        emit AllowanceStatus(msg.sender, _spender, _amount, "Decreased");
        return true;
    }

    function transferFrom(address _from, address _to, uint _amount) public returns(bool) {
        if (_amount == 0) {revert AmountZero();}
        if (balanceOf[_from] < _amount) revert InsufficientBalance(balanceOf[_from],_amount);
        if (allowance[_from][msg.sender] < _amount) revert InsufficientBalance(allowance[_from][msg.sender], _amount);
        allowance[_from][msg.sender] -= _amount;
        balanceOf[_from] -= _amount;
        balanceOf[_to] += _amount;
        emit Transfer(_from, _to, _amount);
        return true;
    }

    function burn(uint _amount) public onlyOwner returns(bool) {
        if (_amount == 0) {revert AmountZero();}
        if (balanceOf[owner] < _amount) revert InsufficientBalance(balanceOf[owner], _amount);
        balanceOf[owner] -= _amount;
        totalSupply -= _amount;
        emit SupplyChanged(_amount, "Burn");
        return true;
    }

    function mint(uint _amount) public onlyOwner returns(bool) {
        if (_amount== 0) {revert AmountZero();}
        balanceOf[owner] += _amount;
        totalSupply += _amount;
        emit SupplyChanged(_amount, "Mint");
        return true;
    }

    function getAnyonesBalance(address user) public view onlyOwner returns(uint) {
        return balanceOf[user];
    }

}
