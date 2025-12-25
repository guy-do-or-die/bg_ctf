// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import "../src/Solver.sol";

contract SolveScript is Script {
    function run() external {
        // uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY"); 
        // User said: "let's use Foundry keystore's default key for deployment" 
        // usually that means no private key arg if using `cast wallet` or just `vm.startBroadcast()` without args implies default sender?
        // Actually, for scripts, `vm.startBroadcast()` uses the `--sender` or default account derived from mnemonic/private key passed via CLI.
        // If the user wants to use "Foundry keystore's default key", they usually mean the account unlocked via `cast wallet import` or similar, 
        // referenced by `--account <account_name>`.
        // I will just use `vm.startBroadcast()` and let the CLI handle the signer.

        vm.startBroadcast();

        address target = 0x0b997E0a306c47EEc755Df75fad7F41977C5582d;
        new Solver(target);

        vm.stopBroadcast();
    }
}
