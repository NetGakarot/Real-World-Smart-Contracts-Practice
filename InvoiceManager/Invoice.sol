//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

/*22.	On-Chain Invoice Manager
Businesses can issue invoices with hashes, track status, and mark paid. Use enums, 
struct mapping, and access control.
*/

error NotAuthorized();
error InvalidAddress();
error InvalidInvoiceNumber(uint _invoiceNumber);
error AlreadyHashed();

contract InvoiceManager {

       address owner;
       uint invoiceNumber;

    mapping(uint => Invoice) invoiceRecord;
    mapping(address => bool) allowedBusiness;
    mapping(bytes32 => bool) hashedRecord;

    event HashCreated(address indexed business, uint indexed _invoiceNumber, bytes32 hashedValue);
    event InvoiceStatus(address indexed business, Status _status);
    event BusinessAdded(address indexed business);

    enum Status {pending,paid,rejected}

    struct Invoice {
        bytes32 hashed;
        address businessAddress;
        uint time;
        Status status;
    }

    constructor() {
        owner = msg.sender;
    }

    function changeOwner(address newOwner) external {
        if(msg.sender != owner) revert NotAuthorized();
        if(newOwner == address(0)) revert InvalidAddress();
        owner = newOwner;
    }

    function addBusiness(address business) external {
        if (msg.sender != owner) revert NotAuthorized();
        if (business == address(0)) revert InvalidAddress();
        allowedBusiness[business] = true;
        emit BusinessAdded(business);
    }

    function createInvoiceHash(string memory content) external {
        if(!allowedBusiness[msg.sender]) revert NotAuthorized();
        Invoice storage i = invoiceRecord[invoiceNumber];
        i.hashed = keccak256(abi.encode(content));
        if(hashedRecord[i.hashed]) revert AlreadyHashed();
        i.businessAddress = msg.sender;
        i.status = Status.pending;
        i.time = block.timestamp;
        hashedRecord[i.hashed] = true;
        emit HashCreated(msg.sender, invoiceNumber, i.hashed);
        invoiceNumber++;
    } 

    function changeInvoiceStatus(uint _invoiceNumber, Status _status) external {
        if(_invoiceNumber >= invoiceNumber) revert InvalidInvoiceNumber(_invoiceNumber);
        if(!allowedBusiness[msg.sender]) revert NotAuthorized();
        Invoice storage i = invoiceRecord[_invoiceNumber];
        i.status = _status;
        emit InvoiceStatus(msg.sender, _status);
    }

    function getInvoiceDetails(uint _invoiceNumber) external view returns(address,bytes32,Status,uint) {
        Invoice storage i = invoiceRecord[_invoiceNumber];
        return(i.businessAddress,i.hashed,i.status,i.time);
    }
}
