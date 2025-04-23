//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract EIP712 {
    string public name;
    string public version;
    uint256 public immutable chainId;
    bytes32 public immutable DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    bytes32 internal constant PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner, address spender, uint256 value,uint256 nonce, uint256 deadline)"
        );

    constructor(string memory _name, string memory _version) {
        name = _name;
        version = _version;
        uint256 _chainId;
        assembly {
            _chainId := chainid()
        }
        chainId = _chainId;

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(name)),
                keccak256(bytes(version)),
                _chainId,
                address(this)
            )
        );
    }

    function verifySignature(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public view returns (bool) {
        require(block.timestamp <= deadline, "Signature Expired");

        bytes32 structHash = keccak256(
            abi.encode(
                PERMIT_TYPEHASH,
                owner,
                spender,
                value,
                nonces[owner],
                deadline
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash)
        );

        address recoverAddress = ecrecover(digest, v, r, s);
        return recoverAddress != address(0) && recoverAddress == owner;
    }
}
