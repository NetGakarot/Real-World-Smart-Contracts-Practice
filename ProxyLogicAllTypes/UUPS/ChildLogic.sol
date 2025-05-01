// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract Child is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    uint public value;

    function initialize(uint _value) public initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        value = _value;
    }

    function updateValue(uint _newValue) external onlyOwner {
        value = _newValue;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
