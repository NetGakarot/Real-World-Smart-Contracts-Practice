// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

/*8.Decentralized Notary Service
Allow registered notaries to hash and store user documents. Anyone can verify existence using hash.
 Use roles, mapping, struct, and access control.
*/

error NotaryNotRegistered(address user);
error NotaryRegistered(address user);



contract Notary {
    address public owner;
    uint public totalNotariesRegistered;

    mapping(bytes32 => bool) public hashExists;
    mapping(bytes32 => ApprovedBy) public approverRecord;
    mapping(address => bool) public notaryRegistered;
    mapping(address => uint) public notaryDocCount;


    struct ApprovedBy {
        address notariser;
        uint time;
    }

    event Register(address indexed _user,string note);
    event Remove(address indexed _user, string note);
    event HashGenerated(address indexed approver,bytes32 indexed _hash);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender==owner,"Not Authorized");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0),"New owner passed is not valid");
        owner = newOwner;
    }

    function registerNotary(address user) public onlyOwner {
        if (notaryRegistered[user]) revert NotaryRegistered(user);
        notaryRegistered[user] = true;
        totalNotariesRegistered++;
        emit Register(user , "Registered");

    }

    function removeNotary(address user) public onlyOwner {
        if (!notaryRegistered[user]) revert NotaryNotRegistered(user);
        notaryRegistered[user] = false;
        emit Remove(user,"Removed");
    }

    function hashGeneration(string memory docName,string memory docContent) public {
        if (!notaryRegistered[msg.sender]) revert NotaryNotRegistered(msg.sender);
        bytes32 hashed = keccak256(abi.encode(docName,docContent));
        require(!hashExists[hashed],"Document already hashed");
        hashExists[hashed] = true;
        ApprovedBy storage data = approverRecord[hashed];
        data.notariser = msg.sender;
        data.time = block.timestamp;
        notaryDocCount[msg.sender]++;
        emit HashGenerated(msg.sender, hashed);
    }

    function totalNotariser() public view returns(uint) {
        return totalNotariesRegistered;
    }

    function getHash(string memory docName, string memory docContent) public pure returns (bytes32) {
    return keccak256(abi.encode(docName, docContent));
    }

    function hashVerification(bytes32 _hash) public view returns(bool) {
        return hashExists[_hash];
    }

    function getApprovedBy(bytes32 _hash) public view returns(address,uint) {
        require(hashExists[_hash],"Hash does not exist");
        ApprovedBy memory data = approverRecord[_hash];
        return (data.notariser,data.time);
    }

    function isNotary(address user) public view returns(bool) {
        return notaryRegistered[user];
    }

    function getNotaryDocCount(address user) public view returns(uint) {
        return notaryDocCount[user];
    }
}
