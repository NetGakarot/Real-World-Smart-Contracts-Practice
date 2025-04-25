// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


contract MyERC165 {

    mapping(bytes4 => bool) private _supportedInterfaces;


    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "Invalid interfaceId");
        _supportedInterfaces[interfaceId] = true;
    }


    function supportsInterface(bytes4 interfaceId) external view virtual returns (bool) {
        return _supportedInterfaces[interfaceId];
    }
}
