const { ethers } = require('ethers')
const Launchpad = require('../abi/Launchpad.json')

const LaunchpadAbi = Launchpad.abi
const LaunchpadAddress = '0x2Fd9C7b10Db952F5aEF98A2Bd571f1ed4247eBcC'
const apiULR = 'https://pacific-rpc.sepolia-testnet.manta.network/http'
const apiURL2 = 'http://127.0.0.1:8545'

var init = function () {
  const provider = new ethers.providers.JsonRpcProvider(apiULR)
  const contract = new ethers.Contract(LaunchpadAddress, LaunchpadAbi, provider)
  const AddLaunchpadEvent = 'AddLaunchpad'
  const ClaimEvent = 'Claimed'
  const StakeEvent = 'Staked'
  const UnStakeEvent = 'UnStaked'
  contract.on(AddLaunchpadEvent, (launchpadId, launchedAddress, chainId, name, event) => {
    console.log(`AddLaunchpad event triggered - launchpadId: ${launchpadId}, launchedAddress: ${launchedAddress}, chainId: ${chainId}, name: ${name}`)
    //      console.log("Event details:", event);
  })

  contract.on(ClaimEvent, (userAddress, launchpadId, points, token, amount, timestamp, chainId, event) => {
    console.log(
      `Claimed event triggered - userAddress: ${userAddress}, launchpadId: ${launchpadId}, points: ${points}, token: ${token}, amount: ${amount}, timestamp: ${timestamp}, chainId: ${chainId}`
    )
    //      console.log("Event details:", event);
  })
  contract.on(StakeEvent, (userAddress, launchpadId, index, token, amount, timestamp, chainId, event) => {
    console.log(`Staked event triggered - userAddress: ${userAddress}, launchpadId: ${launchpadId}, index: ${index}, token: ${token}, amount: ${amount}, timestamp: ${timestamp}, chainId: ${chainId}`)
    //      console.log("Event details:", event);
  })
  contract.on(UnStakeEvent, (userAddress, launchpadId, index, token, amount, timestamp, chainId, event) => {
    console.log(
      `UnStaked event triggered - userAddress: ${userAddress}, launchpadId: ${launchpadId}, index: ${index}, token: ${token}, amount: ${amount}, timestamp: ${timestamp}, chainId: ${chainId}`
    )
    //      console.log("Event details:", event);
  })
}

init()
