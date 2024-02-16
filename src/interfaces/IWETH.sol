// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin/interfaces/IERC20.sol";
import "openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";

abstract contract IWETH {
    function allowance(address, address) public view virtual returns (uint256);

    function balanceOf(address) public view virtual returns (uint256);

    function approve(address, uint256) public virtual;

    function transfer(address, uint256) public virtual returns (bool);

    function transferFrom(address, address, uint256) public virtual returns (bool);

    function deposit() public payable virtual;

    function withdraw(uint256) public virtual;
}
