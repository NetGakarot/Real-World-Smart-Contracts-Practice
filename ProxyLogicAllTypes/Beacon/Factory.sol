// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BeaconProxy.sol"; // Ensure path is correct

contract Factory {
    address public immutable beacon;
    address[] public children;

    constructor(address _beacon) {
        beacon = _beacon;
    }

    function createChild(uint _value) external returns (address proxy) {
        bytes memory initData = abi.encodeWithSignature("initialize(uint256)", _value);
        proxy = address(new BeaconProxy(beacon, initData));
        children.push(proxy);
    }

    function getAllChildren() external view returns (address[] memory) {
        return children;
    }
}
