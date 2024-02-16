// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ActionBase } from "./ActionBase.sol";

contract Example is ActionBase {
    // 사용할 라이브러리 적용
    // 예) using TokenUtils for address;

    struct Params {
        bytes32 param1;
        bytes32 param2;
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

        // parse 먼저 진행 이전에 있었던 action 결과를 사용할지 _params로 넘겨받은 내용을 사용할지 결정
        // ActionBase 컨트랙트에 정의되어 있음
        params.param1 = _parseParamABytes32(params.param1, _paramMapping[0], _returnValues);
        params.param2 = _parseParamABytes32(params.param2, _paramMapping[1], _returnValues);

        // ...

        result = bytes32(
            /**
             * something
             */
            0
        );

        bytes memory logData = abi.encode(_recipeId);

        /**
         * something
         */
        emit ActionEvent("ContractName", logData);
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

    // 실제 사용시 view는 삭제
    function _doSomething(Params memory _params) internal view returns (uint256, bytes32, bytes32) {
        return (block.timestamp, _params.param1, _params.param2);
    }
}
