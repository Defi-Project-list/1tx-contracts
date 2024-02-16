// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract EventLogger {
    event Execute1TxEvent(address indexed caller, uint256 indexed recipeId);

    event ActionDirectEvent(address indexed caller, string indexed logName, bytes data);

    function logExecute1TxEvent(uint256 _recipeId) public {
        emit Execute1TxEvent(msg.sender, _recipeId);
    }

    function logActionDirectEvent(string memory _logName, bytes memory _data) public {
        emit ActionDirectEvent(msg.sender, _logName, _data);
    }
}
