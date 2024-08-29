// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require('hardhat')
let launchpad, launchapToken, stakingToken, airdrop
async function main() {
  const LaunchapToken = await ethers.getContractFactory('LaunchapToken')
  launchapToken = await LaunchapToken.deploy()
  await launchapToken.deployed()

  const StakingToken = await ethers.getContractFactory('StakingToken')
  stakingToken = await StakingToken.deploy()
  await stakingToken.deployed()

  const Launchpad = await ethers.getContractFactory('Launchpad')
  const tx = (launchpad = await Launchpad.deploy())
  await launchpad.deployed()
  const Airdrop = await ethers.getContractFactory('Airdrop')
  airdrop = await Airdrop.deploy()
  await airdrop.deployed()
  console.log(tx)
  console.log('launchapToken:' + launchapToken.address)
  console.log('stakingToken:' + stakingToken.address)
  console.log('launchpad:' + launchpad.address)
  console.log('airdrop:' + airdrop.address)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch(error => {
  console.error(error)
  process.exitCode = 1
})
