// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

interface IParent {
    function setValueA(uint _a) external;
    function setValueB(uint _b) external;
    function setValueC(uint _c) external;
    function getValueA() external view returns (uint);
    function getValueB() external view returns (uint);
    function getValueC() external view returns (uint);
    function changeOwner(address newOwner) external;
}

contract Caller {
    address admin;
    address public targetAddress;
    IParent public p;

    constructor(address _targetAddress) {
        admin = msg.sender;
        targetAddress = _targetAddress;
        p = IParent(targetAddress);
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not Authorized");
        _;
    }

    function changeAdmin(address newOwner) external onlyAdmin {
        require(newOwner != address(0), "Invalid address");
        admin = newOwner;
    }

    function setValueA(uint _a) external {
        p.setValueA(_a);
    }

    function setValueB(uint _b) external {
        p.setValueB(_b);
    }

    function setValueC(uint _c) external {
        p.setValueC(_c);
    }

    function getValueA() external view returns (uint) {
        return p.getValueA();
    }

    function getValueB() external view returns (uint) {
        return p.getValueB();
    }

    function getValueC() external view returns (uint) {
        return p.getValueC();
    }

    function changeOwner(address newOwner) external {
        p.changeOwner(newOwner);
    }
}

