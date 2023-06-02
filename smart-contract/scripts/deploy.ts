import { ethers, upgrades } from "hardhat";

async function main() {
  //---------------------- Token smart contract deployment ------------------//
  const tokenSupply = 1000000;
  const tokenName = "GradCoin";
  const tokenDecimals = 0;
  const tokenSymbol = "GRAD";

  const Token = await ethers.getContractFactory("Token");
  const token = await Token.deploy(
    tokenSupply,
    tokenName,
    tokenDecimals,
    tokenSymbol
  ); //deployed instance of smart contract

  await token.deployed(); //wait till the deployment of token is completed.

  console.log("Token deployment successful at: " + token.address);

  //------------------ Governance smart contract deployment -----------------//
  const flaggingTreshold = 5;

  const Governance = await ethers.getContractFactory("Governance");
  //pass the parameters taken by 'inititalize' method
  const governance = await upgrades.deployProxy(Governance, [flaggingTreshold]); //since this is an upgradeable smart contract

  await governance.deployed();
  console.log(
    "Governance upgradeable contract deployed at: " + governance.address
  );

  //------------------- DeFi Platform smart contract deployment ------------------//
  const DeFiPlatform = await ethers.getContractFactory("DeFiPlatform");
  const defiplatform = await DeFiPlatform.deploy(governance.address);

  await defiplatform.deployed();
  console.log("DeFi Platform contract deployed at: " + defiplatform.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
