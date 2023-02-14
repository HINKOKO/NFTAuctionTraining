// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IMdNFT is IERC721 {
	function mintValidTarget(address to, string memory uri) external returns (uint256);
	function burn(uint256 tokenId) external;
}
