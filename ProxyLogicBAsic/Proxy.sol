// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Proxy {
    uint256 public num;
    address public sender;
    uint public value;

    // Fallback function: This will delegate calls to the logic contract
    function setVars(address _logicContract, uint _num) public payable {
        (bool success, bytes memory data) = _logicContract.delegatecall(abi.encodeWithSignature("setVars(uint256)", _num));
        require(success, "Delegatecall failed");
    }

}
