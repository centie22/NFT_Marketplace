import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

require("dotenv").config({ path: ".env" });
module.exports = {
  solidity: "0.8.9",
  networks: {
    alfajores: {
      url: process.env.API_URL,
      accounts: {
        mnemonic: process.env.MNEMONIC_KEYS, // line 25
        path: "m/44'/52752'/0'/0",
      chainId: 44787,
    },
  },
}
}

// import "@nomiclabs/hardhat-ethers";
//  type HttpNetworkAccountUserConfig = any;
// const {API_URL, PRIVATE_KEY} = process.env;
// const config: HardhatUserConfig = {
//   solidity: "0.8.9",
//   defaultNetwork: "goerli",
//   networks:{
//     hardhat:{},
//     goerli:{
//       url: API_URL,
//       accounts:[PRIVATE_KEY] as HttpNetworkAccountUserConfig | undefined,
//     }
//   }
// };

//export default config;
