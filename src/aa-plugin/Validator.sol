// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { UserOperation } from "../interfaces/UserOperation.sol";
import { Registry } from "../Registry.sol";
import { ECDSA } from "solady/utils/ECDSA.sol";
import { IKernelValidator } from "kernel/interfaces/IKernelValidator.sol";
import { IValidator } from "../interfaces/IValidator.sol";
import { ValidationData } from "kernel/common/Types.sol";
import { Constants } from "../utils/Constants.sol";
import { SIG_VALIDATION_FAILED } from "kernel/common/Constants.sol";

contract Validator is Constants, IValidator {
    Registry registry = Registry(REGISTRY_ADDRESS);

    // key of metadataMap(address) is user SCA address
    mapping(address => Metadata) metadataMap;

    function enable(bytes calldata _data) external payable {
        address owner = address(bytes20(_data[0:20]));
        address oldOwner = metadataMap[msg.sender].owner;
        metadataMap[msg.sender].owner = owner;
        emit OwnerChanged(msg.sender, oldOwner, owner);
    }

    function disable(bytes calldata)
        /**
         * _data
         */
        external
        payable
    {
        delete metadataMap[msg.sender];
    }

    function validateUserOp(
        UserOperation calldata _userOp,
        bytes32 _userOpHash,
        uint256
    )
        /**
         * _missingFund
         */
        external
        payable
        returns (ValidationData validationData)
    {
        address owner = metadataMap[_userOp.sender].owner;
        bytes32 hash = ECDSA.toEthSignedMessageHash(_userOpHash);
        if (owner == ECDSA.recover(hash, _userOp.signature)) {
            return ValidationData.wrap(0);
        }
        if (owner != ECDSA.recover(_userOpHash, _userOp.signature)) {
            return SIG_VALIDATION_FAILED;
        }
    }

    function validateSignature(bytes32 hash, bytes calldata signature) external view returns (ValidationData) {
        address owner = metadataMap[msg.sender].owner;
        if (owner == ECDSA.recover(hash, signature)) {
            return ValidationData.wrap(0);
        }
        bytes32 ethHash = ECDSA.toEthSignedMessageHash(hash);
        address recovered = ECDSA.recover(ethHash, signature);
        if (owner != recovered) {
            return SIG_VALIDATION_FAILED;
        }
        return ValidationData.wrap(0);
    }

    // if Kernel's `execute` didn't go to the fallback logic:
    // - `msg.sender` in the context of Validator is always SCA (as this was called directly from Kernel)
    // - `_caller` can be a random address (as other addresses can directly call Kernel SCA, thus msg.sender of Kernel
    // can be anyone)
    //
    // if Kernel's `execute` did go to the fallback logic:
    // - `msg.sender` in the context of Validator is always SCA (as this was called directly from Kernel)
    // - `_caller` can be either FL action contract (assuming FL action contract directly goes to the fallback logic) OR
    // SCA itself (e.g. when it was called by entry point)
    //
    // Considering above, `validCaller` should return `true` when:
    // 1. if `_caller` is a verified contract (i.e. action contract) && if validator is enabled for the SCA
    // 2. if `_caller` is not a verified contract, this means `_caller` can be either SCA or malicious address:
    // 2-a. if the owner of the SCA == `_caller`
    // 2-b. `_caller` itself is SCA
    function validCaller(address _caller, bytes calldata /* data */ ) external view returns (bool) {
        return (registry.isVerifiedContract(_caller) && metadataMap[msg.sender].enabled)
            || (metadataMap[msg.sender].owner == _caller) || (_caller == msg.sender);
    }

    function activate() external {
        require(metadataMap[msg.sender].owner != address(0), "add module first");
        metadataMap[msg.sender].enabled = true;
    }

    function deactivate() external {
        require(metadataMap[msg.sender].owner != address(0), "add module first");
        metadataMap[msg.sender].enabled = false;
    }

    function getStatus(address _user) external view returns (Status) {
        if (metadataMap[_user].owner == address(0)) {
            return Status.NOT_ADDED;
        } else if (metadataMap[_user].enabled == false) {
            return Status.DISABLED;
        } else {
            return Status.ENABLED;
        }
    }
}
