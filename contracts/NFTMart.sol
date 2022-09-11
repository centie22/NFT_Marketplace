//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTMart is ERC721URIStorage{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenId;
    Counters.Counter private _itemsSold;

    constructor ()

uint listingPrice = 0.02 ether;

struct listedTokens{
    uint tokenId;
    address payable tokenOwner;
    address payable sender;
    uint tokenPrice;
    bool listed;
}

mapping (uint => listedTokens) private listedTokentrack;

function updateListPrice(uint _listingPrice) public {
    _listingPrice = listingPrice;
}


}