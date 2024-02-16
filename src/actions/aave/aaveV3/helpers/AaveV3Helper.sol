// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./FujiAaveV3Addresses.sol";
import { IPoolAddressesProvider } from "aaveV3/interfaces/IPoolAddressesProvider.sol";

contract AaveV3Helper is FujiAaveV3Addresses {
    IPoolAddressesProvider constant poolAddressProvider = IPoolAddressesProvider(AAVE_V3_ADDRESS_PROVIDER);

    function boolToBytes(bool x) internal pure virtual returns (bytes1 r) {
        return x ? bytes1(0x01) : bytes1(0x00);
    }

    function bytesToBool(bytes1 x) internal pure virtual returns (bool r) {
        return x != bytes1(0x00);
    }
}
