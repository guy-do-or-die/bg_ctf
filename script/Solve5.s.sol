// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import "../src/Solver5.sol";

contract Solve5Script is Script {
    function run() external {
        vm.startBroadcast();
        address target = 0xB76AdFe9a791367A8fCBC2FDa44cB1a2c39D8F59;
        Solver5 solver = new Solver5(target);

        // The solver contract needs to be the one calling claimPoints if the logic was msg.sender,
        // BUT Challenge5 checks `points[tx.origin]`.
        // Wait, if it checks `points[tx.origin]`, then `tx.origin` is ME.
        // `challenge.claimPoints()` is called by `Solver` (msg.sender).
        // `points[tx.origin]` refers to ME.
        // So the points are credited to ME.
        // And `mintFlag` checks `points[tx.origin]`.
        // So `Solver` calling `mintFlag` will work if I am the `tx.origin`.

        solver.solve();

        vm.stopBroadcast();
    }
}
