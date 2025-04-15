/*6.Timelocked Admin Control
A contract where an admin change can only be proposed and executed after a specific timestamp
 (like Safe’s Timelock). Use modifiers, enums, and access roles.
*/
// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract MyContract {
    address public admin;
    uint public votersCount;
    uint public adminLockedTime;
    uint public candidateID;
    uint public votingTime;
    uint public voteRequired = 5;

    enum Status {
        pending,
        active,
        rejected
    }

    struct Candidate {
        address candidateAddr;
        uint voteCount;
        Status status;
    }

    mapping(address => bool) public votersList;
    mapping(uint => mapping(address => bool)) public hasVoted;
    mapping(uint => Candidate) public candidate;

    event VotersAdded(address indexed votersAddr, uint votersID);
    event VotersRemoved(address indexed votersAddr);
    event Voted(address indexed voter, uint ID);
    event Proposal(address indexed newAdmin);
    event adminChanged(address indexed newAdmin, uint ID);
    event adminRejected(address indexed newAdmin, uint voteCounts, uint ID);

    constructor() {
        admin = msg.sender;
        adminLockedTime = block.timestamp + 120 seconds;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not Authorized");
        _;
    }

    modifier onlyVoter() {
        require(votersList[msg.sender], "Not Authorized");
        _;
    }

    modifier onlyAfter() {
        require(block.timestamp >= adminLockedTime, "Locked time still active");
        _;
    }

    function addVoter(address votersAddr) public onlyAdmin {
        require(!votersList[votersAddr], "Already exist");
        votersList[votersAddr] = true;
        emit VotersAdded(votersAddr, votersCount);
        votersCount++;
    }

    function removeVoter(address votersAddr) public onlyAdmin {
        require(votersList[votersAddr], "Already removed or does not exist");
        votersList[votersAddr] = false;
        emit VotersRemoved(votersAddr);
    }

    function changeAdminProposal(address newAdmin) public onlyAdmin onlyAfter {
        require(block.timestamp > votingTime, "Previous proposal still active");
        Candidate storage c = candidate[candidateID];
        c.candidateAddr = newAdmin;
        c.status = Status.pending;
        votingTime = block.timestamp + 2 days;
        emit Proposal(newAdmin);
        candidateID++;
    }

    function vote(uint ID) public onlyVoter {
        require(ID < candidateID, "Candidate ID invalid");
        require(!hasVoted[ID][msg.sender], "Already voted");
        Candidate storage c = candidate[ID];
        require(c.status == Status.pending, "Result alreaady declared");
        require(voteRequired > c.voteCount, "Voting has completed");
        hasVoted[ID][msg.sender] = true;
        c.voteCount++;
        emit Voted(msg.sender, ID);
        if (c.voteCount == voteRequired && block.timestamp < votingTime) {
            admin = c.candidateAddr;
            c.status = Status.active;
            emit adminChanged(c.candidateAddr, ID);
            adminLockedTime = block.timestamp + 120 seconds;
        }

        if (c.voteCount < voteRequired && block.timestamp > votingTime) {
            c.status = Status.rejected;
            emit adminRejected(c.candidateAddr, c.voteCount, ID);
        }
    }

    function getStatus(uint ID) public view returns (Status status) {
        Candidate storage c = candidate[ID];
        return c.status;
    }

    function getAdmin() public view returns (address) {
        return admin;
    }

    function getCandidateID() public view returns (uint) {
        return candidateID;
    }

    function getVotersCount() public view returns (uint) {
        return votersCount;
    }

    function getAdminLockedTime() public view returns (uint) {
        return adminLockedTime;
    }

    function getVotingTime() public view returns (uint) {
        return votingTime;
    }

    function getVoteRequired() public view returns (uint) {
        return voteRequired;
    }

    function checkVotersList(address addr) public view returns (bool) {
        return votersList[addr];
    }

    function getHasVoted(uint ID, address addr) public view returns (bool) {
        return hasVoted[ID][addr];
    }

    function getCandidateDetails(
        uint ID
    ) public view returns (address, uint, uint) {
        require(ID < candidateID, "Candidate ID invalid");
        Candidate storage c = candidate[ID];
        return (c.candidateAddr, c.voteCount, uint(c.status));
    }

    function getAllCandidates() public view returns (uint[] memory) {
        uint[] memory ids = new uint[](candidateID);
        for (uint i = 0; i < candidateID; i++) {
            ids[i] = i;
        }
        return ids;
    }
}
