import { expect } from "chai";
import { ethers } from "hardhat";
import { Contract, ContractFactory, Signer } from "ethers";

let Token: ContractFactory;
let token: Contract;
let accounts: Signer[];

describe("Token", function () {
  beforeEach(async function () {
    accounts = await ethers.getSigners();

    Token = await ethers.getContractFactory("Token");
    token = await Token.deploy(10000000, "Coin", 0, "COIN");

    await token.deployed();
  });

  it("Should have allocated token supply to owner", async function () {
    const owner = await accounts[0].getAddress();
    expect(await token.balanceOf(owner).to.equal(10000000));
  });

  it("Should be able to transfer tokens to another account", async function () {
    const owner = await accounts[0].getAddress();
    const receiver = await accounts[1].getAddress();

    await token.transfer(receiver, 5);
    expect(await token.balanceOf(receiver).to.equal(5));
  });

  it("Should be able to approve allowance for spender account", async function () {
    const owner = await accounts[0].getAddress();
    const spender = await accounts[1].getAddress();

    await token.approve(spender, 10);
    expect(await token.allowance(owner, spender).to.equal(10));
  });

  it("Should be able to spend on behalf of another account after getting the approval", async function () {
    const owner = await accounts[0].getAddress();
    const spender = await accounts[1].getAddress();
    const receiver = await accounts[2].getAddress();

    await token.approve(spender, 10);
    await token.connect(accounts[1]).transferFrom(owner, receiver, 10);
    expect(await token.allowance(owner, receiver).to.equal(10));
  });
});
