// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract FoxiverseSkidoo is ERC721, ERC721URIStorage, Pausable, Ownable, ERC721Burnable {
  using Counters for Counters.Counter;

  Counters.Counter private _tokenIdCounter;

  constructor() ERC721("Skidoo", "SKIDOO") {}

  function pause() public onlyOwner {
    _pause();
  }


  function unpause() public onlyOwner {
    _unpause();
  }

  function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
    super._burn(tokenId);
  }

  function tokenURI(uint256 tokenId)
  public
  view
  override(ERC721, ERC721URIStorage)
  returns (string memory)
  {
    return super.tokenURI(tokenId);
  }


  struct MarketItem {
    uint256 tokenId;
    string uri;
    address payable owner;
  }
  mapping(uint256 => MarketItem) private idToMarketItem;
  mapping(uint256 => uint256) private mintingPrices;

  mapping(address => bool) minters;
  function grantMintingRole(address _address) public onlyOwner{
    require(!minters[_address], "Address already added");
    minters[_address] = true;
  }

  function mintHero(string memory uri) public payable returns (uint) {
    require(minters[msg.sender], "You are not a valid minter");
    _tokenIdCounter.increment();
    uint256 newTokenId = _tokenIdCounter.current();
    _mint(msg.sender, newTokenId);
    _setTokenURI(newTokenId, uri);
    string memory tURI = string(tokenURI(newTokenId));
    idToMarketItem[newTokenId] = MarketItem(
    newTokenId,
    tURI,
    payable(msg.sender)
    );
    address _owner = super.owner();
    payable(_owner).transfer(msg.value);
    return newTokenId;
  }

  function bulkMint(uint256 count, string[] memory jsonUri) public payable{
    for (uint i = 0; i < count; i++) {
      require(minters[msg.sender], "You are not a valid minter");
      _tokenIdCounter.increment();
      uint256 newTokenId = _tokenIdCounter.current();
      _mint(msg.sender, newTokenId);
      _setTokenURI(newTokenId, jsonUri[i]);
      string memory tURI = string(tokenURI(newTokenId));
      idToMarketItem[newTokenId] = MarketItem(
      newTokenId,
      tURI,
      payable(msg.sender)
      );
      //      string memory url = string(abi.encodePacked(jsonUri, Strings.toString(i), ".json"));
      //      mintLand(jsonUri[i]);
    }
    address _owner = super.owner();
    payable(_owner).transfer(msg.value);
  }

  function transferTo(address to, uint tokenId) public {
    safeTransferFrom(msg.sender, to, tokenId);
    idToMarketItem[tokenId].owner = payable(to);
  }
  function bulkTransfer(uint256 count, address[] memory to, uint[] memory tokenIds) public {
    for(uint i = 0; i < count; i++) {
      safeTransferFrom(msg.sender, to[i], tokenIds[i]);
      idToMarketItem[tokenIds[i]].owner = payable(to[i]);
    }
  }

  function fetchAllNFTs() public view returns (MarketItem[] memory) {
    uint itemCount = _tokenIdCounter.current();
    uint currentIndex = 0;

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint i = 0; i < itemCount; i++) {
      uint currentId = i + 1;
      MarketItem storage currentItem = idToMarketItem[currentId];
      items[currentIndex] = currentItem;
      currentIndex += 1;
    }
    return items;
  }

  function fetchNFTs(uint from, uint to) public view returns (MarketItem[] memory) {
    uint itemCount = to - from;
    uint currentIndex = 0;

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint i = from; i < to; i++) {
      MarketItem storage currentItem = idToMarketItem[i];
      items[currentIndex] = currentItem;
      currentIndex += 1;
    }
    return items;
  }

  function fetchMyNFTs() public view returns (MarketItem[] memory) {
    uint totalItemCount = _tokenIdCounter.current();
    uint itemCount = 0;
    uint currentIndex = 0;

    for (uint i = 0; i < totalItemCount; i++) {
      if (ownerOf(i + 1) == msg.sender) {
        itemCount += 1;
      }
    }

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint i = 0; i < totalItemCount; i++) {
      if (ownerOf(i + 1) == msg.sender) {
        uint currentId = i + 1;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }
}
