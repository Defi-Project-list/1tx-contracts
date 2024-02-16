// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ActionBase } from "../ActionBase.sol";

contract SumInputs is ActionBase {
    struct Params {
        uint256 a;
        uint256 b;
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

        params.a = _parseParamUint(params.a, _paramMapping[0], _returnValues);
        params.b = _parseParamUint(params.b, _paramMapping[1], _returnValues);

        result = bytes32(_sumInputs(params.a, params.b));

        bytes memory logData = abi.encode(_recipeId, result);

        emit ActionEvent("SumInputs", logData);
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

    function _sumInputs(uint256 _a, uint256 _b) internal pure returns (uint256) {
        return _a + _b;
    }
}
