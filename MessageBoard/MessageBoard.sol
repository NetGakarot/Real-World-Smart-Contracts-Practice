//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract MessageBoard{

    struct Message {
        address sender;
        string message;
        uint time;
    }

    Message[] public messages;

    event NewMessage(address indexed sender, string content, uint timestamp);

    function postMessage(string calldata _content) public {
        messages.push(Message({
            sender: msg.sender,
            message: _content,
            time: block.timestamp
        }));

        emit NewMessage(msg.sender, _content, block.timestamp);
    }

    function getMessageLength() public view returns(uint) {
        return messages.length;
    }

    function viewMessage(uint index) external view returns(address,string memory,uint) {
        require(index < messages.length,"Index out of bound");
        Message memory m = messages[index];
        return (m.sender,m.message,m.time);
    }

    function viewAll() public view returns(Message[] memory) {
        return messages;
    }

}