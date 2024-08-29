const { expect } = require("chai");
const { StandardMerkleTree } = require("@openzeppelin/merkle-tree");
const fs = require("fs");
const { log } = require("console");

let _name = "MyStakingPool";
let _startTime = Math.floor(Date.now() / 1000);
let _endTime = _startTime + 3600;
let _LowStakingAmount = ethers.utils.parseUnits("10", 18);
let _totalAllocation = ethers.utils.parseUnits("1000", 18);

let launchpad, launchapToken, stakingToken, airdrop;
describe("Test", function () {
  async function init() {
    const [owner, owner2] = await ethers.getSigners();

    const LaunchapToken = await ethers.getContractFactory("LaunchapToken");
    launchapToken = await LaunchapToken.deploy();
    await launchapToken.deployed();

    const StakingToken = await ethers.getContractFactory("StakingToken");
    stakingToken = await StakingToken.deploy();
    await stakingToken.deployed();

    const Launchpad = await ethers.getContractFactory("Launchpad");
    launchpad = await Launchpad.deploy();
    await launchpad.deployed();

    const Airdrop = await ethers.getContractFactory("Airdrop");
    airdrop = await Airdrop.deploy();
    await airdrop.deployed();

    console.log("launchapToken:" + launchapToken.address);
    console.log("stakingToken:" + stakingToken.address);
    console.log("launchpad:" + launchpad.address);
    console.log("airdrop:" + airdrop.address);
  }

  before(async function () {
    await init();
  });

  it("TestLaunchpad", async function () {
    const [owner, owner2] = await ethers.getSigners();
    await launchapToken.mint(
      launchapToken.address,
      ethers.utils.parseUnits("10000", 18)
    );
    await stakingToken.mint(
      owner.address,
      ethers.utils.parseUnits("10000", 18)
    );
    await stakingToken.approve(
      launchpad.address,
      ethers.utils.parseUnits("10000", 18)
    );
    await launchpad.addLaunchpad(
      _name,
      stakingToken.address,
      launchapToken.address,
      _startTime,
      _endTime,
      1337,
      launchpad.address,
      launchapToken.address,
      _LowStakingAmount,
      _totalAllocation
    );
    await launchpad.launchpads(0);
    await launchpad.trackCheckpoints(0);
    await launchpad.stake(0, ethers.utils.parseUnits("10", 18));
    await launchpad.UserChecks(0, owner.address, 1);
    await launchpad.unstake(0, 1);
    await launchpad.UserChecks(0, owner.address, 1);
    await launchpad.trackCheckpoints(0);

    await launchpad.setLaunchpadAdministrator(0, [owner.address]);
    await launchpad.updateAllowsWithdraw(0, true);

    const amount1 = "100";
    const amount2 = "100";
    const values = [
      [owner.address, amount1],
      [owner2.address, amount2],
    ];
    const tree = StandardMerkleTree.of(values, ["address", "uint256"]);
    await launchpad.setLaunchpadRoot(0, 200, tree.root);
    let proof;
    for (const [i, v] of tree.entries()) {
      if (v[0] == owner.address) {
        proof = tree.getProof(i);
      }
    }
    await launchpad.claimOfSameChain(0, 100, proof);
  });

  it("TestA", async function () {
    const [owner, owner2] = await ethers.getSigners();
    await launchapToken.mint(
      airdrop.address,
      ethers.utils.parseUnits("100000", 18)
    );
    const amount1 = ethers.utils.parseUnits("1000", 18);
    const amount2 = ethers.utils.parseUnits("1000", 18);
    const values = [
      [owner.address, amount1],
      [owner2.address, amount2],
    ];
    const tree = StandardMerkleTree.of(values, ["address", "uint256"]);
    // fs.writeFileSync("tree.json", JSON.stringify(tree.dump()));
    // let tree = StandardMerkleTree.load(
    //   JSON.parse(fs.readFileSync("tree.json", "utf8"))
    // );
    await airdrop.addTokenAirDrop(
      launchapToken.address,
      tree.root,
      _startTime,
      _endTime
    );

    await launchapToken.balanceOf(owner.address).then((res) => console.log(res));
    await launchapToken.balanceOf(owner2.address).then((res) => console.log(res));
    const proof0 = tree.getProof(0);
    const proof1 = tree.getProof(1);
    await airdrop.claim(launchapToken.address, proof0, amount1);
    await airdrop.connect(owner2).claim(launchapToken.address, proof1, amount2);
    await launchapToken.balanceOf(owner.address).then((res) => console.log(res));
    await launchapToken.balanceOf(owner2.address).then((res) => console.log(res));
   /*  for (const [i, v] of tree.entries()) {
      const proof = tree.getProof(i);
      console.log("i", i);
      console.log("Address:Value:", v[0], v[1]);
      // await airdrop.claim(launchapToken.address, proof, v[1]);
    } */
  });
});
