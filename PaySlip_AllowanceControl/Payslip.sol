// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

/*7.Payment Split + Allowance Control
Users can deposit Ether, but owner can assign custom withdrawal allowances to specific users.
Users withdraw under that limit. Combine allowance wallet and payable vault.
*/

contract MyContract {
    address owner;

    mapping(address => uint) public balanceOf;
    mapping(address => uint) public withdrawAllowed;
    mapping(address => uint) public totalBalanceWithdrawn;

    event Deposit(address sender, uint _amount);
    event limitAllowed(address user, uint _amount,string note);
    event withdrawn(address user, uint _amount);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender==owner,"Not Authorized");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid new owner");
        owner = newOwner;
    }

    function _deposit() internal {
        require(msg.value > 0,"Amount cant be zero");
        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
        }

    fallback() external payable {_deposit();}

    receive() external payable {_deposit();}

    function deposit() public payable {_deposit();}

    function incLimit(address user, uint amount) public onlyOwner {
            require(amount > 0,"Amount cant be zero");
            withdrawAllowed[user] += amount;
            emit limitAllowed(user, amount, "Increased");
    }

    function decLimit(address user, uint amount) public onlyOwner {
            require(withdrawAllowed[user] >= amount, "Underflow not allowed");
            require(amount > 0,"Amount cant be zero");
            withdrawAllowed[user] -= amount;
            emit limitAllowed(user, amount,"Decreased");
    }

    function withdraw(uint amount) public {
        require(amount > 0,"Amount cant be zero");
        require(withdrawAllowed[msg.sender] >= amount,"Amount requested is not allowed, Contact admin");
        withdrawAllowed[msg.sender] -= amount;
        totalBalanceWithdrawn[msg.sender] += amount;
        (bool success, ) = msg.sender.call{value:amount}("");
        require(success,"Failed");
        emit withdrawn(msg.sender, amount);
    }

    function getBalance() public view returns(uint) {
        return balanceOf[msg.sender];
    }

    function getLimitAllowed() public view returns(uint) {
        return withdrawAllowed[msg.sender];
    }

    function getOwner() public view returns(address) {
        return owner;
    }

    function getContractBalance() public view returns(uint) {
        return address(this).balance;
    }

    function totalBalancedata(address user) public view returns(int) {
        return int(balanceOf[user] - totalBalanceWithdrawn[user]);
    }
}
