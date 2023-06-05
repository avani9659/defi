import { ethers, upgrades } from "hardhat";

async function upgrade() {
  const GOVERNANCE_ADDRESS = "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9";

  const GovernanceV2 = await ethers.getContractFactory("Governance");
  //since we want to update the contract, we use upgradeProxy to do that
  const governance = await upgrades.upgradeProxy(
    GOVERNANCE_ADDRESS,
    GovernanceV2
  );

  console.log(
    "Governance contract upgraded. Contract is deployed at address: " +
      governance.address
  );
}

upgrade().catch((error) => {
  console.log(error);
  process.exitCode = 1;
});
