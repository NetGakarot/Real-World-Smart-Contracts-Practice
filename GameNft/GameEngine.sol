// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

interface IGameNFT {
    function getTokenURI(uint tokenId) external view returns (string memory);
    function transfer(address to, uint tokenId) external;
}

contract GameEngine {

    address public admin;
    address public nftContract;

    constructor(address _nftContract) {
        nftContract = _nftContract;
        admin = msg.sender;
    }

    modifier onlyBy() {
        require(msg.sender == admin,"Not authorized");
        _;
    }

    function changeAdmin(address newAdmin) public onlyBy {
        require(newAdmin != address(0),"Invalid address");
        admin = newAdmin;
    }

    function forceTransfer(address to, uint tokenId) external {
        IGameNFT(nftContract).transfer(to,tokenId);
    }

    function getUri(uint tokenId) external view returns(string memory) {
        return IGameNFT(nftContract).getTokenURI(tokenId);
    }

}
