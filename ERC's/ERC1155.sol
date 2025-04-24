// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

interface IERC1155Receiver {

    function onERC1155Received(address operator, address from, uint id,
         uint value, bytes calldata data) external returns(bytes4);

    function onERC1155BatchReceived(address operator, address from, uint[] calldata id,
         uint[] calldata value, bytes calldata data) external returns(bytes4);
    }

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    }

error OnlyAdmin();
error InvalidAddress();

contract ERC1155 is IERC165 {

    address admin;
    string name;
    string symbol;
    uint private nextTokenId = 1;


    mapping(uint => mapping(address => uint)) private balances;
    mapping(address => mapping(address => bool)) private operatorApprovals;
    mapping(uint => string) public tokenURIs;
    mapping(uint => uint) private supplyPerToken;


    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint id, uint amount);
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint [] ids, uint[] amount);
    event ApproveForAll(address indexed owner, address indexed operator, bool approved);
    event URI(uint indexed id, string tokenURI);

    constructor(string memory _name, string memory _symbol) {
        admin = msg.sender;
        name = _name;
        symbol = _symbol;
    }


    function changeAdmin(address newAdmin) external virtual {
        if(msg.sender != admin) revert OnlyAdmin();
        if(newAdmin == address(0)) revert InvalidAddress();
        admin = newAdmin;
    }

    function balanceOf(address account, uint id) public view returns(uint) {
        require(account != address(0), "Invalid address");
        return balances[id][account];
    }

    function getTotalSupply(uint id) external view returns(uint) {
        return supplyPerToken[id];
    }

    function getTokenURI(uint id) external view returns(string memory) {
        return tokenURIs[id];
    }

    function getNextTokenId() external view returns(uint) {
        return nextTokenId;
    }

    function batchBalanceOf(address[] memory account, uint[] memory id) external view returns(uint[] memory) {
        require(account.length == id.length, "Length mismatched data incorrect");
        uint[] memory batchBalance = new uint[](account.length);
        for (uint256 i = 0; i < account.length; i++) {
            batchBalance[i] = balanceOf(account[i], id[i]);
        }

        return batchBalance;
    }

    function setApprovalForAll(address operator,bool approved) external {
        require(operator != address(0),"Address invalid");
        require(msg.sender != operator,"Self-approved not allowed");
        operatorApprovals[msg.sender][operator] = approved;
        emit ApproveForAll(msg.sender, operator, approved);
    } 

    function isApprovedForAll(address account, address operator) public view returns(bool) {
        return operatorApprovals[account][operator];
    }

    function changeUri(uint Id, string memory _newTokenUri) external virtual {
        if(msg.sender != admin) revert OnlyAdmin();
        require(Id <= nextTokenId,"Index out of bounds");
        tokenURIs[Id] = _newTokenUri; 
        emit URI(Id, _newTokenUri);
    }

    function isContract(address user) public view returns(bool) {
        require(user != address(0),"Invalid address");
        uint size;
        assembly {
            size := extcodesize(user)
        }
        return (size > 0);
    }

    function _transfer(address from, address to, uint id, uint amount) internal {
        require(to != address(0),"Address invalid");
        require(from != address(0),"Address invalid");
        require(balances[id][from] >=amount,"Insufficient Balance");
        balances[id][from] -= amount;
        balances[id][to] += amount;

        emit TransferSingle(msg.sender, from, to, id, amount);
    }

    function safeTransferFrom(address from, address to, uint id, uint amount, bytes memory data) external {
        require(to != address(0),"Invalid address");
        require(msg.sender==from || operatorApprovals[from][msg.sender],"Not Authorized");
        require(balances[id][from] >= amount,"Insufficient balance");

        if(isContract(to)) {
            try IERC1155Receiver(to).onERC1155Received(msg.sender, from, id, amount, data) returns (bytes4 retval) {
                if (retval != IERC1155Receiver(to).onERC1155Received.selector)
                revert ("Receiver Invalid");
                } catch {
                revert("Receiver contract can't handle NFT's");
                }
        }
        _transfer(from,to,id,amount);
    }

    function safeBatchTransferFrom(address from, address to, uint[] memory id, uint[] memory amount, bytes memory data) external {
        require(to != address(0),"Invalid address");
        require(id.length == amount.length,"Length mismatch");
        require(msg.sender==from || operatorApprovals[from][msg.sender],"Not Authorized");

        if(isContract(to)) {
            try IERC1155Receiver(to).onERC1155BatchReceived(msg.sender, from, id, amount, data) returns (bytes4 retval) {
                if (retval != IERC1155Receiver(to).onERC1155BatchReceived.selector)
                revert ("Receiver Invalid");
                } catch {
                revert("Receiver contract can't handle NFT's");
                }
        }

        for (uint256 i = 0; i < id.length; i++) {
            _transfer(from,to,id[i],amount[i]);
        }
        
        emit TransferBatch(msg.sender,from,to,id,amount);
    }

    function mint(address to,uint amount, string memory uri) external {
        if(msg.sender != admin) revert OnlyAdmin();
        require(to != address(0),"Invalid address");

        uint id = nextTokenId;
        balances[id][to] += amount;
        tokenURIs[id] = uri;
        supplyPerToken[id] += amount;

        emit TransferSingle(msg.sender, address(0), to, id, amount);
        emit URI(id, uri);
        nextTokenId++;
    }

    function mintBatch(address to, uint[] memory id, uint[] memory amount, string[] memory uri) external {
        if(msg.sender != admin) revert OnlyAdmin();
        require(to != address(0),"Invalid address");
        require(id.length == amount.length && id.length == uri.length,"Length mismatch");
        require(nextTokenId < id[0], "Index out of bounds");

        for (uint256 i = 0; i < id.length; i++) {
            require(id[i] >= nextTokenId, "Token ID already used or out of order");
            balances[id[i]][to] += amount[i];
            tokenURIs[id[i]] = uri[i];
            supplyPerToken[id[i]] += amount[i];
            nextTokenId++;
        }

        emit TransferBatch(msg.sender, address(0), to, id, amount);
    }

    function burn(address from, uint id, uint amount) external {
        require(from == msg.sender || isApprovedForAll(from, msg.sender), "Not authorized");
        require(balances[id][from] >= amount, "Insufficient balance");

        balances[id][from] -= amount;
        supplyPerToken[id] -= amount;
        
        emit TransferSingle(msg.sender, from, address(0), id, amount);
    }

    function burnBatch(address from, uint[] memory id, uint[] memory amount) external {
        require(from == msg.sender || isApprovedForAll(from, msg.sender), "Not authorized");
        require(id.length == amount.length,"Length mismatch");

        for (uint i = 0; i < id.length; i++) {
            balances[id[i]][from] -= amount[i];
            supplyPerToken[id[i]] -= amount[i];
        }

        emit TransferBatch(msg.sender, from, address(0), id, amount);
    }

    bytes4 private constant _ERC1155_INTERFACE_ID = 0xd9b67a26;

    function supportsInterface(bytes4 interfaceId) public pure override returns (bool) {
        return interfaceId == _ERC1155_INTERFACE_ID;
}
    
}
    


