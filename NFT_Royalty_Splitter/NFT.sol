/*3.	NFT Royalty Splitter
Upon receiving payment (via payable), distribute Ether to multiple artists based on predefined
 royalty share. Use structs, enums, and nested mapping.
*/


// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

error AmountZero();
error ArtistIDNotFound(uint _artistID, uint artistID);

contract NFT {

    address owner;
    uint artistID;
    uint totalShares = 100;
    uint remainingShare;

    enum RoyaltyStatus {Pending,Active,Paused,Completed}

    mapping(uint => RoyaltyDetails) public royaltyRecord;
    mapping(address => bool) artistRecord;
    mapping(address => uint) ethRecord;

    event Artist(address indexed,uint share,uint status,uint artistID);
    event Status(uint indexed artistID, uint newStatus);
    event Withdraw(address indexed caller,uint amount);

    struct RoyaltyDetails {

        address payable recipient;
        uint share;
        RoyaltyStatus status; 
    }

    constructor() {
        owner = msg.sender;
    }

    modifier onlyBy() {
        require(msg.sender==owner,"Not Authorized");
        _;
    }

    function addartist(address payable _artist, uint _share) public onlyBy {
        require(!artistRecord[_artist],"Already registered");
        RoyaltyDetails storage R = royaltyRecord[artistID];
        require((remainingShare +  _share) <= totalShares,"Share exceeding the totalShares threshold");
        R.recipient = _artist;
        R.status = RoyaltyStatus(1);
        R.share = _share;
        remainingShare += _share;
        artistRecord[_artist] = true;
        emit Artist(_artist,_share,uint(R.status),artistID);
        artistID++;
    }

    function changeStatus(uint _artistID, RoyaltyStatus newStatus) public onlyBy {
        if(_artistID >= artistID) revert ArtistIDNotFound(_artistID,artistID);
        RoyaltyDetails storage R = royaltyRecord[_artistID];
        R.status = newStatus;
        emit Status(_artistID, uint(newStatus));
    }

    function distributeRoyalty() private returns(bool)  {
        
        for (uint256 index = 0; index < artistID; index++) {
            RoyaltyDetails storage R = royaltyRecord[index];
            if(R.status == RoyaltyStatus.Active) {
                uint amount = (msg.value * R.share)/100;
                ethRecord[R.recipient] += amount; 
            }
            
        }
        return true;
    }

    function deposit() public payable {
        if(msg.value==0) revert AmountZero();
        distributeRoyalty();

    }

    fallback() external payable {
        if(msg.value==0) revert AmountZero();
        distributeRoyalty();
    }

    receive() external payable {
        if(msg.value==0) revert AmountZero();
        distributeRoyalty();
    }

    function withdraw(uint _artistID) public payable {
        require(artistRecord[msg.sender],"Not Authorized");
        if(_artistID >= artistID) revert ArtistIDNotFound(_artistID,artistID);
        RoyaltyDetails storage R = royaltyRecord[_artistID];
        require(msg.sender==R.recipient,"ID do not match with address");
        uint amount = ethRecord[msg.sender];
        if(amount==0) revert AmountZero();
        require(address(this).balance >= amount,"Insufficient funds in contract");
        ethRecord[msg.sender] = 0;
        (bool success, ) = R.recipient.call{value:amount}("");
        require(success,"Failed");
        emit Withdraw(msg.sender, amount);
    }


    function getArtist(uint _artistID) public view returns(address,uint,uint) {
        if(_artistID >= artistID) revert ArtistIDNotFound(_artistID,artistID);
        RoyaltyDetails storage R = royaltyRecord[_artistID];
        return(R.recipient,uint(R.share),uint(R.status));
    }

    function getBalance() public view returns(uint) {
        return ethRecord[msg.sender];
    }

    function getRemainingShare() public view onlyBy returns(uint) {
        return remainingShare;
    }

    function changeOwner(address newOwner) public onlyBy returns(bool) {
        owner = newOwner;
        return true;
    }

    function selfDestruct() public onlyBy  {
        (bool success, ) = owner.call{value:address(this).balance}("");
        require(success,"Failed!");
    }

    function getAllBalances() public view onlyBy returns(address[] memory recipients, uint[] memory balances) {
    recipients = new address[](artistID);
    balances = new uint[](artistID);
    for (uint i = 0; i < artistID; i++) {
        RoyaltyDetails storage r = royaltyRecord[i];
        recipients[i] = r.recipient;
        balances[i] = ethRecord[r.recipient];
        }
    }

}