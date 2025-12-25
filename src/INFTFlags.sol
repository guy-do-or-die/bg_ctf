// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface INFTFlags {
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) external;
    function ownerOf(uint256 tokenId) external view returns (address);
    function tokenIdToChallengeId(uint256 tokenId) external view returns (uint256);
    function tokenIdCounter() external view returns (uint256);
    function mint(address to, uint256 challengeId) external;
}
