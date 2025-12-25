// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./IChallenge6.sol";

contract Solver6 {
    bool public success; // Debugging flag

    function name() external pure returns (string memory) {
        return "BG CTF Challenge 6 Solution";
    }

    function solve(address _target, uint256 _gasLimit) external {
        IChallenge6 targetContract = IChallenge6(_target);
        uint256 count = targetContract.count();
        uint256 code = count << 8;

        bytes memory data = abi.encodeWithSelector(IChallenge6.mintFlag.selector, code);

        assembly {
            // call(gas, addr, value, argsOffset, argsLength, retOffset, retLength)
            // We use the passed _gasLimit explicitly.
            let result := call(_gasLimit, _target, 0, add(data, 0x20), mload(data), 0, 0)

            if iszero(result) {
                // If the call failed, revert to bubble up the error (useful for debugging)
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }
    }
}
