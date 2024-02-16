// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ActionBase } from "../../ActionBase.sol";
import { UniV2Helper } from "./helpers/UniV2Helper.sol";
import { TokenUtils } from "../../../utils/TokenUtils.sol";
import { Constants } from "../../../utils/Constants.sol";
import { IERC20 } from "openzeppelin/interfaces/IERC20.sol";

contract UniswapV2ExactOut is Constants, ActionBase, UniV2Helper {
    using TokenUtils for address;

    struct Params {
        uint256 amountOut;
        uint256 amountInMax;
        address to;
        address[] path;
        uint256 deadline;
    }

    function executeAction(
        uint256 _rcipeId,
        bytes memory _params,
        uint8[] memory _paramMapping,
        bytes32[] memory _returnValues
    )
        public
        payable
        override
        returns (bytes32 result)
    {
        Params memory params = abi.decode(_params, (Params));
        bool eth;

        if (address(params.path[0]) == WETH_ADDRESS) {
            TokenUtils.ensureETHAndWETH(WETH_ADDRESS, params.amountInMax);
        } else {
            require(IERC20(params.path[0]).balanceOf(address(this)) >= params.amountInMax, "Not enough TokenB");
        }

        if (params.path[params.path.length - 1] == ETH_ADDRESS) {
            params.path[params.path.length - 1] = WETH_ADDRESS;
            eth = true;
        }

        params.amountOut = _parseParamUint(params.amountOut, _paramMapping[0], _returnValues);
        params.amountInMax = _parseParamUint(params.amountInMax, _paramMapping[1], _returnValues);
        params.to = _parseParamAddr(params.to, _paramMapping[2], _returnValues);

        uint256 amount = _swapTokensForExactTokens(params);

        if (eth) {
            TokenUtils.withdrawWeth(params.amountOut);
        }

        result = bytes32(amount);

        bytes memory logData =
            abi.encode(_rcipeId, params.path[0], params.path[params.path.length - 1], amount, params.amountOut);
        emit ActionEvent("UniswapV2ExactOut", logData);
    }

    function executeActionDirect(bytes memory _params) public payable override returns (bytes32 result) {
        return this.executeAction(0, _params, new uint8[](0), new bytes32[](0));
    }

    function actionType() public pure override returns (uint8) {
        return uint8(ActionType.STANDARD_ACTION);
    }

    //////////////////////////// ACTION LOGIC ////////////////////////////

    function _swapTokensForExactTokens(Params memory _params) internal returns (uint256 amount) {
        _params.path[0].approveToken(address(router), _params.amountInMax);

        (uint256[] memory amounts) = router.swapTokensForExactTokens(
            _params.amountOut, _params.amountInMax, _params.path, _params.to, _params.deadline
        );

        amount = amounts[0];

        _params.path[0].revokeToken(address(router));
    }
}
