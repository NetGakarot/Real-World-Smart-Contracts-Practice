// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract Certificates {

    address public owner;

    struct Certificate {
        string name;
        bytes32 cHash;
        uint timestamp;
    }

    mapping(bytes32 => Certificate) internal certificates;

    event CertificateIssued(string name, bytes32 certHash, uint timestamp);

    constructor () {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender==owner,"Not Authorized");
        _;
    }

    function issueCertificate(string calldata _name, string calldata certData) public onlyOwner {
       bytes32 certHash = keccak256(abi.encodePacked(_name,certData,block.timestamp));
       certificates[certHash] = Certificate(_name,certHash,block.timestamp);
       emit CertificateIssued(_name, certHash, block.timestamp);
    }

    function verifyCertificate(bytes32 _certHash) public view returns(string memory) {
        require(_certHash==certificates[_certHash].cHash,"Certificate not issued");
        return "Certificate issued";
    }
}