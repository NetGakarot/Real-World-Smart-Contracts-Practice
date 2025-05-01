// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract Factory {
    address public childImplementation;
    address[] public allChildren;

    event ChildCreated(address proxyAddress, uint value);

    constructor(address _childImplementation) {
        childImplementation = _childImplementation;
    }

    function createChild(uint _value) external returns (address) {
        // Encode the initializer call
        bytes memory data = abi.encodeWithSignature("initialize(uint256)", _value);

        // Create a new proxy pointing to the logic contract
        ERC1967Proxy proxy = new ERC1967Proxy(childImplementation, data);

        allChildren.push(address(proxy));
        emit ChildCreated(address(proxy), _value);

        return address(proxy);
    }

    function getAllChildren() external view returns (address[] memory) {
        return allChildren;
    }
}

