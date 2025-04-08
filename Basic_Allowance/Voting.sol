// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract Voting {

    struct Candidates {
        string name;
        uint voteCount;
    }

    event Winner(uint[] indexed ID, string[] name, uint votes);

    mapping(uint => Candidates) public candidates;
    mapping(address => bool) public hasVoted;

    uint public candidatesCount;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender==owner,"Not authorized");
        _;
    }

    function addCandidate(string memory _name) public onlyOwner {
        candidates[candidatesCount] = Candidates(_name,0);
        candidatesCount++;
    }

    function vote(uint _candidateID) public {
        require(!hasVoted[msg.sender],"Already Voted");
        require(_candidateID < candidatesCount,"Invalid ID");
        candidates[_candidateID].voteCount++;
        hasVoted[msg.sender] = true;
    }

    uint[] winners;
    function selectWinner() public onlyOwner {
        
        uint maxVotes = 0;


        for (uint i = 0; i < candidatesCount; i++) {
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
            }
        }

        for (uint i = 0; i < candidatesCount;i++) {
            if (candidates[i].voteCount==maxVotes) {
                winners.push(i);
            }
        }
        
    }

    function getWinners() public view returns (uint[] memory) {
    return winners;
    }

}