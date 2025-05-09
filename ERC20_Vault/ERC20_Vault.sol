/* 1.	Time-Locked ERC20 Vault
Build a contract where users can deposit ERC20 tokens that are locked for a specific period. Only 
after the time expires, the user can withdraw. Use nested mappings, ERC20 logic, and modifiers.
*/

error NotEnoughBalance(uint requested, uint balance);
error NotAuthorized(address sender);
error AmountZero();



//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract ERC20_Vault {

    address owner;
    string public name = "Gakarot";
    string public symbol = "Gak$";
    uint8 public decimals = 18;
    uint public totalSupply;
    uint public Fixed_Locked_Time = 60 days;

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    mapping(address => uint) public vault;
    mapping(address => uint) public locked_time;

    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed approver, address indexed spender, uint amount);
    event Deposit(address indexed from, uint amount);
    event Withdraw(address indexed by, uint amount);

    constructor (uint _initialSupply) {
        totalSupply = _initialSupply * (10 ** 18);
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    modifier onlyAfter() {
        require(locked_time[msg.sender] <= block.timestamp,"Locked time is active");
        _;
    }


    function transfer(address _to, uint _amount) public returns (bool) {
        if(_amount == 0) revert AmountZero();
        if(_amount > balanceOf[msg.sender]) revert NotEnoughBalance(_amount,balanceOf[msg.sender]);
        balanceOf[msg.sender] -= _amount;
        balanceOf[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    function incAllowance(address _spender, uint _amount) public returns (bool) {
        if(_amount == 0) revert AmountZero();
        allowance[msg.sender][_spender] += _amount;
        emit Approval(msg.sender, _spender,allowance[msg.sender][_spender]);
        return true;
    }

    function decAllowance(address _spender, uint _amount) public returns (bool) {
        if(_amount == 0) revert AmountZero();
        require(allowance[msg.sender][_spender] >= _amount, "Not enough allowance");
        allowance[msg.sender][_spender] -= _amount;
        emit Approval(msg.sender, _spender,allowance[msg.sender][_spender]);
        return true;
    }

    function transferFrom(address _from, address _to, uint _amount) public returns (bool) {
        if(_amount == 0) revert AmountZero();
        if(_amount > balanceOf[msg.sender]) revert NotEnoughBalance(_amount,balanceOf[msg.sender]);
        if(_amount > allowance[_from][msg.sender]) revert NotEnoughBalance(_amount,allowance[_from][msg.sender]);
        balanceOf[_from] -= _amount;
        allowance[_from][msg.sender] -= _amount;
        balanceOf[_to] += _amount;
        emit Transfer(_from, _to, _amount);
        return true;
    }

    function deposit(uint _amount) public returns (bool) {
        if(_amount == 0) revert AmountZero();
        if(_amount > balanceOf[msg.sender]) revert NotEnoughBalance(_amount,balanceOf[msg.sender]);
        balanceOf[msg.sender] -= _amount;
        vault[msg.sender] += _amount;
        locked_time[msg.sender] = block.timestamp + Fixed_Locked_Time;
        emit Deposit(msg.sender, _amount);
        return true;
    }

    function withdrawVault(uint _amount) public onlyAfter returns (bool) {
        if(_amount == 0) revert AmountZero();
        if(_amount > vault[msg.sender]) revert NotEnoughBalance(_amount,vault[msg.sender]);
        vault[msg.sender] -= _amount;
        balanceOf[msg.sender] += _amount;
        emit Withdraw(msg.sender,_amount);
        return true;
    }

    function getBalance() public view returns(uint) {
        return balanceOf[msg.sender];
    }

    function getName() public view returns(string memory) {
        return name;

    }
    function getSymbol() public view returns(string memory) {
        return symbol;
    }

    function getDecimal() public view returns(uint) {
        return decimals;
    }

    function getTotalSupply() public view returns(uint) {
        return totalSupply;
    }

    function fixedLockedTime() public view returns(uint) {
        return Fixed_Locked_Time;
    }

    function getAllowance(address _spender) public view returns(uint) {
        return allowance[msg.sender][_spender];
    }

    function getVaultBalance() public view returns(uint) {
        return vault[msg.sender];
    }

    function remainingLockedTime() public view returns(uint) {
        return block.timestamp - locked_time[msg.sender];
    }
}
