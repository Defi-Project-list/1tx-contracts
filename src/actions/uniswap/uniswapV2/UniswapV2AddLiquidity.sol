// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "openzeppelin/interfaces/IERC20.sol";
import { ActionBase } from "../../ActionBase.sol";
import { UniV2Helper } from "./helpers/UniV2Helper.sol";
import { TokenUtils } from "../../../utils/TokenUtils.sol";
import { IWETH } from "../../../interfaces/IWETH.sol";
import { Constants } from "../../../utils/Constants.sol";

contract UniswapV2AddLiquidity is Constants, ActionBase, UniV2Helper {
    using TokenUtils for address;

    struct Params {
        address tokenA;
        address tokenB;
        address to;
        uint256 amountADesired;
        uint256 amountBDesired;
        uint256 amountAMin;
        uint256 amountBMin;
        uint256 deadline;
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

        // ETH와 WETH를 더한 잔액이 요청한 금액만큼인지 확인
        // 부족한 WETH는 ETH를 wrap해서 보충
        if (address(params.tokenA) == WETH_ADDRESS || address(params.tokenB) == WETH_ADDRESS) {
            uint256 desiredWeth;
            if (address(params.tokenA) == WETH_ADDRESS) {
                desiredWeth = params.amountADesired;
                TokenUtils.ensureETHAndWETH(WETH_ADDRESS, desiredWeth);
                require(IERC20(params.tokenB).balanceOf(address(this)) >= params.amountBDesired, "Not enough TokenB");
            } else {
                desiredWeth = params.amountBDesired;
                TokenUtils.ensureETHAndWETH(WETH_ADDRESS, desiredWeth);
                require(IERC20(params.tokenA).balanceOf(address(this)) >= params.amountADesired, "Not enough TokenA");
            }
        } else {
            require(IERC20(params.tokenA).balanceOf(address(this)) >= params.amountADesired, "Not enough TokenA");
            require(IERC20(params.tokenB).balanceOf(address(this)) >= params.amountBDesired, "Not enough TokenB");
        }

        params.tokenA = _parseParamAddr(params.tokenA, _paramMapping[0], _returnValues);
        params.tokenB = _parseParamAddr(params.tokenB, _paramMapping[1], _returnValues);
        params.to = _parseParamAddr(params.to, _paramMapping[2], _returnValues);
        params.amountADesired = _parseParamUint(params.amountADesired, _paramMapping[3], _returnValues);
        params.amountBDesired = _parseParamUint(params.amountBDesired, _paramMapping[4], _returnValues);

        (uint256 amountA, uint256 amountB, uint256 liqAmount) = _addLiquidity(params);

        result = bytes32(liqAmount);

        bytes memory logData = abi.encode(_recipeId, _params, amountA, amountB, liqAmount);
        emit ActionEvent("UniswapV2AddLiquidity", logData);
    }

    function executeActionDirect(bytes memory _params) public payable override returns (bytes32 result) {
        return this.executeAction(0, _params, new uint8[](0), new bytes32[](0));
    }

    function actionType() public pure override returns (uint8) {
        return uint8(ActionType.STANDARD_ACTION);
    }

    //////////////////////////// ACTION LOGIC ////////////////////////////

    function _addLiquidity(Params memory _params)
        internal
        returns (uint256 amountA, uint256 amountB, uint256 liqAmount)
    {
        _params.tokenA.approveToken(address(router), _params.amountADesired);
        _params.tokenB.approveToken(address(router), _params.amountBDesired);

        (amountA, amountB, liqAmount) = router.addLiquidity(
            _params.tokenA,
            _params.tokenB,
            _params.amountADesired,
            _params.amountBDesired,
            _params.amountAMin,
            _params.amountBMin,
            _params.to,
            _params.deadline
        );

        _params.tokenA.revokeToken(address(router));
        _params.tokenB.revokeToken(address(router));
    }
}
