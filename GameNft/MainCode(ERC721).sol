// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

/*15.Game Asset Manager (NFT)
Game NFTs are mintable by game engine. Players can transfer. Use interface + external contract
 calls to transfer or check metadata.
*/

interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 _tokenId, bytes calldata data) external returns (bytes4);
}

contract MyContract {
    string public name = "Gakarot";
    string public symbol = "Gak";

    address public admin;
    uint public totalSupply;

    mapping(uint => address) private owners;
    mapping(address => uint) private balances;
    mapping(uint => string) private tokenURIs;
    mapping(uint => address) public tokenApprovals;
    mapping(address => mapping(address => bool)) public approvedForAll;
    
    event Transfer(address indexed from, address indexed to, uint indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    constructor() {
        admin = msg.sender;
    }

    modifier onlyBy() {
        require(msg.sender == admin,"Not authorized");
        _;
    }

    function changeAdmin(address newAdmin) public onlyBy {
        require(newAdmin != address(0),"Invalid address");
        admin = newAdmin;
    }

    function mint(address to, string memory tokenURI) external onlyBy {
        require(to != address(0), "Invalid address");

        totalSupply++;
        uint tokenId = totalSupply;

        owners[tokenId] = to;
        balances[to]++;
        tokenURIs[tokenId] = tokenURI;

        emit Transfer(address(0), to, tokenId);
    }

    function burn(uint tokenId) external onlyBy {

        address owner = owners[tokenId];
        delete owners[tokenId];
        balances[owner]--;
        delete tokenURIs[tokenId];
        emit Transfer(owner, address(0), tokenId);
    }

    function getOwnerOf(uint tokenId) external view returns (address) {
        require(owners[tokenId] != address(0), "Token doesn't exist");
        return owners[tokenId];
    }

    function getTokenURI(uint tokenId) external view returns (string memory) {
        require(owners[tokenId] != address(0), "Token doesn't exist");
        return tokenURIs[tokenId];
    }

    function transfer(address to, uint tokenId) external {
        require(owners[tokenId] == msg.sender, "Not the owner");
        require(to != address(0), "Invalid recipient");

        owners[tokenId] = to;
        balances[msg.sender]--;
        balances[to]++;
        emit Transfer(msg.sender, to, tokenId);
    }

    function approve(address operator, uint tokenId) external {
        require(owners[tokenId] == msg.sender,"Not the owner");
        require(operator != owners[tokenId],"Cant approve yourself");
        tokenApprovals[tokenId] = operator;
        emit Approval(msg.sender, operator, tokenId);
    }

    function getApproved(uint256 tokenId) external view returns (address) {
        return tokenApprovals[tokenId];
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        require(_operator != msg.sender, "Cannot approve yourself");
        approvedForAll[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return approvedForAll[_owner][_operator];
    }

    function transferFrom(address _from, address _to, uint256 tokenId) external {
        require(tokenApprovals[tokenId] == msg.sender || approvedForAll[_from][msg.sender],"Not authorized");
        require(owners[tokenId] == _from, "Incorrect from");
        require(_to != address(0), "Cannot transfer to zero address");
        delete tokenApprovals[tokenId];
        owners[tokenId] = _to;
        balances[_from]--;
        balances[_to]++;
        emit Transfer(_from, _to, tokenId);
    }

    function isContract(address _addr) internal view returns (bool) {
        uint32 size;
        assembly {
        size := extcodesize(_addr)
        }
        return (size > 0);
    }


    function safeTransferFrom(address _from, address _to, uint256 tokenId) external {
        require(tokenApprovals[tokenId] == msg.sender || approvedForAll[_from][msg.sender],"Not authorized");
        require(owners[tokenId] == _from, "Incorrect from");
        require(_to != address(0), "Cannot transfer to zero address");
        if (isContract(_to)) {
            try IERC721Receiver(_to).onERC721Received(msg.sender, _from, tokenId, "") returns (bytes4 retval) {
            require(retval == IERC721Receiver(_to).onERC721Received.selector, "Receiver not implemented properly");
        } catch {
        revert("Receiver contract can't handle NFTs");
        }

        delete tokenApprovals[tokenId];
        owners[tokenId] = _to;
        balances[_from]--;
        balances[_to]++;
        emit Transfer(_from, _to, tokenId);
        }

    }

    function changeURI(uint tokenId, string memory newTokenURI) external {
            require(owners[tokenId] == msg.sender,"Not the owner");
            tokenURIs[tokenId] = newTokenURI;
    }
}





