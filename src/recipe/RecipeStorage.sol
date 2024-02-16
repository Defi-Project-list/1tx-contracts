// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../Registry.sol";
import { Constants } from "../utils/Constants.sol";
import { IRecipeStorage } from "../interfaces/IRecipeStorage.sol";

contract RecipeStorage is Constants, IRecipeStorage {
    Registry public constant registry = Registry(REGISTRY_ADDRESS);

    modifier onlyManager(uint256 _recipeId) {
        require(recipes[_recipeId].recipeId != 0, "Recipe does not exist");
        require(msg.sender == recipes[_recipeId].manager, "Only the manager can perform this operation");
        _;
    }

    struct Recipe {
        uint256 recipeId;
        address manager;
        mapping(address => bool) whitelist;
        RecipeType recipeType;
        bytes4[] actions;
        uint256 fee;
        bool available;
        bool isVerified;
    }

    mapping(uint256 => Recipe) recipes;

    uint256 public recipeCount = 1;

    function createRecipe(
        address _manager,
        bytes4[] calldata _actions,
        uint256 _fee,
        address[] calldata _whitelist
    )
        public
        payable
        returns (uint256)
    {
        bool verified = true;

        for (uint256 i = 0; i < _actions.length; i++) {
            if (!registry.isVerifiedContract(_actions[i])) {
                verified = false;
                break;
            }
        }

        Recipe storage newRecipe = recipes[recipeCount];
        newRecipe.recipeId = recipeCount;
        newRecipe.manager = _manager;
        newRecipe.actions = _actions;
        newRecipe.fee = _fee;
        newRecipe.available = true;
        newRecipe.isVerified = verified;

        for (uint256 i = 0; i < _whitelist.length; i++) {
            newRecipe.whitelist[_whitelist[i]] = true;
        }

        recipeCount++;

        return (recipeCount - 1);
    }

    function getFirstAction(uint256 _recipeId) public view returns (address) {
        Recipe storage recipe = recipes[_recipeId];
        return registry.getAddr(recipe.actions[0]);
    }

    function getActions(uint256 _recipeId) public view returns (address[] memory) {
        Recipe storage recipe = recipes[_recipeId];
        address[] memory actions = new address[](recipe.actions.length);
        for (uint256 i = 0; i < recipe.actions.length; i++) {
            actions[i] = registry.getAddr(recipe.actions[i]);
        }
        return (actions);
    }

    function recipeAccessCheck(uint256 _recipeId) public view {
        require(recipes[_recipeId].recipeId != 0, "Invalid recipe id");
        require(recipes[_recipeId].available, "This recipe has been deactivated by the manager");
        if (recipes[_recipeId].recipeType == RecipeType.PRIVATE) {
            require(recipes[_recipeId].whitelist[msg.sender], "You do not have access to this recipe");
        }
    }

    /*
    Only manager functions
    */

    function setRecipeActions(uint256 _recipeId, bytes4[] calldata _actions) public onlyManager(_recipeId) {
        if (_actions.length > 0) {
            Recipe storage recipe = recipes[_recipeId];
            recipe.actions = _actions;

            verificationCheck(_recipeId);
        }
    }

    function setRecipeFee(uint256 _recipeId, uint256 _fee) public onlyManager(_recipeId) {
        Recipe storage recipe = recipes[_recipeId];
        recipe.fee = _fee;
    }

    function setRecipeWhitelist(uint256 _recipeId, address[] calldata _whitelist) public onlyManager(_recipeId) {
        Recipe storage recipe = recipes[_recipeId];
        for (uint256 i = 0; i < _whitelist.length; i++) {
            recipe.whitelist[_whitelist[i]] = true;
        }
    }

    function setRecipeType(uint256 _recipeId, RecipeType _recipeType) public onlyManager(_recipeId) {
        Recipe storage recipe = recipes[_recipeId];
        recipe.recipeType = _recipeType;
    }

    function setRecipeManager(uint256 _recipeId, address _manager) public onlyManager(_recipeId) {
        Recipe storage recipe = recipes[_recipeId];
        recipe.manager = _manager;
    }

    function setRecipeAvailable(uint256 _recipeId, bool _available) public onlyManager(_recipeId) {
        Recipe storage recipe = recipes[_recipeId];
        recipe.available = _available;
    }

    function verificationCheck(uint256 _recipeId) public {
        Recipe storage recipe = recipes[_recipeId];

        bytes4[] memory acts = recipe.actions;

        bool verified = true;

        for (uint256 i = 0; i < acts.length; i++) {
            if (!registry.isVerifiedContract(acts[i])) {
                verified = false;
                break;
            }
        }

        recipe.isVerified = verified;
    }
}
