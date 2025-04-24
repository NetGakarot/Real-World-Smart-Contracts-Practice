// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleERC1820Registry {

    mapping(address => mapping(bytes32 => address)) private interfaces;

    event InterfaceImplementerSet(address indexed account, bytes32 indexed interfaceHash, address indexed implementer);

    function setInterfaceImplementer(
        address account,
        bytes32 interfaceHash,
        address implementer
    ) external {
        require(msg.sender == account, "Only the account itself can set implementer");
        interfaces[account][interfaceHash] = implementer;
        emit InterfaceImplementerSet(account, interfaceHash, implementer);
    }

    function getInterfaceImplementer(
        address account,
        bytes32 interfaceHash
    ) external view returns (address) {
        return interfaces[account][interfaceHash];
    }

    function _interfaceHash(string calldata interfaceName) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(interfaceName));
    }
}
