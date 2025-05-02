// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;



contract DiamondProxy {
    address owner;
    
    mapping(bytes4 => address) public selectorTofacets;
    mapping(address => uint) public balances;

    constructor(address _facetA, address _facetB) {
        owner = msg.sender;
        selectorTofacets[bytes4(keccak256("setA(uint256)"))] = _facetA;
        selectorTofacets[bytes4(keccak256("getA(uint256)"))] = _facetA;
        selectorTofacets[bytes4(keccak256("setB(uint256)"))] = _facetB;
        selectorTofacets[bytes4(keccak256("getB(uint256)"))] = _facetB;
    }

    modifier onlyOwner() {
        require(msg.sender == owner,"Not Authorized");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if(newOwner == address(0)) revert ("Invalid address");
        owner = newOwner;
    }

    function registerFacet(bytes4 selector, address facet) external onlyOwner {
        selectorTofacets[selector] = facet;
    }

    fallback() external payable {
        address facet = selectorTofacets[msg.sig];
        require(facet != address(0), "Facet not found");
        _delegateCall(facet);
    }

    receive() external payable {
        address facet = selectorTofacets[msg.sig];
        require(facet != address(0), "Facet not found");
        _delegateCall(facet);
    }

    function _delegateCall(address _facet) private {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), _facet, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

}
