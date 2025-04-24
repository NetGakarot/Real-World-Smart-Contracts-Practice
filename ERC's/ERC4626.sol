// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

}

contract MyERC4626Vault {
    IERC20 public immutable asset;

    string public name = "GakVault Token";
    string public symbol = "vGkt";
    uint8 public decimals = 18;

    uint256 public totalAssets;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    constructor(address _asset) {
        asset = IERC20(_asset);
    }

    // Core ERC4626-like functions below -->


    function deposit(uint256 assets, address receiver) external returns (uint256 shares) {
        require(assets > 0, "Zero deposit");

        shares = convertToShares(assets);
        require(shares > 0, "Zero shares");

        totalAssets += assets;
        totalSupply += shares;
        balanceOf[receiver] += shares;

        require(asset.transferFrom(msg.sender, address(this), assets), "Transfer failed");
    }

    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares) {
        require(assets > 0, "Zero withdraw");

        shares = convertToShares(assets);
        require(balanceOf[owner] >= shares, "Insufficient shares");

        if (msg.sender != owner) revert("Not owner");

        balanceOf[owner] -= shares;
        totalSupply -= shares;
        totalAssets -= assets;

        require(asset.transfer(receiver, assets), "Transfer failed");
    }

    function mint(uint256 shares, address receiver) external returns (uint256 assets) {
        require(shares > 0, "Zero mint");

        assets = convertToAssets(shares);
        require(assets > 0, "Zero assets");

        totalAssets += assets;
        totalSupply += shares;
        balanceOf[receiver] += shares;

        require(asset.transferFrom(msg.sender, address(this), assets), "Transfer failed");
    }

    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets) {
        require(shares > 0, "Zero redeem");
        require(balanceOf[owner] >= shares, "Not enough shares");

        if (msg.sender != owner) revert("Not owner");

        assets = convertToAssets(shares);

        balanceOf[owner] -= shares;
        totalSupply -= shares;
        totalAssets -= assets;

        require(asset.transfer(receiver, assets), "Transfer failed");
    }

    // -----------------------------------
    // View Helpers
    // -----------------------------------

    function convertToShares(uint256 assets) public view returns (uint256) {
        return totalAssets == 0 || totalSupply == 0
            ? assets
            : (assets * totalSupply) / totalAssets;
    }

    function convertToAssets(uint256 shares) public view returns (uint256) {
        return totalSupply == 0 || totalAssets == 0
            ? shares
            : (shares * totalAssets) / totalSupply;
    }

    function previewDeposit(uint256 assets) external view returns (uint256) {
        return convertToShares(assets);
    }

    function previewWithdraw(uint256 assets) external view returns (uint256) {
        return convertToShares(assets);
    }

    function previewMint(uint256 shares) external view returns (uint256) {
        return convertToAssets(shares);
    }

    function previewRedeem(uint256 shares) external view returns (uint256) {
        return convertToAssets(shares);
    }

    function totalAssetsInVault() external view returns (uint256) {
        return totalAssets;
    }
}
