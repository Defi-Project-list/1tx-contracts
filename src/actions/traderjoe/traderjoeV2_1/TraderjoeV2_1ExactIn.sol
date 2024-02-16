// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ActionBase } from "../../ActionBase.sol";
import { JoeV2_1Helper } from "./helpers/JoeV2_1Helper.sol";
import { TokenUtils } from "../../../utils/TokenUtils.sol";
import { Constants } from "../../../utils/Constants.sol";
import { IERC20 } from "openzeppelin/interfaces/IERC20.sol";
import "../../../interfaces/IWETH.sol";

import "forge-std/console.sol";

import { ILBRouter } from "../../../interfaces/ITraderJoeV2_1Router.sol";

contract TraderjoeV2_1ExactIn is Constants, ActionBase, JoeV2_1Helper {
    using TokenUtils for address;

    enum Version {
        V1,
        V2,
        V2_1
    }

    struct Params {
        uint256 amountIn;
        uint256 amountOutMin;
        uint256[] pairBinSteps;
        ILBRouter.Version[] versions;
        IERC20[] tokenPath;
        address to;
    }

    function executeAction(
        uint256 _recipeId,
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

        require(IERC20(params.tokenPath[0]).balanceOf(address(this)) >= params.amountIn, "Not enough TokenB");

        if (_returnValues.length != 0 && _paramMapping.length != 0) {
            params.amountIn = _parseParamUint(params.amountIn, _paramMapping[0], _returnValues);
            params.amountOutMin = _parseParamUint(params.amountOutMin, _paramMapping[1], _returnValues);
            params.to = _parseParamAddr(params.to, _paramMapping[5], _returnValues);
        }

        uint256 amount = _swapExactTokensForTokens(params);

        result = bytes32(amount);

        bytes memory logData = abi.encode(
            _recipeId, params.tokenPath[0], params.tokenPath[params.tokenPath.length - 1], params.amountIn, amount
        );
        emit ActionEvent("TraderjoeV2_1ExactIn", logData);
    }

    function executeActionDirect(bytes memory _params) public payable override returns (bytes32 result) {
        return this.executeAction(0, _params, new uint8[](0), new bytes32[](0));
    }

    function actionType() public pure override returns (uint8) {
        return uint8(ActionType.STANDARD_ACTION);
    }

    //////////////////////////// ACTION LOGIC ////////////////////////////

    function _swapExactTokensForTokens(Params memory _params) internal returns (uint256 amount) {
        address(_params.tokenPath[0]).approveToken(address(router), _params.amountIn);

        ILBRouter.Path memory path;
        path.pairBinSteps = _params.pairBinSteps;
        path.versions = _params.versions;
        path.tokenPath = _params.tokenPath;

        uint256 deadline = block.timestamp + 1000;

        amount = router.swapExactTokensForTokens(_params.amountIn, _params.amountOutMin, path, _params.to, deadline);

        address(_params.tokenPath[0]).revokeToken(address(router));
    }
}
