// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleNFTWithRoyalty {
    address public owner;
    uint96 public royaltyFeesInBips;
    
    mapping(uint256 => address) public creators;

    constructor(uint96 _royaltyFeesInBips) {
        owner = msg.sender;
        royaltyFeesInBips = _royaltyFeesInBips;
    }

    function mint(uint256 tokenId) external {
        creators[tokenId] = msg.sender;
    }

    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) external view returns (address receiver, uint256 royaltyAmount) {
        receiver = creators[_tokenId];
        royaltyAmount = (_salePrice * royaltyFeesInBips) / 10000;
    }
}
