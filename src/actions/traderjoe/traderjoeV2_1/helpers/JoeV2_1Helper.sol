// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./FujiTraderjoeV2_1Addresses.sol";

import { ILBRouter } from "../../../../interfaces/ITraderJoeV2_1Router.sol";

contract JoeV2_1Helper is FujiTraderjoeV2_1Addresses {
    ILBRouter public constant router = ILBRouter(JOE_V2_1_ROUTER_ADDR);
}
