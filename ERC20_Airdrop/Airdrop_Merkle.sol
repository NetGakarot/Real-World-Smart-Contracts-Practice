// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

interface IERC20 {
    function transfer(address to, uint amount) external returns (bool);
    function balanceOf(address account) external view returns (uint);
}

contract MerkleAirdrop {
    address public owner;
    address public tokenAddr;
    bytes32 public merkleRoot;

    mapping(address => bool) public hasClaimed;

    event Claimed(address indexed user, uint amount);

    constructor(address _tokenAddr, bytes32 _merkleRoot) {
        owner = msg.sender;
        tokenAddr = _tokenAddr;
        merkleRoot = _merkleRoot;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0),"Address passed is not valid");
        owner = newOwner;
    }

    function claim(uint amount, bytes32[] calldata proof) external {
        require(!hasClaimed[msg.sender], "Already claimed");

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, amount));

        require(MerkleProof.verify(proof, merkleRoot, leaf), "Invalid proof");

        hasClaimed[msg.sender] = true;
        IERC20(tokenAddr).transfer(msg.sender, amount);

        emit Claimed(msg.sender, amount);
    }

    function updateRoot(bytes32 newRoot) external onlyOwner {
        merkleRoot = newRoot;
    }
}
