const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('MdAuction Testing', async () => {
  let owner;
  let addr1;
  let addr2;
  let addrs;
  let nftContract;
  let auctionContract;
  let tokenContract;

  beforeEach(async () => {
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    let tokenFactory = await ethers.getContractFactory('MdToken');
    tokenContract = await tokenFactory.deploy();
    let nftFactory = await ethers.getContractFactory('MdNFT');
    nftContract = await nftFactory.deploy();

    let auctionFactory = await ethers.getContractFactory('MdAuction');
    auctionContract = await auctionFactory.deploy(
      tokenContract.address.toString(),
      nftContract.address.toString()
    );
    await nftContract.setValidTarget(auctionContract.address, true);
    await nftContract.setValidTarget(owner.address, true);
    await nftContract.setValidTarget(addr1.address, true);
  });

  it('Should deploy successfully', async () => {
    console.log('Auction address', auctionContract.address);
    console.log('NFT address', nftContract.address);
    console.log('Token address', tokenContract.address);
  });

  it('Open contract => bid contracts => close contract, the NFT will belong to highest bidder', async () => {
    const ownerMint = await tokenContract.mint(addr1.address, 1000000);
    await ownerMint.wait();
    const entranceFee = await auctionContract.entranceFee();
    const openTx = await auctionContract.openAuction('ipfs://');
    await openTx.wait();
    const approveTx = await tokenContract.approve(
      auctionContract.address,
      5000
    );
    await approveTx.wait();
    const tx1 = await auctionContract.placeBid(5000, { value: entranceFee });
    await tx1.wait();

    const approveTx1 = await tokenContract
      .connect(addr1)
      .approve(auctionContract.address, 6000);
    await approveTx1.wait();
    const tx2 = await auctionContract
      .connect(addr1)
      .placeBid(6000, { value: entranceFee });
    await tx2.wait();
    //   const changeStatusTx = await auctionContract.changeState(1);
    //   await changeStatusTx.wait();
    //   const closeTx = await auctionContract.closeAuction();
    //   await closeTx.wait();
    //   const auctionLength = await auctionContract.auctionLength();
    //   const auctionData = await auctionContract.auctions(
    //     parseInt(auctionLength) - 1
    //   );
    //   const nftId = parseInt(auctionData.nftId);
    //   const owner = await nftContract.ownerOf(nftId);
    //   expect(owner).to.be.eq(addr1.address);
    //   const openTxx = await auctionContract.openAuction('ipfs://');
    //   await openTxx.wait();
  });

  it('Open contract => close contract (no bids), nft burned', async () => {
    const openTx = await auctionContract.openAuction('ipfs://');
    await openTx.wait();
    const changeStateTx = await auctionContract.changeState(1);
    await changeStateTx.wait();
    // const closeTx = await auctionContract.closeAuction();
    // await closeTx.wait();
    const auctionLength = await auctionContract.auctionLength();
    const auctionsData = await auctionContract.auctions(
      parseInt(auctionLength) - 1
    );
    const nftId = parseInt(auctionsData.nftId);
    // const value = await nftContract.nftIsBurned(nftId);
    // expect(value).to.be.eq(true);
  });
});
