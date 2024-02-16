// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../../../utils/TokenUtils.sol";
import "../../ActionBase.sol";
import "./helpers/AaveV3Helper.sol";
import { IPool } from "aaveV3/interfaces/IPool.sol";

/// @title Supply a token to an Aave market
// @doc https://docs.aave.com/developers/core-contracts/pool#supply
contract AaveV3Supply is ActionBase, AaveV3Helper {
    using TokenUtils for address;

    struct Params {
        uint256 amount;
        address from;
        uint16 assetId;
        bool enableAsColl;
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
            params.from = _parseParamAddr(params.from, _paramMapping[1], _returnValues);
            params.assetId = uint16(_parseParamUint(params.assetId, _paramMapping[2], _returnValues));
            params.enableAsColl = _parseParamUint(params.enableAsColl ? 1 : 0, _paramMapping[3], _returnValues) == 1;
            params.useOnBehalf = _parseParamUint(params.useOnBehalf ? 1 : 0, _paramMapping[4], _returnValues) == 1;
            params.onBehalf = _parseParamAddr(params.onBehalf, _paramMapping[5], _returnValues);
        }

        if (!params.useOnBehalf) {
            params.onBehalf = address(0);
        }

        (uint256 supplyAmount, bytes memory logData) =
            _supply(_recipeId, params.amount, params.from, params.assetId, params.enableAsColl, params.onBehalf);
        emit ActionEvent("AaveV3Supply", logData);
        return bytes32(supplyAmount);
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

    /// @notice User deposits tokens to the Aave protocol
    /// @dev User needs to approve the DSProxy to pull the tokens being supplied
    /// @param _amount Amount of tokens to be deposited
    /// @param _from Where are we pulling the supply tokens amount from
    /// @param _assetId The id of the token to be deposited
    /// @param _enableAsColl If the supply asset should be collateral
    /// @param _onBehalf For what user we are supplying the tokens, defaults to proxy
    function _supply(
        uint256 _recipeId,
        uint256 _amount,
        address _from,
        uint16 _assetId,
        bool _enableAsColl,
        address _onBehalf
    )
        internal
        returns (uint256, bytes memory)
    {
        IPool lendingPool = IPool(poolAddressProvider.getPool());
        address reserveAddr = lendingPool.getReserveAddressById(_assetId);

        // if amount is set to max, take the whole _from balance
        if (_amount == type(uint256).max) {
            _amount = reserveAddr.getBalance(_from);
        }

        // default to onBehalf of proxy
        if (_onBehalf == address(0)) {
            _onBehalf = address(this);
        }

        // pull tokens to proxy so we can supply
        reserveAddr.pullTokensIfNeeded(_from, _amount);

        // approve aave pool to pull tokens
        reserveAddr.approveToken(address(lendingPool), _amount);

        lendingPool.supply(reserveAddr, _amount, _onBehalf, AAVE_REFERRAL_CODE);

        if (_enableAsColl) {
            lendingPool.setUserUseReserveAsCollateral(reserveAddr, true);
        } else {
            lendingPool.setUserUseReserveAsCollateral(reserveAddr, false);
        }

        bytes memory logData = abi.encode(_recipeId, reserveAddr, _amount, _from, _onBehalf, _enableAsColl);
        return (_amount, logData);
    }

    function parseInputs(bytes memory _callData) public pure returns (Params memory params) {
        params = abi.decode(_callData, (Params));
    }
}
