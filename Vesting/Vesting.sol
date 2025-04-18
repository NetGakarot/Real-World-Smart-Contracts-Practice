// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*14.Token Vesting Contract
Employer assigns token grants with cliff and vesting schedule. Employees can claim vested tokens.
 Use math + timestamp + mapping.
*/

interface IERC20 {
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

error InsufficientBalance(uint balance, uint amount);
error AmountZero();
error NotAuthorized(address sender);
error InvalidAddress(address _address);
error Locked(uint time);
error MemberDontExists(address sender);
error WithdrawalPaused();

contract Vesting {
    address public owner;
    address public token;
    uint public cliff = 365 days;
    uint public vestingPeriod = 1095 days;

    event AddMember(address indexed member, uint _Lockedtime, uint time);
    event RemoveMember(address indexed member, uint time);
    event Withdraw(address indexed sender, uint amount);
    event StatusRecord(address indexed sender, uint status, uint time);

    mapping(address => bool) public teamMemberRecord;
    mapping(address => teamRecord) public teamDetails;

    enum Status {
        paused,
        active
    }
    Status status;

    struct teamRecord {
        address _address;
        uint amount;
        uint fixedLockedTime;
        uint nextClaimTime;
        uint amountLeft;
        uint claimAmount;
    }

    constructor(address _token) {
        owner = msg.sender;
        token = _token;
    }

    function changeOwner(address newOwner) public {
        if (msg.sender != owner) revert NotAuthorized(msg.sender);
        if (newOwner == address(0)) revert InvalidAddress(address(0));
        owner = newOwner;
    }

    function addMember(address _member, uint _amount) public {
        if (msg.sender != owner) revert NotAuthorized(msg.sender);
        teamMemberRecord[_member] = true;
        teamRecord storage t = teamDetails[_member];
        t._address = _member;
        t.amount = _amount;
        t.amountLeft = _amount;
        t.nextClaimTime = block.timestamp + cliff;
        t.claimAmount = (_amount * 100) / 36; // 36 months vesting = ~2.77% monthly unlock
        emit AddMember(_member, t.fixedLockedTime, block.timestamp);
    }

    function removeMember(address _member) public {
        if (msg.sender != owner) revert NotAuthorized(msg.sender);
        teamMemberRecord[_member] = false;
        teamRecord storage t = teamDetails[_member];
        t.amount = 0;
        emit RemoveMember(_member, block.timestamp);
    }

    function withdraw() public {
        if (status == Status.paused) revert WithdrawalPaused();
        if (!teamMemberRecord[msg.sender]) revert MemberDontExists(msg.sender);
        teamRecord storage t = teamDetails[msg.sender];
        if (block.timestamp < t.nextClaimTime) revert Locked(t.nextClaimTime);
        if (t.amountLeft == 0) revert AmountZero();
        if (t.amountLeft < t.claimAmount)
            revert InsufficientBalance(t.amountLeft, t.claimAmount);
        if (IERC20(token).balanceOf(address(this)) < t.claimAmount)
            revert InsufficientBalance(
                IERC20(token).balanceOf(address(this)),
                t.claimAmount
            );
        t.amountLeft -= t.claimAmount;
        t.nextClaimTime = block.timestamp + 30 days;
        IERC20(token).transfer(t._address, t.claimAmount);
        emit Withdraw(msg.sender, t.claimAmount);
    }

    function getMemberDetails(
        address _member
    ) public view returns (uint, uint, uint) {
        if (!teamMemberRecord[_member]) revert MemberDontExists(_member);
        teamRecord storage t = teamDetails[_member];
        return (t.amount, t.amountLeft, t.nextClaimTime);
    }

    function changeWithdrawStatus(Status _status) public {
        if (msg.sender != owner) revert NotAuthorized(msg.sender);
        status = _status;
        emit StatusRecord(msg.sender, uint(_status), block.timestamp);
    }

    function getWithdrawStatus() public view returns (uint) {
        return uint(status);
    }
}

