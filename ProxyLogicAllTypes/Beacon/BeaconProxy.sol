// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BeaconProxy {
    address public immutable beacon;

    constructor(address _beacon, bytes memory _data) {
        beacon = _beacon;

        if (_data.length > 0) {
            (bool success, ) = _implementation().delegatecall(_data);
            require(success, "Initialization failed");
        }
    }

    fallback() external payable {
        _delegate(_implementation());
    }

    receive() external payable {
        _delegate(_implementation());
    }

    function _implementation() internal view returns (address impl) {
        (bool success, bytes memory data) = beacon.staticcall("");
        require(success, "Beacon call failed");
        impl = abi.decode(data, (address));
    }

    function _delegate(address impl) internal {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}
