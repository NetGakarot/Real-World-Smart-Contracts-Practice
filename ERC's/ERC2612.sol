//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "./EIP712.sol";

contract EIP2612 is EIP712 {

    string public _name = "Gakarot";
    string public symbol = "$Gak";
    uint8 public decimals = 18;
    uint public totalSupply;

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value );
    event Approval(address indexed from, address indexed spender, uint256 value);

    constructor(uint _initialSupply) EIP712("GakarotToken", "1") {
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

    function permit(address owner,address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) public returns(bool) {
        require(verifySignature(owner, spender, value, deadline, v, r, s),"Invalid signature");
        nonces[owner]++;
        return true;
    }

    function approve(address _spender, uint _value, uint _deadline, uint8 v, bytes32 r, bytes32 s) public returns(bool) {
        require(_value > 0, "Zero value not allowed");
        require(permit(msg.sender, _spender, _value, _deadline, v, r, s), "Permit failed");
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
