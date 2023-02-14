const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('MdToken Testing', async () => {
  let owner;
  let addr1;
  let addrs;
  let tokenContract;

  beforeEach(async () => {
    [owner, addr1, ...addrs] = await ethers.getSigners();
    let tokenFactory = await ethers.getContractFactory('MdToken');
    tokenContract = await tokenFactory.deploy();
  });

  it('Deploy smart contract success', async () => {
    console.log(tokenContract.address);
    console.log('ABCXYZ');
    console.log(tokenContract);
  });

  it('should show that totalSupply is 10^26 and equal to balance owner', async () => {
    console.log('Owner', owner);
    const ownerAmount = await tokenContract.balanceOf(owner.address);
    console.log(ownerAmount);
    const totalSupply = await tokenContract.totalSupply();
    expect(ownerAmount).to.be.eq(totalSupply);
  });

  it('Should fail if you mint token with different account', async () => {
    const tx = tokenContract.connect(addr1).mint(addr1.address, 5000);
    await expect(tx).to.be.reverted;
  });
});
