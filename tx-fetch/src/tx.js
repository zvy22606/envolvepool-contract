const { ethers } = require("ethers");


// 连接到以太坊节点
const provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:8545/");

// 使用私钥连接到账户
const privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
const wallet = new ethers.Wallet(privateKey, provider);

// 读取 ABI 文件
const launchapToken1abi = require("../abi/LaunchapToken.json");
const stakingTokenabi = require("../abi/StakingToken.json");
const launchpadabi = require("../abi/Launchpad.json");
const launchapToken1Abi = launchapToken1abi.abi;
const stakingTokenAbi = stakingTokenabi.abi;
const launchpadAbi = launchpadabi.abi;
// 获取已部署的合约实例
// launchapToken:0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9
// stakingToken:0x5FC8d32690cc91D4c39d9d3abcBD16989F875707
// launchpad:0x0165878A594ca255338adfa4d48449f69242Eb8F
const launchapTokenAddress = "0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9";
const stakingTokenAddress = "0x5FC8d32690cc91D4c39d9d3abcBD16989F875707";
const launchpadAddress = "0x0165878A594ca255338adfa4d48449f69242Eb8F";

const launchapToken1 = new ethers.Contract(launchapTokenAddress, launchapToken1Abi, wallet);
const stakingToken = new ethers.Contract(stakingTokenAddress, stakingTokenAbi, wallet);
const launchpad = new ethers.Contract(launchpadAddress, launchpadAbi, wallet);

// 执行操作
const owner = wallet.address;

async function executeLaunchpadOperations() {
    await launchapToken1.mint(
        owner,
        ethers.utils.parseUnits("10000", 18)
    );
    await stakingToken.mint(
        owner,
        ethers.utils.parseUnits("10000", 18)
    );
    await stakingToken.approve(
        launchpad.address,
        ethers.utils.parseUnits("10000", 18)
    );

    console.log("Tokens minted and approved successfully!");
    const _name = "MyStakingPool";
    const _startTime = Math.floor(Date.now() / 1000);
    const _endTime = _startTime + 3600;
    const _LowStakingTime = 3600;
    const _LowStakingAmount = ethers.utils.parseUnits("10", 18);
    const _exchangeCharge = 0;

    // 添加 Launchpad
    await launchpad.addLaunchpad(
        _name,
        stakingTokenAddress,
        launchapTokenAddress,
        _startTime,
        _endTime,
        33137,
        launchpadAddress,
        launchapTokenAddress,
        _LowStakingAmount,
        ethers.utils.parseUnits("10", 18)
    );

    // 获取 Launchpad 信息
    const launchpadInfo = await launchpad.launchpads(0);
    console.log("Launchpad Info:", launchpadInfo);

    // 验证用户检查点
    await launchpad.UserChecks(0, wallet.address, 1).then(console.log);

    // 显示检查点
    await launchpad.trackCheckpoints(0).then(console.log);

    // 质押
    await launchpad.stake(0, ethers.utils.parseUnits("10", 18));

    // 再次验证用户检查点
    await launchpad.UserChecks(0, wallet.address, 1).then(console.log);

    // 显示更新后的检查点
    await launchpad.trackCheckpoints(0).then(console.log);

    // 取回质押
    await launchpad.unstake(0, 2).then(console.log);

    // 最终用户检查点
    await launchpad.UserChecks(0, wallet.address, 0).then(console.log);

    // 最终检查点
    await launchpad.trackCheckpoints(0).then(console.log);
}

executeLaunchpadOperations()
