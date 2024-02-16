// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ActionBase } from "../ActionBase.sol";
import { TokenUtils } from "../../utils/TokenUtils.sol";
import { Constants } from "../../utils/Constants.sol";
import "../../interfaces/IWETH.sol";

contract WrappingETH is Constants, ActionBase {
    using TokenUtils for address;

    struct Params {
        uint256 amount;
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
        Params memory params = parseInputs(_params);

        params.amount = _parseParamUint(params.amount, _paramMapping[0], _returnValues);

        params.amount = _wrappingEth(params.amount);

        result = bytes32(params.amount);

        bytes memory logData = abi.encode(_recipeId, result);

        emit ActionEvent("WrappingETH", logData);
    }

    function executeActionDirect(bytes memory _params) public payable override returns (bytes32 result) {
        return this.executeAction(0, _params, new uint8[](0), new bytes32[](0));
    }

    function actionType() public pure override returns (uint8) {
        return uint8(ActionType.STANDARD_ACTION);
    }

    function parseInputs(bytes memory _params) public pure returns (Params memory params) {
        params = abi.decode(_params, (Params));
    }

    //////////////////////////// ACTION LOGIC ////////////////////////////

    function _wrappingEth(uint256 _amount) internal returns (uint256) {
        IWETH(WETH_ADDRESS).deposit{ value: _amount }();

        return _amount;
    }
}
