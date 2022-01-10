require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-solhint");

const ROPSTEN_PRIVATE_KEY =
  "c4348d2683fb302c319a7854bc1adb940ae5633e277ea464945b292518863e5a";

module.exports = {
  solidity: "0.8.0",
  settings: {
    optimizer: {
      enabled: true,
      runs: 1,
    },
  },
  networks: {
    ropsten: {
      url: "https://ropsten.infura.io/v3/9c38c0f8900e4335a68282d4a29af940",
      accounts: [`${ROPSTEN_PRIVATE_KEY}`],
    },
    rinkeby: {
      url: "https://rinkeby.infura.io/v3/9c38c0f8900e4335a68282d4a29af940",
      accounts: [`${ROPSTEN_PRIVATE_KEY}`],
    },
  },
};
