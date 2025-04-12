/*1.Two-Level DAO Voting System
Parent DAO can create Sub-DAOs. Each Sub-DAO has its own candidates and voters. Allow parent
DAO to override any Sub-DAO result. Use contract inheritance, interface, and struct-mapping nesting.
*/

// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

abstract contract DAOVoting {
    address owner;
    uint candidatesCount;

    struct Candidates {
        address candidateAddr;
        string name;
        uint voteCount;
    }

    constructor () {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender==owner);
        _;
    }

    mapping(uint => Candidates) public candidateRecord;
    mapping(address => bool) public candidateExist;
    mapping(address => bool) public hasVoted;

    event Winner(uint[] indexed ID,uint votes);
    event CandidateAdded(uint indexed ID,address indexed _candidateAddr,string _name);
    event Voted(address indexed voted, uint ID);



    function addCandidate(address _candidateAddr, string memory _name) external virtual {}
    function vote(uint ID) external virtual{}
    uint[] winners;
    function selectWinner() external virtual {}
    function getWinners() external virtual view returns (uint[] memory) {}
    function getCandidate(uint ID) external virtual view returns(address, string memory) {}
    function getCandidateCount() external virtual view returns(uint) {}
    function changeOwner(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}

contract subDao is DAOVoting {
    address public admin;

    constructor(address _admin) {
        admin = _admin;
    }

    modifier onlyAdmin() {
        require(msg.sender==admin,"Not Authorized");
        _;
    }

    function addCandidate(address _candidateAddr, string memory _name) public onlyAdmin override {
        require(!candidateExist[_candidateAddr],"Candidate already Exists");
        Candidates storage c = candidateRecord[candidatesCount];
        c.candidateAddr = _candidateAddr;
        c.name = _name;
        candidateExist[_candidateAddr] = true;
        emit CandidateAdded(candidatesCount,_candidateAddr,_name);
        candidatesCount++;
    }

    function vote(uint _ID) public override {
        require(_ID < candidatesCount,"Candidate does not Exists");
        require(!hasVoted[msg.sender],"Already voted");
        candidateRecord[_ID].voteCount++;
        hasVoted[msg.sender] = true;
        emit Voted(msg.sender, _ID);
    }

    function selectWinner() public onlyAdmin override {
        delete winners;
        uint maxVotes = 0;

        for (uint256 i = 0; i < candidatesCount; i++) {
        if (candidateRecord[i].voteCount > maxVotes) {
                maxVotes = candidateRecord[i].voteCount;
            }
        }

        for (uint256 i = 0; i < candidatesCount; i++) {
            if(candidateRecord[i].voteCount==maxVotes) {
                winners.push(i);
            } 
        }
        emit Winner(winners,maxVotes);
    }

    function getWinners() external virtual override view returns (uint[] memory) {
        return winners;
    }

    function changeAdmin(address newAdmin) public onlyAdmin {
        admin = newAdmin;
    }

    function getCandidate(uint _ID) external override view returns(address, string memory) {
        Candidates storage c = candidateRecord[_ID];
        return (c.candidateAddr,c.name);
    }

    function getCandidateCount() external override view returns(uint) {
        return candidatesCount;
    }
}

contract ParentDAO {
    address public superAdmin;
    uint public subDaoCount;

    mapping(uint => address) public subDaos;
    mapping(uint => uint[]) public overriddenWinners;

    event SubDAOCreated(uint id, address subDaoAddress);
    event WinnerOverridden(uint subDaoID, uint[] newWinners);


    constructor() {
    superAdmin = msg.sender;
    }

    modifier onlySuperAdmin() {
    require(msg.sender == superAdmin, "Not allowed");
    _;
    }

    function createSubDAO() public onlySuperAdmin {
    subDao newDAO = new subDao(msg.sender);
    subDaos[subDaoCount] = address(newDAO);
    emit SubDAOCreated(subDaoCount, address(newDAO));
    subDaoCount++;
    }

    function overrideWinner(uint subDaoID, uint[] memory newWinners) public onlySuperAdmin {
    require(subDaoID < subDaoCount, "Invalid SubDAO");
    overriddenWinners[subDaoID] = newWinners;
    emit WinnerOverridden(subDaoID, newWinners);
    }

    function getSubDaoWinner(uint subDaoID) public view returns(uint[] memory) {
    subDao d = subDao(subDaos[subDaoID]);
    return d.getWinners();
    }

    function getCandidateOfSubDao(uint subDaoID, uint ID) public view returns(address, string memory) {
    subDao d = subDao(subDaos[subDaoID]);
    return d.getCandidate(ID);
    }

    function getOverriddenWinners(uint subDaoID) public view returns(uint[] memory) {
        require(subDaoID < subDaoCount, "Invalid SubDAO");
        return overriddenWinners[subDaoID];
    }
}