pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import { TraderjoeV2_1ExactIn } from "./TraderjoeV2_1ExactIn.sol";
import { ILBRouter } from "../../../interfaces/ITraderJoeV2_1Router.sol";
import { IWETH } from "../../../interfaces/IWETH.sol";
import { IERC20 } from "openzeppelin/interfaces/IERC20.sol";
import "../../../utils/bnb/Constants.sol";

contract TraderjoeV2_1ExactInTest is Test {
    uint256 testnetFork;

    // Variables
    address public constant entryPoint = 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789;
    address public owner = 0x2595F7Cd55BedEdaA09e8988a9B4daef5aEaDF82;
    address public dylanAddr = 0x2595F7Cd55BedEdaA09e8988a9B4daef5aEaDF82;
    address public dylanKernel = 0xfda9c831090Eb4E006B54846C435dD333856001E;

    // Token Addresses
    // FUJI Address
    address public usdtToken = 0xBDE7fbbb1DC89E74B73C54Ad911A1C9685caCD83;
    address public wethToken = 0xf97b6C636167B529B6f1D729Bd9bC0e2Bd491848;

    IERC20 public USDT = IERC20(usdtToken);
    IWETH public WETH = IWETH(wethToken);

    address private constant TRADERJOE_V1_ROUTER = 0xb4315e873dBcf96Ffd0acd8EA43f689D8c20fB30;

    ILBRouter private router = ILBRouter(TRADERJOE_V1_ROUTER);

    function setUp() public {
        string memory RPC_URL = vm.envString("RPC_URL_FUJI");
        testnetFork = vm.createFork(RPC_URL);
    }

    function test_success_execute_action_with_token() public {
        // Arrange
        vm.selectFork(testnetFork);
        vm.startPrank(owner);

        TraderjoeV2_1ExactIn actionContract = new TraderjoeV2_1ExactIn();

        deal(address(USDT), address(actionContract), 1 ether);

        // start status
        uint256 startUsdt = USDT.balanceOf(address(actionContract));

        IERC20[] memory tokenPath = new IERC20[](2);
        tokenPath[0] = USDT;
        tokenPath[1] = IERC20(wethToken);

        // pairBinSteps[i] refers to the bin step for the market (x, y) where tokenPath[i] = x and tokenPath[i+1] = y
        uint256[] memory pairBinSteps = new uint256[](1);
        pairBinSteps[0] = 25;

        ILBRouter.Version[] memory versions = new ILBRouter.Version[](1);
        versions[0] = ILBRouter.Version.V1; // the version of the Dex the swap on

        ILBRouter.Path memory path;
        path.pairBinSteps = pairBinSteps;
        path.versions = versions;
        path.tokenPath = tokenPath;

        uint256 tokenInAmount = 30;

        TraderjoeV2_1ExactIn.Params memory params = TraderjoeV2_1ExactIn.Params({
            amountIn: tokenInAmount,
            amountOutMin: 1,
            pairBinSteps: pairBinSteps,
            versions: versions,
            tokenPath: tokenPath,
            to: address(actionContract)
        });

        bytes memory encoded = abi.encode(params);

        // Act
        actionContract.executeActionDirect(encoded);

        uint256 endUsdt = USDT.balanceOf(address(actionContract));

        vm.stopPrank();

        // Assert
        assertEq(startUsdt - endUsdt, tokenInAmount);
    }

    function test_revert_execute_action_with_token_over() public {
        // Arrange
        vm.selectFork(testnetFork);
        vm.startPrank(owner);

        TraderjoeV2_1ExactIn actionContract = new TraderjoeV2_1ExactIn();

        deal(address(USDT), address(actionContract), 100);

        IERC20[] memory tokenPath = new IERC20[](2);
        tokenPath[0] = USDT;
        tokenPath[1] = IERC20(wethToken);

        // pairBinSteps[i] refers to the bin step for the market (x, y) where tokenPath[i] = x and tokenPath[i+1] = y
        uint256[] memory pairBinSteps = new uint256[](1);
        pairBinSteps[0] = 25;

        ILBRouter.Version[] memory versions = new ILBRouter.Version[](1);
        versions[0] = ILBRouter.Version.V1; // the version of the Dex the swap on

        ILBRouter.Path memory path;
        path.pairBinSteps = pairBinSteps;
        path.versions = versions;
        path.tokenPath = tokenPath;

        uint256 tokenInAmount = 1000;

        TraderjoeV2_1ExactIn.Params memory params = TraderjoeV2_1ExactIn.Params({
            amountIn: tokenInAmount,
            amountOutMin: 1,
            pairBinSteps: pairBinSteps,
            versions: versions,
            tokenPath: tokenPath,
            to: address(actionContract)
        });

        bytes memory encoded = abi.encode(params);

        // Act

        vm.expectRevert("Not enough TokenB");
        actionContract.executeActionDirect(encoded);

        vm.stopPrank();

        // Assert
    }

    struct UintVersionParams {
        uint256 amountIn;
        uint256 amountOutMin;
        uint256[] pairBinSteps;
        uint256[] versions;
        IERC20[] tokenPath;
        address to;
    }

    function test_revert_execute_action_with_token_by_wrong_version() public {
        // Arrange
        vm.selectFork(testnetFork);
        vm.startPrank(owner);

        TraderjoeV2_1ExactIn actionContract = new TraderjoeV2_1ExactIn();

        deal(address(USDT), address(actionContract), 100);

        IERC20[] memory tokenPath = new IERC20[](2);
        tokenPath[0] = USDT;
        tokenPath[1] = IERC20(wethToken);

        // pairBinSteps[i] refers to the bin step for the market (x, y) where tokenPath[i] = x and tokenPath[i+1] = y
        uint256[] memory pairBinSteps = new uint256[](1);
        pairBinSteps[0] = 25;

        uint256[] memory versions = new uint256[](1);
        versions[0] = 3; // the version of the Dex the swap on

        uint256 tokenInAmount = 100;

        UintVersionParams memory params = UintVersionParams({
            amountIn: tokenInAmount,
            amountOutMin: 1,
            pairBinSteps: pairBinSteps,
            versions: versions,
            tokenPath: tokenPath,
            to: address(actionContract)
        });

        bytes memory encoded = abi.encode(params);

        // Act

        vm.expectRevert();
        actionContract.executeActionDirect(encoded);

        vm.stopPrank();

        // Assert
    }

    function test_success_execute_action_with_token_by_enum_version() public {
        // Arrange
        vm.selectFork(testnetFork);
        vm.startPrank(owner);

        TraderjoeV2_1ExactIn actionContract = new TraderjoeV2_1ExactIn();

        deal(address(USDT), address(actionContract), 100);

        IERC20[] memory tokenPath = new IERC20[](2);
        tokenPath[0] = USDT;
        tokenPath[1] = IERC20(wethToken);

        // pairBinSteps[i] refers to the bin step for the market (x, y) where tokenPath[i] = x and tokenPath[i+1] = y
        uint256[] memory pairBinSteps = new uint256[](1);
        pairBinSteps[0] = 25;

        uint256[] memory versions = new uint256[](1);
        versions[0] = 0; // the version of the Dex the swap on

        uint256 tokenInAmount = 100;

        UintVersionParams memory params = UintVersionParams({
            amountIn: tokenInAmount,
            amountOutMin: 1,
            pairBinSteps: pairBinSteps,
            versions: versions,
            tokenPath: tokenPath,
            to: address(actionContract)
        });

        bytes memory encoded = abi.encode(params);

        // Act

        actionContract.executeActionDirect(encoded);

        vm.stopPrank();

        // Assert
    }

    struct StringVersionParams {
        uint256 amountIn;
        uint256 amountOutMin;
        uint256[] pairBinSteps;
        bytes[] versions;
        IERC20[] tokenPath;
        address to;
    }

    function test_success_execute_action_with_token_by_string_version() public {
        // Arrange
        vm.selectFork(testnetFork);
        vm.startPrank(owner);

        TraderjoeV2_1ExactIn actionContract = new TraderjoeV2_1ExactIn();

        deal(address(USDT), address(actionContract), 100);

        IERC20[] memory tokenPath = new IERC20[](2);
        tokenPath[0] = USDT;
        tokenPath[1] = IERC20(wethToken);

        // pairBinSteps[i] refers to the bin step for the market (x, y) where tokenPath[i] = x and tokenPath[i+1] = y
        uint256[] memory pairBinSteps = new uint256[](1);
        pairBinSteps[0] = 25;

        bytes[] memory versions = new bytes[](1);
        versions[0] = "V1"; // the version of the Dex the swap on

        uint256 tokenInAmount = 100;

        StringVersionParams memory params = StringVersionParams({
            amountIn: tokenInAmount,
            amountOutMin: 1,
            pairBinSteps: pairBinSteps,
            versions: versions,
            tokenPath: tokenPath,
            to: address(actionContract)
        });

        bytes memory encoded = abi.encode(params);

        // Act
        vm.expectRevert();
        actionContract.executeActionDirect(encoded);

        vm.stopPrank();

        // Assert
    }
}
