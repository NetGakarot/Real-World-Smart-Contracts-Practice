// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Proxy {
    address public logic;

    constructor(address _logic) {
        logic = _logic;
    }

    function updateLogic(address _newLogic) public {
        logic = _newLogic;
    }

    fallback() external payable {
        (bool success, ) = logic.delegatecall(msg.data);
        require(success, "Delegatecall failed");
    }

    receive() external payable {}
}
