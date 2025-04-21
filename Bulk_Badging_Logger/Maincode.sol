// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

/*19.Event_Batching_Logger
Admin can log multiple events from different sources in one tx. Use array inputs,
 custom events, and loop safety.
*/

interface IMyToken{
    function transfer(address _to, uint _value) external returns(bool);
}

error NotAuthorized();
error InvalidAddress();
error Alreadyregistered(address user);
error OutOfbounds();


contract MyContract {

    address admin;
    address token;
    address [] userAddress;
    uint [] userAmount;

    mapping (address => bool) userRecord;

    event AddMember(address indexed _to, uint _amount);
    event TransferLogged(address _to, uint _amount);

    constructor(address _token) {
        admin = msg.sender;
        token = _token;

    }

    function changeOwner(address newAdmin) external {
        if(msg.sender != admin) revert NotAuthorized();
        if(newAdmin == address(0)) revert InvalidAddress();
        admin = newAdmin;
    }
    
    function addMember(address to, uint amount) external {
        if(msg.sender != admin) revert NotAuthorized();
        if(userRecord[to]) revert Alreadyregistered(to);
        userAddress.push(to);
        userAmount.push(amount);
        userRecord[to] = true;
        emit AddMember(to, amount);
    }

    function batchTransfer() external {
        if(msg.sender != admin) revert NotAuthorized();
        if(userAddress.length != userAmount.length) revert OutOfbounds();
        for (uint256 i = 0; i < userAddress.length; i++) {
            IMyToken(token).transfer(userAddress[i],userAmount[i]);
            emit TransferLogged(userAddress[i], userAmount[i]);
        }
    }

    function getUserStatus(address user) external view returns(bool) {
        return userRecord[user];
    }

    function getUserDetails() external view returns(address[] memory,uint[] memory) {
        return (userAddress,userAmount);
    }
}