import { ethers } from "hardhat";

// DEPLOYED CONTRACT ADDRESS: 0xEDa0F98d09656896c8A50d19933aefE75A425c5b
async function main() {
  
  const NFTMart = await ethers.getContractFactory('NFTMart'); //get instance of contract

  const nFTMart = await NFTMart.deploy(); //we deploy with name and symbol of nft as I use constructor
  await nFTMart.deployed();
  console.log('Contract deployed to address:', nFTMart.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
