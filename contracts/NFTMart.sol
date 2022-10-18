//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract NFTMart is ERC721URIStorage, ReentrancyGuard{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenId;
    Counters.Counter private _itemsSold;

    address payable owner;
    address celoToken = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;

    constructor () ERC721("NFTMart", "NftM") {
        owner = payable(msg.sender);
    }

uint listingPrice;
bool listPrice;


struct listedTokens {
    uint tokenId;
    address payable martOwner;
    address payable NFTowner;
    uint tokenPrice;
    bool listed;
}
/*Mapping tokenId to Listed NFTs*/
mapping (uint => listedTokens) private listedTokentrack;

/*Event for NFT listing */
event NFTlisted(
    uint indexed tokenId,
    address martOwner,
    address NFTowner,
    uint tokenPrice,
    bool listed

);
/*Modifier set to restrict access to certain functions */
modifier onlyOwner () {
     require(msg.sender == owner, "Only owner can update Listing price");
     _;
}
/*Function set for only contract owner to update listing price*/ 
function updateListingPrice(uint _listingPrice) public payable onlyOwner{
    listingPrice = _listingPrice;
    listPrice = true;
}

function showContractTokenBal () public view returns(uint) {
    uint bal = IERC20(celoToken).balanceOf(address(this));
    return bal;
}
/*Function set for seller to deposit celoUSD for listing price */
function depositCelo () internal {
    IERC20(celoToken).transferFrom(msg.sender, address(this), listingPrice );
} 

/*Function set for owner to withdraw cUSD from the contract */
function withdrawCelo (uint amount, address to) external onlyOwner{
    require(to != address(0), "You can't withdraw to this address"); 
    IERC20(celoToken).transferFrom(address(this), to, amount);
}
/*Function set for users to view cost of listing on the marketplace*/
function seeListingPrice() public view returns(uint){
    return listingPrice;
}

/*Function to get a listed NFT */
function getAListedToken(uint NFTId) external view returns(listedTokens memory){
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
    require(listPrice == true, "You cannot list yet");
    depositCelo();
    require(tokenPrice >= listingPrice, "Price less then listing price");
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

/*emitting the listing event */
emit NFTlisted(
    tokenId, 
address(this),
 msg.sender, 
 tokenPrice, 
 true
 );
}
/*Function set to return all NFTs up for sale on this marketplace */
function viewAllNFTs() public view returns(listedTokens[] memory){
    uint noOfNfts = _tokenId.current();
    listedTokens[] memory NFTs = new listedTokens[](noOfNfts);
    uint index = 0;
    uint id;

    for (uint i = 0; i < noOfNfts; i++) {
        id = i + 1;
        listedTokens storage currentNFT = listedTokentrack[id];
        NFTs[index] = currentNFT;
        index += 1;
    }
    return NFTs;
}
/*Function for buying listed NFTs */
function buyNFT(uint256 NFTid) public payable nonReentrant{
    /*setting variables for the NFT price and the seeler of the NFT */
    uint nftPrice = listedTokentrack[NFTid].tokenPrice;
    address seller = listedTokentrack[NFTid].NFTowner;

    /*Transferring the value paid for the NFT to the seller */
    IERC20(celoToken).transferFrom(msg.sender, seller, nftPrice);
    
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
    depositCelo();
    // require (IERC20(celoToken) == listingPrice, "Listing price requirement not met");
    require(price > 0, "Price of NFT cannot be 0 celo!");
   bool  list = listedTokentrack[NFTid].listed;
    price = listedTokentrack[NFTid].tokenPrice;

    list = true;
}
}