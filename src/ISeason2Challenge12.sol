// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface ISeason2Challenge12 {
    function nftContract() external view returns (address);
    function challenge12Inventory() external view returns (address);
    function challenge12Quest() external view returns (address);
    function challenge12Dungeon() external view returns (address);
    function challenge12Victory() external view returns (address);
    function challenge12GoldToken() external view returns (address);
    function challenge12HeroNFT() external view returns (address);
    function mintFlag(uint256 tokenId) external;
}

interface ISeason2Challenge12GoldToken {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function mint(address to) external;
    function burn(uint256 amount) external;
}

interface ISeason2Challenge12HeroNFT {
    function mint(string memory tokenURI) external returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface ISeason2Challenge12Inventory {
    function inventory(address user) external view returns (uint256);
    function setValue(uint256 value) external;
}

interface ISeason2Challenge12Quest {
    function quest(address user) external view returns (uint256);
    function setCurrentQuest(uint256 value) external;
}

interface ISeason2Challenge12Dungeon {
    function dungeon(address user) external view returns (bytes32);
    function setPosition(bytes32 value) external;
    function getCurrentPosition() external view returns (uint256);
}

interface ISeason2Challenge12Victory {
    function victory(address user) external view returns (bool);
    function free(bool value) external;
    function winner() external view returns (bool);
}
