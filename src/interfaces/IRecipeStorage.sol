// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRecipeStorage {
    enum RecipeType {
        PUBLIC, // 0
        PRIVATE // 1

    }

    function createRecipe(
        address _manager,
        bytes4[] calldata _actions,
        uint256 _fee,
        address[] calldata _whitelist
    )
        external
        payable
        returns (uint256);

    function getFirstAction(uint256 _recipeId) external view returns (address);

    function getActions(uint256 _recipeId) external view returns (address[] memory);

    function recipeAccessCheck(uint256 _recipeId) external view;

    function setRecipeActions(uint256 _recipeId, bytes4[] calldata _actions) external;

    function setRecipeFee(uint256 _recipeId, uint256 _fee) external;

    function setRecipeWhitelist(uint256 _recipeId, address[] calldata _whitelist) external;

    function setRecipeType(uint256 _recipeId, RecipeType _recipeType) external;

    function setRecipeManager(uint256 _recipeId, address _manager) external;

    function setRecipeAvailable(uint256 _recipeId, bool _available) external;

    function verificationCheck(uint256 _recipeId) external;
}
