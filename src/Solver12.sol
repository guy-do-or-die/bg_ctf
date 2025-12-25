// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./IChallenge12.sol";

contract Solver12 {
    address public target;

    constructor(address _target) {
        target = _target;
    }

    function step1() external {
        IChallenge12(target).preMintFlag();
    }

    function step2(bytes memory rlp) external {
        // Try to mint
        IChallenge12(target).mintFlag(rlp);

        // Check if we received it
        // We need the NFT address. We can get it from Challenge12 public variable?
        // Or we hardcode it since it's known: 0xc1Ebd7a78FE7c075035c516B916A7FB3f33c26cE
        address nftAddr = 0xc1Ebd7a78FE7c075035c516B916A7FB3f33c26cE;

        // Check balance
        (bool success, bytes memory data) =
            nftAddr.staticcall(abi.encodeWithSignature("balanceOf(address)", address(this)));
        require(success, "Balance check failed");
        uint256 bal = abi.decode(data, (uint256));

        require(bal > 0, "Mint failed: Balance is 0");

        // Transfer to tx.origin (me)
        // assuming standard ERC721 transferFrom(from, to, tokenId)
        // Challenge 12 token ID is 12? Or is it auto-increment?
        // Challenge contract says: mint(msg.sender, 12). So ID is 12.

        (success,) = nftAddr.call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", address(this), tx.origin, 12)
        );
        require(success, "Transfer failed");
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
