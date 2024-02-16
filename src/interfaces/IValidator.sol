// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { UserOperation } from "./UserOperation.sol";
import { ValidationData } from "kernel/common/Types.sol";

interface IValidator {
    error NotImplemented();

    event OwnerChanged(address indexed kernel, address indexed oldOwner, address indexed newOwner);

    struct Metadata {
        address owner;
        bool enabled;
    }

    enum Status {
        ENABLED,
        DISABLED,
        NOT_ADDED
    }

    function enable(bytes calldata _data) external payable;
    function disable(bytes calldata) external payable;
    function validateUserOp(
        UserOperation calldata _userOp,
        bytes32 _userOpHash,
        uint256
    )
        external
        payable
        returns (ValidationData validationData);
    function validateSignature(bytes32 hash, bytes calldata signature) external view returns (ValidationData);
    function validCaller(address _caller, bytes calldata) external view returns (bool);
    function activate() external;
    function deactivate() external;
    function getStatus(address _user) external view returns (Status);
}
