// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;


error AmountZero(uint amount, string note);
error NotAuthorized(address sender);
error AlreadyVoted(address sender);
error InvalidID(uint ID);
error TxCompleted(uint ID);
error InsufficientApproval();
error InsufficientBalance(string note);
error AlreadyRegistered(address _address);
error NotRegistered(address _address);
error InvalidAddress(address _address);

interface IERC20 {
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(
        address sender,
        address spender
    ) external view returns (uint256);
    function approve(address _spender, uint _value) external returns (bool);
    function transferFrom(
        address _from,
        address _to,
        uint _value
    ) external returns (bool);
}

contract MyContract {
    address public owner;
    address public token;
    uint public totalArbiter;
    uint public buyerID;
    uint public sellerID;
    address public contractAddress = address(this);

    mapping(address => bool) public arbitersList;
    mapping(uint => Proposal) public buyerProposals;
    mapping(uint => Proposal) public sellerProposals;
    mapping(uint => mapping(address => bool)) public hasVotedBuyer;
    mapping(uint => mapping(address => bool)) public hasVotedSeller;
    mapping(address => uint) public ethBalance;
    mapping(address => mapping(address => uint)) public tokenBalance;

    enum Status {
        pending,
        cleared,
        rejected
    }

    struct Proposal {
        uint amount;
        uint8 voteCount;
        address addr;
        uint expiryTime;
        Status status;
    }

    event arbiterAdded(address indexed _arbiter, string note);
    event arbiterRemoved(address indexed _arbiter, string note);
    event buyerProposalCreated(
        uint buyerID,
        uint amount,
        address indexed buyer
    );
    event sellerProposalCreated(
        uint sellerID,
        uint amountToken,
        uint amountEth,
        address indexed seller
    );
    event VoteForBuying(uint indexed buyerID, uint voteCount, Status status);
    event VoteForSelling(uint indexed sellerID, uint voteCount, Status status);
    event paymentCleared(address indexed receiver, uint amount);
    event paymentRejected(address indexed sender, uint amount);

    constructor(address tokenAddr) {
        owner = msg.sender;
        token = tokenAddr;
    }

    function changeOwner(address newOwner) public returns (bool) {
        if (newOwner == address(0)) revert InvalidAddress(address(0));
        if (msg.sender != owner) revert NotAuthorized(msg.sender);
        owner = newOwner;
        return true;
    }

    function addArbiter(address _addr) public {
        if (msg.sender != owner) revert NotAuthorized(msg.sender);
        if (arbitersList[_addr]) revert AlreadyRegistered(_addr);
        arbitersList[_addr] = true;
        emit arbiterAdded(_addr, "Added");
        totalArbiter++;
    }

    function removeArbiter(address _addr) public {
        if (msg.sender != owner) revert NotAuthorized(msg.sender);
        if (!arbitersList[_addr]) revert NotRegistered(_addr);
        arbitersList[_addr] = false;
        emit arbiterRemoved(_addr, "Removed");
    }

    function BuyerProposal(uint tokenAmount, uint ethAmount) public payable {
        if (msg.value <= 0)
            revert AmountZero(msg.value, "ETH Amount cant be zero");
        require(msg.value == ethAmount, "Insufficient funds for proposal");
        ethBalance[msg.sender] += msg.value;
        if (tokenAmount <= 0)
            revert AmountZero(tokenAmount, "Desired token amount cant be zero");
        Proposal storage b = buyerProposals[buyerID];
        b.amount = tokenAmount;
        b.status = Status.pending;
        b.addr = msg.sender;
        b.expiryTime = block.timestamp + 1 hours;
        emit buyerProposalCreated(buyerID, tokenAmount, msg.sender);
        buyerID++;
    }

    function voteForBuying(uint _buyerID) public {
        if (!arbitersList[msg.sender]) revert NotAuthorized(msg.sender);
        if (hasVotedBuyer[_buyerID][msg.sender] == true)
            revert AlreadyVoted(msg.sender);
        if (_buyerID >= buyerID) revert InvalidID(_buyerID);
        Proposal storage b = buyerProposals[_buyerID];
        if (b.status != Status.pending) revert TxCompleted(_buyerID);
        hasVotedBuyer[_buyerID][msg.sender] = true;
        b.voteCount++;

        if (b.voteCount >= 2 && b.expiryTime > block.timestamp) {
            b.status = Status.cleared;
            bool success = IERC20(token).transfer(b.addr, b.amount);
            require(success, "Transfer failed");
            emit paymentCleared(b.addr, b.amount);
            emit VoteForBuying(_buyerID, b.voteCount, b.status);
        }

        if (b.voteCount < 2 && b.expiryTime < block.timestamp) {
            b.status = Status.rejected;
            uint amount = ethBalance[b.addr];
            ethBalance[b.addr] = 0;
            (bool success, ) = b.addr.call{value: amount}("");
            require(success, "Failed");
            emit paymentRejected(b.addr, b.amount);
            emit VoteForBuying(_buyerID, b.voteCount, b.status);
        }
        
    }

    function sellerProposal(uint tokenAmount, uint amountEth) public {
        if (tokenAmount <= 0)
            revert AmountZero(tokenAmount, "Token amount cant be zero");
        if (amountEth <= 0)
            revert AmountZero(amountEth, "ETH Amount cant be zero");
        if (IERC20(token).allowance(msg.sender, contractAddress) < tokenAmount)
            revert InsufficientApproval();
        if (IERC20(token).balanceOf(msg.sender) < tokenAmount)
            revert InsufficientBalance("Sender does not have enough tokens");
        if (address(this).balance < amountEth)
            revert InsufficientBalance("Contract does not have enough ETH!");
        tokenBalance[msg.sender][contractAddress] = tokenAmount;
        Proposal storage s = sellerProposals[sellerID];
        s.amount = amountEth;
        s.status = Status.pending;
        s.addr = msg.sender;
        s.expiryTime = block.timestamp + 1 hours;
        emit sellerProposalCreated(
            sellerID,
            tokenAmount,
            amountEth,
            msg.sender
        );
        sellerID++;
    }

    function voteForSelling(uint _sellerID) public {
        if (!arbitersList[msg.sender]) revert NotAuthorized(msg.sender);
        if (hasVotedSeller[_sellerID][msg.sender] == true)
            revert AlreadyVoted(msg.sender);
        if (_sellerID >= sellerID) revert InvalidID(_sellerID);
        Proposal storage s = sellerProposals[_sellerID];
        if (s.status != Status.pending) revert TxCompleted(_sellerID);
        hasVotedSeller[_sellerID][msg.sender] = true;
        s.voteCount++;

        if (s.voteCount >= 2 && s.expiryTime > block.timestamp) {
            s.status = Status.cleared;
            if (
                IERC20(token).balanceOf(s.addr) <
                tokenBalance[s.addr][contractAddress]
            ) revert InsufficientBalance("Sender does not have enough tokens");
            IERC20(token).transferFrom(
                s.addr,
                contractAddress,
                tokenBalance[s.addr][contractAddress]
            );
            tokenBalance[s.addr][contractAddress] = 0;
            (bool success, ) = s.addr.call{value: s.amount}("");
            require(success, "Failed");
            emit paymentCleared(s.addr, s.amount);
            emit VoteForSelling(_sellerID, s.voteCount, s.status);
        }

        if (s.voteCount < 2 && s.expiryTime < block.timestamp) {
            tokenBalance[s.addr][contractAddress] = 0;
            emit paymentRejected(s.addr, s.amount);
            emit VoteForSelling(_sellerID, s.voteCount, s.status);
        }
        
    }

    fallback() external payable {
        if (msg.sender != owner) revert NotAuthorized(msg.sender);
        if (msg.value <= 0) revert AmountZero(msg.value, "Amount cant be zero");
    }
    receive() external payable {
        if (msg.sender != owner) revert NotAuthorized(msg.sender);
        if (msg.value <= 0) revert AmountZero(msg.value, "Amount cant be zero");
    }
    function deposit() public payable {
        if (msg.sender != owner) revert NotAuthorized(msg.sender);
        if (msg.value <= 0) revert AmountZero(msg.value, "Amount cant be zero");
    }

    function getSellingStatus(
        uint _sellerID
    ) public view returns (Status status) {
        if (_sellerID >= sellerID) revert InvalidID(_sellerID);
        Proposal storage s = sellerProposals[_sellerID];
        return s.status;
    }

    function getBuyingStatus(
        uint _buyerID
    ) public view returns (Status status) {
        if (_buyerID >= buyerID) revert InvalidID(_buyerID);
        Proposal storage b = buyerProposals[_buyerID];
        return b.status;
    }

    function withdrawAll() public returns (bool) {
        if (msg.sender != owner) revert NotAuthorized(msg.sender);
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "Failed");
        return true;
    }
}

