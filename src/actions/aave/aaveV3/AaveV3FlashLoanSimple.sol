// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { FlashLoanBase } from "../../FlashLoanBase.sol";
import { FlashLoanSimpleReceiverBase } from "aaveV3/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import { IPool } from "aaveV3/interfaces/IPool.sol";
import { TokenUtils } from "../../../utils/TokenUtils.sol";
import { PercentageMath } from "aaveV3/protocol/libraries/math/PercentageMath.sol";
import { AaveV3Helper } from "./helpers/AaveV3Helper.sol";
import { IExecutor } from "../../../interfaces/IExecutor.sol";

contract AaveV3FlashLoanSimple is FlashLoanBase, FlashLoanSimpleReceiverBase, AaveV3Helper {
    using TokenUtils for address;
    using PercentageMath for uint256;

    struct Params {
        address asset;
        uint256 amount;
        uint16 referralCode;
    }

    struct ExecuteData {
        address userAddress;
        uint256 recipeId;
        bytes[] params;
        uint8[][] paramMappings;
    }

    constructor() FlashLoanSimpleReceiverBase(poolAddressProvider) { }

    function executeAction(
        uint256 _recipeId,
        bytes[] memory _params,
        uint8[][] memory _paramMappings
    )
        public
        payable
        override
    {
        Params memory params = parseInputs(_params[0]);
        ExecuteData memory _executeData = ExecuteData({
            userAddress: msg.sender, // user SCA address
            recipeId: _recipeId,
            params: _params,
            paramMappings: _paramMappings
        });
        bytes memory operationData = abi.encode(_executeData);

        _executeFlashLoanSimple(params, operationData);

        bytes memory logData = abi.encode(params.amount);

        emit ActionEvent("AaveV3FlashLoanSimple", logData);
    }

    function actionType() public pure override returns (uint8) {
        return uint8(ActionType.FL_ACTION);
    }

    function parseInputs(bytes memory _params) public pure returns (Params memory params) {
        params = abi.decode(_params, (Params));
    }

    /**
     * "executeOperation()" called when a flashloan is executed from the Aave Pool contract
     */
    function executeOperation(
        address _asset,
        uint256 _amount,
        uint256 _premium,
        address,
        /**
         * _initiator
         */
        bytes calldata _operationData
    )
        external
        override
        returns (bool)
    {
        ExecuteData memory _executeData = abi.decode(_operationData, (ExecuteData));
        // send token to user
        _asset.withdrawTokens(_executeData.userAddress, _amount);

        // execute1Tx() with debt
        IExecutor(_executeData.userAddress).execute1Tx(
            _executeData.recipeId, _executeData.params, _executeData.paramMappings, bytes32(_amount + _premium)
        );

        _asset.approveToken(address(POOL), _amount + _premium);

        return true;
    }

    //////////////////////////// ACTION LOGIC ////////////////////////////

    function _executeFlashLoanSimple(Params memory _params, bytes memory _operationData) internal {
        POOL.flashLoanSimple(address(this), _params.asset, _params.amount, _operationData, _params.referralCode);

        _params.asset.revokeToken(address(POOL));
    }
}
