// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Auth {
    address public _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address initialOwner) {
        _owner = initialOwner;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "UAuth: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "UAuth: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
