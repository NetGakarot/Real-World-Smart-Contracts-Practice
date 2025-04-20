// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

/*15.Game Asset Manager (NFT)
Game NFTs are mintable by game engine. Players can transfer. Use interface + external contract
 calls to transfer or check metadata.
*/

interface IERC721Receiver {
    function onERC721Received(address _from, address _spender, uint _tokenId, bytes calldata data) external returns(bytes4);
}

error NotAuthorized(string note);
error InvalidAddress();
error ContractAddress(string note);
error ReceiverInvalid();

contract MyERC721 {
    string public name = "Gakarot";
    string public symbol = "GKT";


    address public admin;
    uint public totalSupply;


    mapping(uint => address) private owners;
    mapping(address => uint) private balances;
    mapping(uint => string) private tokenUri;
    mapping(uint => address) private tokenApproval;
    mapping(address => mapping(address => bool)) public approvedForAll;

    event Transfer(address indexed _from, address indexed _to, uint indexed _tokenId);
    event Approval(address indexed _owner, address indexed _spender, uint indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _spender, bool approved);

    constructor() {
        admin = msg.sender;
    }

    function changeAdmin(address newAdmin) external {
        if(msg.sender != admin) revert NotAuthorized("Only Admin allowed");
        if(newAdmin == address(0)) revert InvalidAddress();
        admin = newAdmin;
    }

    function mint(address _to, string memory _tokenUri) external {
        if(msg.sender != admin) revert NotAuthorized("Only Admin allowed");

        totalSupply++;
        uint tokenId = totalSupply;

        owners[tokenId] = _to;
        balances[_to]++;
        tokenUri[tokenId] = _tokenUri;
        emit Transfer(msg.sender, _to, tokenId);
    }

    function burn(uint _tokenId) external {
        if(msg.sender != admin) revert NotAuthorized("Only Admin allowed");
        address owner = owners[_tokenId];
        delete owners[_tokenId];
        balances[owner]--;
        delete tokenUri[_tokenId];
        emit Transfer(owner, address(0), _tokenId);
    }

    function OwnerOf(uint _tokenId) external view returns(address) {
        return owners[_tokenId];
    }

    function balanceOf(address user) external view returns(uint) {
        return balances[user];
    }

    function getTokenUri(uint _tokenId) external view returns(string memory) {
        return tokenUri[_tokenId];
    }

    function changeUri(uint _tokenId, string memory _newTokenUri) external {
        if(msg.sender != admin) revert NotAuthorized("Only Admin allowed");
        tokenUri[_tokenId] = _newTokenUri; 
    }

    function isContract(address user) internal view returns(bool) {
        uint32 size;
        assembly {
            size := extcodesize(user)
        }
        return(size > 0);
    }

    function transfer(address _to, uint _tokenId) external {
        if(isContract(_to)) revert ContractAddress("Its a contract address use SafeTransferFrom");
        if(msg.sender != owners[_tokenId]) revert NotAuthorized("You do not own this NFT");
        if(_to == address(0)) revert InvalidAddress();

        owners[_tokenId] = _to;
        balances[msg.sender]--;
        balances[_to]++;
        emit Transfer(msg.sender, _to, _tokenId);
    }

    function approve(address _spender, uint _tokenId) external {
        if(msg.sender != owners[_tokenId]) revert NotAuthorized("You do not own this NFT");
        if(_spender == address(0)) revert InvalidAddress();

        tokenApproval[_tokenId] = _spender;
        emit Approval(msg.sender, _spender, _tokenId); 
    }

    function getApproved(uint _tokenId) external view returns(address) {
        return tokenApproval[_tokenId];
    }

    function setApprovalForAll(address _spender, bool _approved) external {
        if(_spender == address(0)) revert InvalidAddress();
        if(_spender == msg.sender) revert InvalidAddress();
        approvedForAll[msg.sender][_spender] = _approved;
        emit ApprovalForAll(msg.sender, _spender, _approved);
    }

    function isApprovedForAll(address _owner, address _spender) external view returns(bool) {
        return approvedForAll[_owner][_spender];
    }

    function transferFrom(address _from, address _to, uint _tokenId) external {
        if(isContract(_to)) revert ContractAddress("Its a contract address use SafeTransferFrom");
        if (
            msg.sender != owners[_tokenId] &&
            msg.sender != tokenApproval[_tokenId] &&
            !approvedForAll[_from][msg.sender]
            ) revert NotAuthorized("Not owner or approved");
        if(_to == address(0)) revert InvalidAddress();
        delete tokenApproval[_tokenId];
        owners[_tokenId] = _to;
        balances[_from]--;
        balances[_to]++;
        emit Transfer(_from, _to, _tokenId);
    }

    function safeTransferFrom(address _from, address _to, uint _tokenId) external {
        if (
            msg.sender != owners[_tokenId] &&
            msg.sender != tokenApproval[_tokenId] &&
            !approvedForAll[_from][msg.sender]
            ) revert NotAuthorized("Not owner or approved");

        if(isContract(_to)) {
            try IERC721Receiver(_to).onERC721Received(_from, msg.sender, _tokenId, "") returns(bytes4 retval)  {
            if (retval != IERC721Receiver(_to).onERC721Received.selector)
                revert ReceiverInvalid();
            } catch {
                revert("Receiver contract can't handle NFT's");
            }
        }
        delete tokenApproval[_tokenId];
        owners[_tokenId] = _to;
        balances[_from]--;
        balances[_to]++;
        emit Transfer(_from, _to, _tokenId);
    }

}





