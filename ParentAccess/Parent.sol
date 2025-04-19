
// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

/*16.Parent Contract Accessor
One contract stores data. Another contract fetches and modifies it via interface.
Use instance + call + interface.
*/

contract Parent {
    address public owner;

    uint a;
    uint b;
    uint c;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyBy() {
        require(msg.sender==owner,"Not Authorized");
        _;
    }

    function changeOwner(address newOwner) external onlyBy {
        require(newOwner != address(0),"Invalid address");
        owner = newOwner;
    }

    function setValueA(uint _a) external {
        a = _a;
    }
    
    function setValueB(uint _b) external {
        b = _b;
    }

    function setValueC(uint _c) external {
        c = _c;
    }

    function getValueA() external view returns (uint) {
        return a;
    }

    function getValueB() external view returns (uint) {
        return b;
    }

    function getValueC() external view returns (uint) {
        return c;
    }
}
