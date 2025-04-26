// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EIP1271Example {
    address public owner;

    bytes4 internal constant MAGICVALUE = 0x1626ba7e;

    constructor(address _owner) {
        owner = _owner;
    }

    function isValidSignature(
        bytes32 _hash,
        bytes memory _signature
    ) public view returns (bytes4) {
        address signer = recoverSigner(_hash, _signature);

        if (signer == owner) {
            return MAGICVALUE;
        } else {
            return 0xffffffff;
        }
    }

    function recoverSigner(
        bytes32 _hash,
        bytes memory _signature
    ) internal pure returns (address) {
        require(_signature.length == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(_signature, 32))
            s := mload(add(_signature, 64))
            v := byte(0, mload(add(_signature, 96)))
        }

        return ecrecover(_hash, v, r, s);
    }
}
