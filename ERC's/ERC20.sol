// SPDX-License-Identifier:MIT
pragma solidity  ^0.8.0;

contract MyToken {

    string public name = "Gakarot";
    string public symbol = "$Gak";
    uint8 public decimals = 18;
    uint public totalSupply;

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value );
    event Approval(address indexed from, address indexed spender, uint256 value);

    constructor(uint _initialSupply) {
        totalSupply = _initialSupply * 10 ** uint(decimals);
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint _amount) public returns(bool) {
        require(_amount > 0, "Zero value not allowed");
        require(balanceOf[msg.sender] >= _amount,"Insufficient Funds");
        balanceOf[msg.sender] -= _amount;
        balanceOf[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
        return true;    
    }

    function approve(address _spender, uint _value) public returns(bool) {
        require(_value > 0, "Zero value not allowed");
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint _amount) public returns(bool) {
        require(_amount > 0, "Zero value not allowed");
        require(balanceOf[_from] >= _amount,"Insufficient Funds");
        require(allowance[_from][msg.sender] >= _amount,"Allowance Exceeded");
        balanceOf[_from] -= _amount;
        allowance[_from][msg.sender] -= _amount;
        balanceOf[_to] += _amount;
        emit Transfer(_from, _to, _amount);
        return true;
    }

}
