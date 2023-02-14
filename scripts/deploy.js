// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require('hardhat');

async function main() {
  const MdNFT = await ethers.getContractFactory('MdNFT');
  const nftContract = await MdNFT.deploy();
  const MdToken = await ethers.getContractFactory('MdToken');
  const tokenContract = await MdToken.deploy();
  const MdAuction = await ethers.getContractFactory('MdAuction');
  const auctionContract = await MdAuction.deploy(
    tokenContract.address,
    nftContract.address
  );
  await nftContract.deployed();
  await tokenContract.deployed();
  await auctionContract.deployed();
  await nftContract.setValidTarget(auctionContract.address, true);
  console.log('Token deployed to: ', tokenContract.address);
  console.log('NFT deployed to: ', nftContract.address);
  console.log('Auction deployed to: ', auctionContract.address);
}

// Token deployed to: 0x59976B30176A2c5b2ba6F0D35cFbA5182C015c87
// NFT deployed to: 0xEbB7fAeD3e45117CdD15c31E30245b48bEb89564
// Auction deployed to: 0x82Ff9b651aEBD06Eb941fd682f0bC2c87C525026

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
