// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Auth } from "../auth/Auth.sol";
import { Registry } from "../Registry.sol";
import { EventLogger } from "../logger/EventLogger.sol";
import { Constants } from "../utils/Constants.sol";
import { IKernel } from "kernel/interfaces/IKernel.sol";

// FlashLoan은 가장 처음에 실행되기 때문에 isReplaceable 할 리가 없다.
// 추후 정리 필요

abstract contract FlashLoanBase is Constants {
    event ActionEvent(string indexed logName, bytes data);

    Registry public constant registry = Registry(REGISTRY_ADDRESS);

    EventLogger public constant logger = EventLogger(EVENTLOGGER_ADDRESS);

    //Wrong return index value
    error ReturnIndexValueError();

    /// @dev Return params index range [1, 127]
    uint8 public constant RETURN_MIN_INDEX_VALUE = 1;
    uint8 public constant RETURN_MAX_INDEX_VALUE = 128;

    /// @dev If the input value should not be replaced
    uint8 public constant NO_PARAM_MAPPING = 0;

    /// @dev We need to parse Flash loan actions in a different way
    enum ActionType {
        FL_ACTION,
        STANDARD_ACTION,
        FEE_ACTION,
        CHECK_ACTION,
        CUSTOM_ACTION
    }

    function executeAction(
        uint256 _recipeId,
        bytes[] memory _params,
        uint8[][] memory _paramMappings
    )
        public
        payable
        virtual;

    function actionType() public pure virtual returns (uint8);

    /// @notice Flash Loan actions are not meant to be executed directly

    //////////////////////////// HELPER METHODS ////////////////////////////

    /// @notice Given an uint256 input, injects return/sub values if specified
    /// @param _param The original input value
    /// @param _mapType Indicated the type of the input in paramMapping
    /// @param _returnValues Array of subscription data we can replace the input value with
    function _parseParamUint(
        uint256 _param,
        uint8 _mapType,
        bytes32[] memory _returnValues
    )
        internal
        pure
        returns (uint256)
    {
        if (isReplaceable(_mapType)) {
            if (isReturnInjection(_mapType)) {
                _param = uint256(_returnValues[getReturnIndex(_mapType)]);
            }
        }

        return _param;
    }

    /// @notice Given an addr input, injects return/sub values if specified
    /// @param _param The original input value
    /// @param _mapType Indicated the type of the input in paramMapping
    /// @param _returnValues Array of subscription data we can replace the input value with
    function _parseParamAddr(
        address _param,
        uint8 _mapType,
        bytes32[] memory _returnValues
    )
        internal
        pure
        returns (address)
    {
        if (isReplaceable(_mapType)) {
            if (isReturnInjection(_mapType)) {
                _param = address(bytes20((_returnValues[getReturnIndex(_mapType)])));
            }
        }

        return _param;
    }

    /// @notice Given an bytes32 input, injects return/sub values if specified
    /// @param _param The original input value
    /// @param _mapType Indicated the type of the input in paramMapping
    /// @param _returnValues Array of subscription data we can replace the input value with
    function _parseParamABytes32(
        bytes32 _param,
        uint8 _mapType,
        bytes32[] memory _returnValues
    )
        internal
        pure
        returns (bytes32)
    {
        if (isReplaceable(_mapType)) {
            if (isReturnInjection(_mapType)) {
                _param = (_returnValues[getReturnIndex(_mapType)]);
            }
        }

        return _param;
    }

    /// @notice Checks if the paramMapping value indicated that we need to inject values
    /// @param _type Indicated the type of the input
    function isReplaceable(uint8 _type) internal pure returns (bool) {
        return _type != NO_PARAM_MAPPING;
    }

    /// @notice Checks if the paramMapping value is in the return value range
    /// @param _type Indicated the type of the input
    function isReturnInjection(uint8 _type) internal pure returns (bool) {
        return (_type >= RETURN_MIN_INDEX_VALUE) && (_type <= RETURN_MAX_INDEX_VALUE);
    }

    /// @notice Transforms the paramMapping value to the index in return array value
    /// @param _type Indicated the type of the input
    function getReturnIndex(uint8 _type) internal pure returns (uint8) {
        if (!(isReturnInjection(_type))) {
            revert ReturnIndexValueError();
        }

        return (_type - RETURN_MIN_INDEX_VALUE);
    }
}
