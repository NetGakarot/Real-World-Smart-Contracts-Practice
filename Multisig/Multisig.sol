/*2.	Simple Multisig Wallet
Create a wallet where multiple owners must approve before a transfer is executed.
 Use structs to track proposals and signatures. Focus on mapping(address => bool), nested logic, 
 and structs.
*/

// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract MultiSig{

    address public admin;
    uint public min_approval_required = 3;
    uint proposalID;


    mapping(address => bool) public owners_data;
    mapping(uint => Proposal) public proposals;
    

    struct Proposal {
        address to;
        uint amount;
        uint approval;
        bool executed;
        mapping(address => bool) signed;
    }

    event ProposalRecord(uint indexed proposalID, address indexed to, uint amount);
    event ApprovalDone(address indexed approver, uint proposalID);
    event ApprovalRequired(address indexed admin,uint newNum);
    event OwnersDataChange(address indexed owner, string note);
    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);


    constructor (address owner1, address owner2, address owner3, address owner4, address owner5) {
        admin = msg.sender;
        owners_data[owner1] = true;
        owners_data[owner2] = true;
        owners_data[owner3] = true;
        owners_data[owner4] = true;
        owners_data[owner5] = true;
    }

    modifier onlyBy() {
        require(msg.sender==admin,"Not authorized");
        _;
    }

    fallback() external payable {}
    receive() external payable {}
    
    function createProposal(address _to, uint _amount) public onlyBy returns(bool) {
        require(_amount <= address(this).balance,"Insufficient funds");
        Proposal storage p = proposals[proposalID];
        p.to = _to;
        p.amount = _amount;
        p.approval = 0;
        p.executed = false;
        emit ProposalRecord(proposalID, _to, _amount);
        proposalID++;
        return true;
    }

    function approve(uint _proposalID) public returns(bool) {
        require(_proposalID < proposalID, "Id not found");
        require(owners_data[msg.sender],"Not Authorized");
        Proposal storage p = proposals[_proposalID];
        require(!p.signed[msg.sender], "Already approved");
        p.signed[msg.sender] = true;
        p.approval++;
        if (p.approval >= min_approval_required && !p.executed) {
        p.executed = true;
        (bool sent, ) = p.to.call{value: p.amount}("");
        require(sent, "Transfer failed");
        }
        emit ApprovalDone(msg.sender, _proposalID);
        return true;
    }

    function changeMinimumapproval(uint approvalRequired) public onlyBy returns(bool) {
        min_approval_required = approvalRequired;
        emit ApprovalRequired(msg.sender,approvalRequired);
        return true;
        
    }

    function addOwner(address _owner) public onlyBy returns(bool) {
        require(!owners_data[_owner],"Already exists");
        owners_data[_owner] = true;
        emit OwnersDataChange(_owner, "Added");
        return true;
    }

    function removeOwner(address _owner) public onlyBy returns(bool) {
        require(owners_data[_owner],"Owner does not exist or already deleted");
        delete owners_data[_owner];
        emit OwnersDataChange(_owner, "Removed");
        return true;
    }

    function changeadmin(address _admin) public onlyBy returns(bool) {
        require(_admin!=admin,"Already a admin");
        admin = _admin;
        emit AdminChanged(admin, _admin);
        return true;
    }

    function getproposalStatus(uint _proposalID) public view returns(address,uint,uint,bool) {
        Proposal storage p = proposals[_proposalID];
        return (p.to,p.amount,p.approval,p.executed);
    }

    function getIsSigned(uint _proposalID, address user) public view onlyBy returns(bool) {
        require(_proposalID < proposalID, "Id not found");
        Proposal storage p = proposals[_proposalID];
        return p.signed[user];
    }
}




