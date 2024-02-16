// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Registry } from "./Registry.sol";
import { Constants } from "./utils/Constants.sol";
import { IRecipeStorage } from "./interfaces/IRecipeStorage.sol";
import { IValidator } from "./interfaces/IValidator.sol";
import { ActionBase } from "./actions/ActionBase.sol";
import { FlashLoanBase } from "./actions/FlashLoanBase.sol";
import { IKernel } from "kernel/interfaces/IKernel.sol";
import { EventLogger } from "./logger/EventLogger.sol";
import { IExecutor } from "./interfaces/IExecutor.sol";

contract Executor is Constants, IExecutor {
    Registry public constant registry = Registry(REGISTRY_ADDRESS);
    EventLogger public constant logger = EventLogger(EVENTLOGGER_ADDRESS);

    /// @param _recipeId recipe id
    /// @param _params recipe action params
    /// @param _paramMappings useing for override _param with returnValue
    /// @param _debt flash loan debt value, from FL action contract
    function execute1Tx(
        uint256 _recipeId,
        bytes[] calldata _params,
        uint8[][] calldata _paramMappings,
        bytes32 _debt
    )
        public
        payable
    {
        IRecipeStorage recipeStorage = IRecipeStorage(registry.getAddr(bytes4(keccak256(bytes("RecipeStorage")))));
        recipeStorage.recipeAccessCheck(_recipeId);

        // In recipes using FlashLoan, the first action is always the FlashLoan action.
        // After the FlashLoan is completed, the token amount(amount + premium) to be repaid is filled in _debt and the
        // `execute1Tx()` function is executed.
        if (_debt == bytes32(0)) {
            address firstAction = recipeStorage.getFirstAction(_recipeId);
            if (_isFL(firstAction)) {
                _executeFlashLoanAction(firstAction, _recipeId, _params, _paramMappings);
            } else {
                (address[] memory actions) = recipeStorage.getActions(_recipeId);
                bytes32[] memory returnValues = new bytes32[](actions.length);

                for (uint256 i = 0; i < actions.length; ++i) {
                    returnValues[i] = _executeAction(_recipeId, actions[i], _params[i], _paramMappings[i], returnValues);
                }

                logger.logExecute1TxEvent(_recipeId);
            }
        } else {
            // This logic is executed after the FlashLoan Action.
            // _debt is the total amount including the amount and premium,
            // and is assigned to the 0th index of returnValues.
            // Since the first action has already been executed,
            // the loop starts from the 1st index.
            (address[] memory actions) = recipeStorage.getActions(_recipeId);
            bytes32[] memory returnValues = new bytes32[](actions.length);

            returnValues[0] = _debt;

            for (uint256 i = 1; i < actions.length; ++i) {
                returnValues[i] = _executeAction(_recipeId, actions[i], _params[i], _paramMappings[i], returnValues);
            }
            logger.logExecute1TxEvent(_recipeId);
        }
    }

    function _executeFlashLoanAction(
        address _firstAction,
        uint256 _recipeId,
        bytes[] memory _params,
        uint8[][] memory _paramMappings
    )
        internal
    {
        IValidator validator = IValidator(registry.getAddr(bytes4(keccak256(bytes("Validator")))));
        // address(this) is user SCA address
        IValidator.Status status = validator.getStatus(address(this));

        if (status == IValidator.Status.NOT_ADDED) {
            revert("plug-in not added!");
        }
        if (status == IValidator.Status.DISABLED) {
            validator.activate();
        }

        FlashLoanBase(_firstAction).executeAction(_recipeId, _params, _paramMappings);

        validator.deactivate();
    }

    function _executeAction(
        uint256 _recipeId,
        address _actions,
        bytes calldata _params,
        uint8[] memory _paramMapping,
        bytes32[] memory _returnValues
    )
        internal
        returns (bytes32 response)
    {
        (bool success, bytes memory data) = _actions.delegatecall(
            abi.encodeWithSignature(
                "executeAction(uint256,bytes,uint8[],bytes32[])", _recipeId, _params, _paramMapping, _returnValues
            )
        );

        require(success, "delegateCall fail");

        response = bytes32(data);
    }

    function _isFL(address _firstAction) internal pure returns (bool) {
        return ActionBase(_firstAction).actionType() == uint8(ActionBase.ActionType.FL_ACTION);
    }
}
