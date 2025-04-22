// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*20.Data Provider + Consumer (Oracle-like)
A data provider contract updates price or data feeds. Consumer contract fetches this via interface.
Practice abstract contract + instance.
*/
error NotAuthorized();
error InvalidAddress();

contract Oracle {

    address owner;

    constructor() {
        owner = msg.sender;
    }

    struct PriceData {
        uint price;
        uint updatedAt;
    }

   mapping(string => PriceData) private prices;
   mapping(address => bool) private allowedUser;

   event UserStatus(address indexed user, string status);
   event PriceUpdated(string indexed symbol, uint price, uint updatedAt);

   function changeOwner(address newOwner) external {
    if(msg.sender != owner) revert NotAuthorized();
    if(newOwner == address(0)) revert InvalidAddress();
    owner = newOwner;
   }

   function addUser(address user) external {
    if(msg.sender != owner) revert NotAuthorized();
    if(user == address(0)) revert InvalidAddress();
    allowedUser[user] = true;
    emit UserStatus(user, "Added");
   }

   function removeUser(address user) external {
    if(msg.sender != owner) revert NotAuthorized();
    if(user == address(0)) revert InvalidAddress();
    allowedUser[user] = false;
    emit UserStatus(user, "Removed");
   }

   function pushPrice(string memory symbol, uint256 price) external {
    if(!allowedUser[msg.sender]) revert NotAuthorized();
    prices[symbol] = PriceData(price, block.timestamp);
   }

   function getPrice(string memory symbol) external view returns(uint, uint) {
    PriceData memory data = prices[symbol];
    return (data.price,data.updatedAt);
   }

   function getUserStatus(address user) external view returns(bool) {
    return allowedUser[user];
   }
}
