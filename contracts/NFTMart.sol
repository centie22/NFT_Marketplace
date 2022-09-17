//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTMart is ERC721URIStorage, ReentrancyGuard{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenId;
    Counters.Counter private _itemsSold;

    address payable owner;

    constructor () ERC721("NFTMart", "NftM"){
        owner = payable(msg.sender);
    }

uint listingPrice = 0.02 ether;

struct listedTokens {
    uint tokenId;
    address payable martOwner;
    address payable NFTowner;
    uint tokenPrice;
    bool listed;
}
/*Mapping tokenId to Listed NFTs*/
mapping (uint => listedTokens) private listedTokentrack;

/*Function set for only contract owner to update listing price*/ 
function updateListingPrice(uint _listingPrice) public payable {
    require(msg.sender == owner, "Only owner can update Listing price");
    _listingPrice = listingPrice;
}
/*Function set for users to view cost of listing on the marketplace*/
function seeListingPrice() public view returns(uint){
    return listingPrice;
}

/*Function to get a listed NFT */
function getAListedToken(uint NFTId) public view returns(listedTokens memory){
    return listedTokentrack[NFTId];
}

/*Function to get the most recent token Id */
function currentListedTokenId() public view returns(uint){
    return _tokenId.current();
}

/*Function to get the listed token of current Id */
function currentListedToken() public view returns(listedTokens memory){
    uint currentlistedtokenId = _tokenId.current();
    return listedTokentrack[currentlistedtokenId];

}


/*Function to create token/list a token on the marketplace */
function createToken(string memory tokenURI, uint tokenPrice) public payable nonReentrant returns(uint) {
    require(msg.value == listingPrice, "Price less then listing price");
    require(tokenPrice >0, "Nft price cannot be 0 ether");

    /*Set new token id by increasing the previous id  */
    _tokenId.increment();
    uint currentlistedtokenId = _tokenId.current();

    /*Mint the NFT to the address of the sender */
    _safeMint(msg.sender, currentlistedtokenId);
    /*connect id to the token URI */
    _setTokenURI(currentlistedtokenId, tokenURI);
    
    createlistedToken(currentlistedtokenId, tokenPrice);
    return currentlistedtokenId;
}

/*Function to create the objet type listedToken*/
function createlistedToken(uint tokenId, uint tokenPrice) private{
    listedTokentrack[tokenId] = listedTokens(
        tokenId, payable(address(this)), payable(msg.sender), tokenPrice, true
    );
    /*After creating the object, the token is transferred to the Marketplace contract */
    _transfer(msg.sender, address(this), tokenId);
}

function buyNFT(uint256 NFTid) public payable nonReentrant{
    /*setting variables for the NFT price and the seeler of the NFT */
    uint nftPrice = listedTokentrack[NFTid].tokenPrice;
    address payable seller = listedTokentrack[NFTid].NFTowner;
    require (msg.value == nftPrice, "Not enough Ether to pay for this NFT");
/*Transfer the listing price to the mart owner */
    payable(owner).transfer(listingPrice);

    /*Transferring the value paid for the NFT to the seller */
    payable(seller).transfer(msg.value);

    /*Approve the Marketplace to send the NFT to the buyer in order to transfer the token to the buyer */
    approve(address(this), NFTid);

    /*Transfer the NFT to the buyer */
    transferFrom(address(this), msg.sender, NFTid);

    /*Unlist NFT from marketplace*/
    listedTokentrack[NFTid].listed = false;

    /*Update the number of items sold by increasing it*/
    _itemsSold.increment();

    /*Set the buyer as the new seller of the NFT */
    listedTokentrack[NFTid].NFTowner = payable (msg.sender);

}

/*If the buyer of the token wishes to re-list the token on the marketplacd for sale, then 
buyer can call this function */
function relistForSale (uint NFTid, uint price) public payable {
    require (msg.value == listingPrice, "Listing price requirement not met");
    require(price > 0, "Price of NFT cannot be 0 ether!");
   bool  list = listedTokentrack[NFTid].listed;
    price = listedTokentrack[NFTid].tokenPrice;

    list = true;
}
}