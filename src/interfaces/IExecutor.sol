// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IExecutor {
    event Process(uint256 indexed recipeId, address actionAddress, uint256 currentStep, uint256 totalStep);

    /// @param _recipeId recipe id
    /// @param _params recipe action params
    /// @param _paramMappings used for override _param with returnValue
    /// @param _debt flash loan debt value, from FL action contract
    function execute1Tx(
        uint256 _recipeId,
        bytes[] calldata _params,
        uint8[][] calldata _paramMappings,
        bytes32 _debt
    )
        external
        payable;
}
