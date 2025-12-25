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
        // Check finding gas in a broad range logic
        // We want gas inside to be 190,000 < g < 200,000.
        // So we probably need to send 190,000 + overhead.
        
        // Let's sweep from 190,000 to 210,000
        for (uint256 g = 197000; g < 197200; g += 1) {
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
