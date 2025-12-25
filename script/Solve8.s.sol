// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";

contract Solve8Script is Script {
    function run() external {
        vm.startBroadcast();
        address target = 0x663145aA2918282A4F96af66320A5046C7009573;
        
        // Function selector: 0x8fd628f0
        // Argument: uint256(uint160(msg.sender))
        
        // Sender from Challenge 4 logs: 0x830bc5551e429DDbc4E9Ac78436f8Bf13Eca8434
        address me = 0x830bc5551e429DDbc4E9Ac78436f8Bf13Eca8434;
        bytes memory data = abi.encodeWithSelector(
            0x8fd628f0, 
            uint256(uint160(me))
        );
        
        (bool success, ) = target.call(data);
        require(success, "Call failed");

        vm.stopBroadcast();
    }
}
