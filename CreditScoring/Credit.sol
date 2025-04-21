// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*24.	Credit Scoring System
Assign scores to users based on tx activity (mock logic). Use struct, mapping, and view 
functions for external querying.
*/

error NotAuthorized();
error InvalidAddress();
error InsufficientBalance(uint balance, uint amount);
error AmountZero();

contract Credit{

    string public name = "Gakarot";
    string public symbol = "$Gak";
    uint constant decimals = 18;
    uint public totalSupply;
    address public owner;

    mapping(address => uint) balanceOf;
    mapping(address => mapping(address => uint)) allowance;
    mapping(address => uint) creditRecord;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event AllowanceStatus(address indexed from, address indexed to, uint256 amount, string status);
    event SupplyChanged(uint256 amount, string status);

    constructor(uint _initialSupply) {
        owner = msg.sender;
        totalSupply = _initialSupply * 10 ** 18;
        balanceOf[msg.sender] = totalSupply;
    }

    function transferOwnership(address newOwner) external {
        if(msg.sender != owner) revert NotAuthorized();
        if(newOwner == address(0)) revert InvalidAddress();
        owner = newOwner;
    }

    function transfer(address _to, uint _amount) external returns(bool) {
        if (_amount == 0) {revert AmountZero();}
        if (balanceOf[msg.sender] < _amount) revert InsufficientBalance(balanceOf[msg.sender],_amount);
        balanceOf[msg.sender] -= _amount;
        balanceOf[_to] += _amount;
        creditRecord[msg.sender] += 1;
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    function approve(address _spender, uint _amount) external returns(bool) {
        if (_amount == 0) {revert AmountZero();}
        allowance[msg.sender][_spender] += _amount;
        emit AllowanceStatus(msg.sender, _spender, _amount, "Increased");
        return true;
    }

    function decreaseAllowance(address _spender, uint _amount) external returns(bool) {
        if (_amount == 0) {revert AmountZero();}
        if (allowance[msg.sender][_spender] < _amount) {revert InsufficientBalance(allowance[msg.sender][_spender],_amount);}
        allowance[msg.sender][_spender] -= _amount;
        emit AllowanceStatus(msg.sender, _spender, _amount, "Decreased");
        return true;
    }

    function transferFrom(address _from, address _to, uint _amount) external returns(bool) {
        if (_amount == 0) {revert AmountZero();}
        if (balanceOf[_from] < _amount) revert InsufficientBalance(balanceOf[_from],_amount);
        if (allowance[_from][msg.sender] < _amount) revert InsufficientBalance(allowance[_from][msg.sender], _amount);
        allowance[_from][msg.sender] -= _amount;
        balanceOf[_from] -= _amount;
        balanceOf[_to] += _amount;
        creditRecord[_from] += 1;
        emit Transfer(_from, _to, _amount);
        return true;
    }

    function burn(uint _amount) external returns(bool) {
        if(msg.sender != owner) revert NotAuthorized();
        if (_amount == 0) {revert AmountZero();}
        if (balanceOf[owner] < _amount) revert InsufficientBalance(balanceOf[owner], _amount);
        balanceOf[owner] -= _amount;
        totalSupply -= _amount;
        emit SupplyChanged(_amount, "Burn");
        return true;
    }

    function mint(uint _amount) external returns(bool) {
        if(msg.sender != owner) revert NotAuthorized();
        if (_amount== 0) {revert AmountZero();}
        balanceOf[owner] += _amount;
        totalSupply += _amount;
        emit SupplyChanged(_amount, "Mint");
        return true;
    }

    function getAnyonesBalance(address user) external view returns(uint) {
        if(msg.sender != owner) revert NotAuthorized();
        return balanceOf[user];
    }

    function getBalance() external view returns(uint) {
        return balanceOf[msg.sender];
    }

    function getAllowances(address spender) external view returns(uint) {
        return allowance[msg.sender][spender];
    }

    function getCreditRecord(address user) external view returns(uint) {
        return creditRecord[user];
    }

    function getdecimals() external pure returns (uint8) {
        return 18;
    }

}
