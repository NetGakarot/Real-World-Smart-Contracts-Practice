// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

interface IERC721Receiver {
    function onERC721Received(address _from, address _spender, uint _tokenId, bytes calldata data) external returns(bytes4);
}
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

contract ERC721NFT is IERC165 {

    error OnlyAdmin();
    error NotTheOwner();
    error InvalidAddress();
    error ContractAddress(string note);
    error ReceiverInvalid();
    error GetApproval();
    error TokenDoesNotExist();

    string name;
    string symbol;


    address public admin;
    uint public totalSupply;


    mapping(uint => address) private owners;
    mapping(address => uint) private balances;
    mapping(uint => string) private tokenURI;
    mapping(uint => address) private tokenApproval;
    mapping(address => mapping(address => bool)) private approvedForAll;

    event Transfer(address indexed _from, address indexed _to, uint indexed _tokenId);
    event Approval(address indexed _owner, address indexed _spender, uint indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _spender, bool approved);
    event Mint(address indexed to, uint indexed tokenId);
    event Burn(address indexed owner, uint indexed tokenId);
    event TokenURIChanged(uint indexed tokenId, string newUri);

    constructor(string memory _name, string memory _symbol) {
        admin = msg.sender;
        name = _name;
        symbol = _symbol;
    }

     function getName() external view returns (string memory) {
        return name;
    }

    function getSymbol() external view returns (string memory) {
        return symbol;
    }

    function changeAdmin(address newAdmin) external virtual {
        if(msg.sender != admin) revert OnlyAdmin();
        if(newAdmin == address(0)) revert InvalidAddress();
        admin = newAdmin;
    }

    function mint(address _to, string memory _tokenUri) external virtual  {
        if(_to == address(0)) revert InvalidAddress();
        if(msg.sender != admin) revert OnlyAdmin();

        totalSupply++;
        uint tokenId = totalSupply;

        owners[tokenId] = _to;
        balances[_to]++;
        tokenURI[tokenId] = _tokenUri;
        emit Mint(_to, tokenId);
    }

    function burn(uint _tokenId) external virtual {
        if(msg.sender != admin) revert OnlyAdmin();
        if (owners[_tokenId] == address(0)) revert TokenDoesNotExist();
        address owner = owners[_tokenId];
        delete owners[_tokenId];
        delete tokenApproval[_tokenId];
        balances[owner]--;
        delete tokenURI[_tokenId];
        emit Burn(owner, _tokenId);
    }

    function tokenExists(uint _tokenId) external virtual view returns(bool) {
        return owners[_tokenId] != address(0);
    }

    function ownerOf(uint _tokenId) external virtual view returns(address) {
        if (owners[_tokenId] == address(0)) revert TokenDoesNotExist();
        return owners[_tokenId];
    }

    function balanceOf(address user) external virtual view returns(uint) {
        return balances[user];
    }

    function getTokenURI(uint _tokenId) external virtual view returns(string memory) {
        if (owners[_tokenId] == address(0)) revert TokenDoesNotExist();
        return tokenURI[_tokenId];
    }

    function changeUri(uint _tokenId, string memory _newTokenUri) external virtual {
        if(msg.sender != admin) revert OnlyAdmin();
        tokenURI[_tokenId] = _newTokenUri; 
        emit TokenURIChanged(_tokenId, _newTokenUri);
    }

    function isContract(address user) internal virtual view returns(bool) {
        uint32 size;
        assembly {
            size := extcodesize(user)
        }
        return(size > 0);
    }

    function _basicTransfer(address _from, address _to, uint _tokenId) internal {
        owners[_tokenId] = _to;
        balances[_from]--;
        balances[_to]++;
        emit Transfer(_from, _to, _tokenId);
    }

    function transfer(address _to, uint _tokenId) external virtual {
        if (owners[_tokenId] == address(0)) revert TokenDoesNotExist();
        if(isContract(_to)) revert ContractAddress("Its a contract address use SafeTransferFrom");
        if(msg.sender != owners[_tokenId]) revert NotTheOwner();
        if(_to == address(0)) revert InvalidAddress();

        _basicTransfer(msg.sender, _to, _tokenId);
    }

    function approve(address _spender, uint _tokenId) external virtual {
        if (owners[_tokenId] == address(0)) revert TokenDoesNotExist();
        if(msg.sender != owners[_tokenId]) revert NotTheOwner();
        if(_spender == address(0)) revert InvalidAddress();

        tokenApproval[_tokenId] = _spender;
        emit Approval(msg.sender, _spender, _tokenId); 
    }

    function getApproved(uint _tokenId) external virtual view returns(address) {
        return tokenApproval[_tokenId];
    }

    function setApprovalForAll(address _spender, bool _approved) external virtual {
        if(_spender == address(0)) revert InvalidAddress();
        if(_spender == msg.sender) revert InvalidAddress();
        approvedForAll[msg.sender][_spender] = _approved;
        emit ApprovalForAll(msg.sender, _spender, _approved);
    }

    function isApprovedForAll(address _owner, address _spender) external virtual view returns(bool) {
        return approvedForAll[_owner][_spender];
    }

    function transferFrom(address _from, address _to, uint _tokenId) external virtual {
        if (owners[_tokenId] == address(0)) revert TokenDoesNotExist();
        if(isContract(_to)) revert ContractAddress("Its a contract address use SafeTransferFrom");
        if (
            msg.sender != owners[_tokenId] &&
            msg.sender != tokenApproval[_tokenId] &&
            !approvedForAll[_from][msg.sender]
            ) revert GetApproval();
        if(_to == address(0)) revert InvalidAddress();
        delete tokenApproval[_tokenId];
        _basicTransfer(_from, _to, _tokenId);
    }

    function _safeTransferFrom(address _from, address _to, uint _tokenId, bytes memory data) public virtual {
        if (owners[_tokenId] == address(0)) revert TokenDoesNotExist();
        if (
            msg.sender != owners[_tokenId] &&
            msg.sender != tokenApproval[_tokenId] &&
            !approvedForAll[_from][msg.sender]
            ) revert GetApproval();

        if (isContract(_to)) {
            try IERC721Receiver(_to).onERC721Received(_from, msg.sender, _tokenId, data) returns (bytes4 retval) {
                if (retval != IERC721Receiver(_to).onERC721Received.selector)
                 revert ReceiverInvalid();
            } catch {
                revert("Receiver contract can't handle NFT's");
            }
        }

        delete tokenApproval[_tokenId];
        _basicTransfer(_from, _to, _tokenId);
    }

    function safeTransferFrom(address _from, address _to, uint _tokenId) external virtual {
        _safeTransferFrom(_from, _to, _tokenId, "");
    }

    function safeTransferFrom(address _from, address _to, uint _tokenId, bytes calldata data) external virtual {
        _safeTransferFrom(_from, _to, _tokenId, data);
    }

    bytes4 private constant _ERC721_INTERFACE_ID = 0x80ac58cd;

    function supportsInterface(bytes4 interfaceId) public pure override returns (bool) {
        return interfaceId == _ERC721_INTERFACE_ID;
    }
}
