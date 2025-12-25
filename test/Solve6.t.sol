// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Test.sol";
import "../src/Solver6.sol";
import "../src/IChallenge6.sol";

contract Solve6Test is Test {
    Solver6 solver;
    address target = 0x75961D2da1DEeBaEC24cD0E180187E6D55F55840;

    function setUp() public {
        vm.createSelectFork("https://mainnet.optimism.io");
        solver = new Solver6();
    }

    function testFindGas() public {
        // Mock NFTFlags.mint to pass "already minted" or "not registered" checks
        address nftFlags = 0xc1Ebd7a78FE7c075035c516B916A7FB3f33c26cE;
        // mint(address,uint256) selector
        vm.mockCall(nftFlags, abi.encodeWithSignature("mint(address,uint256)"), "");

        // Broad range to ensure we find a working gas value
        // Let's sweep from 196,000 to 198,000
        for (uint256 g = 196000; g < 198000; g += 1) {
            try solver.solve(target, g) {
                console.log("SUCCESS with gas:", g);
                return;
            } catch Error(string memory reason) {
                console.log("Failed with gas:", g, reason);
            } catch (bytes memory) {
                console.log("Failed with gas:", g, "unknown");
            }
        }
        revert("Could not find working gas");
    }
}
