require('@nomicfoundation/hardhat-toolbox')
require('hardhat-abi-exporter')

let dotenv = require('dotenv')
dotenv.config({ path: './.env' })

const privatekey = process.env.PRIVATEKEY

module.exports = {
  solidity: '0.8.20',
  networks: {
    hardhat: {
      chainId: 1337,
    },
    dev: {
      url: 'http://127.0.0.1:8545',
      chainId: 1337,
      gas: 30000000,
    },
    // chain: {
    //   url: 'https://pacific-rpc.sepolia-testnet.manta.network/http',
    //   chainId: 3441006,
    //   accounts: [privatekey],
    //   gas: 30000000,
    // },
    // mumbai: {
    //   url: 'https://polygon-mumbai-bor-rpc.publicnode.com',
    //   chainId: 80001,
    //   accounts: [privatekey],
    //   gas: 30000000,
    // },
    edu: {
      url: 'https://rpc.open-campus-codex.gelato.digital',
      chainId: 656476,
      accounts: [privatekey],
      gas: 30000000,
    },
  },
  abiExporter: [
    {
      path: './abi',
      format: 'json',
    },
  ],
}
