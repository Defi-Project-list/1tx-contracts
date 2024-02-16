// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin/interfaces/IERC20Metadata.sol";
import "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IWETH.sol";

library TokenUtils {
    using SafeERC20 for IERC20;

    // avalanche fuji
    address public constant WETH_ADDR = 0x2f6179f64FFe203899600Ba26d10979B314eA13D;
    address public constant ETH_ADDR = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    function approveToken(address _tokenAddr, address _to, uint256 _amount) internal {
        if (_tokenAddr == ETH_ADDR) return;

        if (IERC20(_tokenAddr).allowance(address(this), _to) < _amount) {
            IERC20(_tokenAddr).forceApprove(_to, _amount);
        }
    }

    function revokeToken(address _tokenAddr, address _to) internal {
        if (_tokenAddr == ETH_ADDR) return;

        if (IERC20(_tokenAddr).allowance(address(this), _to) != 0) {
            IERC20(_tokenAddr).forceApprove(_to, 0);
        }
    }

    function pullTokensIfNeeded(address _token, address _from, uint256 _amount) internal returns (uint256) {
        // handle max uint amount
        if (_amount == type(uint256).max) {
            _amount = getBalance(_token, _from);
        }

        if (_from != address(0) && _from != address(this) && _token != ETH_ADDR && _amount != 0) {
            IERC20(_token).safeTransferFrom(_from, address(this), _amount);
        }

        return _amount;
    }

    function withdrawTokens(address _token, address _to, uint256 _amount) internal returns (uint256) {
        if (_amount == type(uint256).max) {
            _amount = getBalance(_token, address(this));
        }

        if (_to != address(0) && _to != address(this) && _amount != 0) {
            if (_token != ETH_ADDR) {
                IERC20(_token).safeTransfer(_to, _amount);
            } else {
                (bool success,) = _to.call{ value: _amount }("");
                require(success, "Eth send fail");
            }
        }

        return _amount;
    }

    function depositWeth(uint256 _amount) internal {
        IWETH(WETH_ADDR).deposit{ value: _amount }();
    }

    function withdrawWeth(uint256 _amount) internal {
        IWETH(WETH_ADDR).withdraw(_amount);
    }

    function getBalance(address _tokenAddr, address _acc) internal view returns (uint256) {
        if (_tokenAddr == ETH_ADDR) {
            return _acc.balance;
        } else {
            return IERC20(_tokenAddr).balanceOf(_acc);
        }
    }

    function getTokenDecimals(address _token) internal view returns (uint256) {
        if (_token == ETH_ADDR) return 18;

        return IERC20Metadata(_token).decimals();
    }

    function ensureETHAndWETH(address desiredToken, uint256 desiredAmount) internal {
        require(desiredToken == ETH_ADDR || desiredToken == WETH_ADDR, "Invalid address : use ETH or WETH address");

        uint256 currentWeth = IWETH(WETH_ADDR).balanceOf(address(this));
        uint256 currentEth = address(this).balance;

        uint256 total = currentWeth + currentEth;

        require(total >= desiredAmount, "Not enough total balance ( ETH + WETH )");

        if (desiredToken == WETH_ADDR) {
            if (currentWeth < desiredAmount) {
                uint256 amountToWrap = desiredAmount - currentWeth;
                IWETH(WETH_ADDR).deposit{ value: amountToWrap }();
            }
        } else {
            if (currentEth < desiredAmount) {
                uint256 amountToUnWrap = desiredAmount - currentEth;
                IWETH(WETH_ADDR).withdraw(amountToUnWrap);
            }
        }
    }
}
