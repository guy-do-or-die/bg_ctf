// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import "../src/IChallenge4.sol";
import "forge-std/console.sol";

contract Solve4AddMinter is Script {
    function run() external {
        vm.startBroadcast();
        address target = 0x9c4A48Dd70a3219877a252E9a0d45Fc1Db808a1D;
        IChallenge4 challenge = IChallenge4(target);

        address me = msg.sender;
        console.log("Sender:", me);
        console.log("Owner:", challenge.owner());
        console.log("Is Minter:", challenge.isMinter(me));

        if (!challenge.isMinter(me)) {
            console.log("Adding sender as minter...");
            challenge.addMinter(me);
        } else {
            console.log("Sender is already a minter.");
        }

        vm.stopBroadcast();
    }
}
