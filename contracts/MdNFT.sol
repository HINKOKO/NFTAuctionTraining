// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";

contract MdNFT is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;
	uint256 public maxSupply = 1000;
	mapping(address => bool) public validTargets;
	mapping(uint256 => bool) public nftIsBurned;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("Multi Deactive", "MD") {}

	modifier onlyValidTargets() {
		require(validTargets[msg.sender] == true, "you are not valid target");
		_;
	}

	function setValidTarget(address _target, bool _permission) public onlyOwner {
		validTargets[_target] = _permission;
	}

    function mintValidTarget(address to, string memory uri) public onlyValidTargets returns(uint256) {
		require(totalSupply() < maxSupply, "MdNFT: max total supply reached");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        return tokenId;
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
		nftIsBurned[tokenId] = true;
        super._burn(tokenId);
    }

	function setTokenURI(uint256 _tokenId, string memory _tokenURI) public onlyOwner {
		_setTokenURI(_tokenId, _tokenURI);
	}

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
