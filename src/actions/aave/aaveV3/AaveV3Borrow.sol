// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../../../utils/TokenUtils.sol";
import "../../ActionBase.sol";
import "./helpers/AaveV3Helper.sol";
import { IPool } from "aaveV3/interfaces/IPool.sol";

/// @title Borrow a token from AaveV3 market
// @doc https://docs.aave.com/developers/core-contracts/pool#borrow
contract AaveV3Borrow is ActionBase, AaveV3Helper {
    using TokenUtils for address;

    struct Params {
        uint256 amount;
        address to;
        uint8 rateMode;
        uint16 assetId;
        bool useOnBehalf;
        address onBehalf;
    }

    /// @inheritdoc ActionBase
    function executeAction(
        uint256 _recipeId,
        bytes memory _params,
        uint8[] memory _paramMapping,
        bytes32[] memory _returnValues
    )
        public
        payable
        override
        returns (bytes32)
    {
        Params memory params = parseInputs(_params);
        if (_returnValues.length != 0 && _paramMapping.length != 0) {
            params.amount = _parseParamUint(params.amount, _paramMapping[0], _returnValues);
            params.to = _parseParamAddr(params.to, _paramMapping[1], _returnValues);
            params.rateMode = uint8(_parseParamUint(uint8(params.rateMode), _paramMapping[2], _returnValues));
            params.assetId = uint16(_parseParamUint(uint16(params.assetId), _paramMapping[3], _returnValues));
            params.useOnBehalf = _parseParamUint(params.useOnBehalf ? 1 : 0, _paramMapping[4], _returnValues) == 1;
            params.onBehalf = _parseParamAddr(params.onBehalf, _paramMapping[5], _returnValues);
        }

        if (!params.useOnBehalf) {
            params.onBehalf = address(0);
        }

        (uint256 borrowAmount, bytes memory logData) =
            _borrow(_recipeId, params.assetId, params.amount, params.rateMode, params.to, params.onBehalf);

        emit ActionEvent("AaveV3Borrow", logData);
        return bytes32(borrowAmount);
    }

    /// @inheritdoc ActionBase
    function executeActionDirect(bytes memory _params) public payable override returns (bytes32) {
        return this.executeAction(0, _params, new uint8[](0), new bytes32[](0));
    }

    /// @inheritdoc ActionBase
    function actionType() public pure virtual override returns (uint8) {
        return uint8(ActionType.STANDARD_ACTION);
    }

    //////////////////////////// ACTION LOGIC ////////////////////////////

    /// @notice User borrows tokens from the Aave protocol
    /// @param _assetId The id of the token to be borrowed
    /// @param _amount Amount of tokens to be borrowed
    /// @param _rateMode Type of borrow debt [Stable: 1, Variable: 2]
    /// @param _to The address we are sending the borrowed tokens to
    /// @param _onBehalf On whose behalf we borrow the tokens, defaults to proxy
    function _borrow(
        uint256 _recipeId,
        uint16 _assetId,
        uint256 _amount,
        uint256 _rateMode,
        address _to,
        address _onBehalf
    )
        internal
        returns (uint256, bytes memory)
    {
        IPool lendingPool = IPool(poolAddressProvider.getPool());

        address reserveAddr = lendingPool.getReserveAddressById(_assetId);
        // defaults to onBehalf of proxy
        if (_onBehalf == address(0)) {
            _onBehalf = address(this);
        }
        lendingPool.borrow(reserveAddr, _amount, _rateMode, AAVE_REFERRAL_CODE, _onBehalf);
        _amount = reserveAddr.withdrawTokens(_to, _amount);

        bytes memory logData = abi.encode(_recipeId, reserveAddr, _amount, _rateMode, _to, _onBehalf);
        return (_amount, logData);
    }

    function parseInputs(bytes memory _callData) public pure returns (Params memory params) {
        params = abi.decode(_callData, (Params));
    }
}
