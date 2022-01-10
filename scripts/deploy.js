const hre = require("hardhat");

async function main() {
  await hre.run("compile");

  // We get the contract to deploy
  const BondingCurveTokenFactoryContract = await hre.ethers.getContractFactory(
    "BondingCurveTokenFactory"
  );
  const BondingCurveTokenFactory =
    await BondingCurveTokenFactoryContract.deploy();

  await BondingCurveTokenFactory.deployed();

  console.log(
    "BondingCurveTokenFactory deployed to:",
    BondingCurveTokenFactory.address
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
