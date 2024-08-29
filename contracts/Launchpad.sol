// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract Launchpad {
    using SafeERC20 for ERC20;

    struct LaunchpadInfo {
        string name;
        uint32 startTime;
        uint32 endTime;
        uint32 LowStakingTime; //最低抵押时间
        uint256 chainID; //所属链ID
        uint256 LowStakingAmount; //最低抵押数量
        address stakingAddress; //质押地址
        address launchedAddress; //launched发币地址
        uint256 totalAllocation; //总分配数量
    }

    struct TrackCheckpoint {
        ERC20 stakeToken;
        ERC20 launchedToken;
        bool allowsWithdraw; //是否允许用户提取资金
        uint256 timestamp; // 时间戳
        uint256 totalStaked; // 总抵押金额
        bool status; //状态
    }

    struct UserCheck {
        uint256 timestamp; // 检查点的时间戳
        uint256 staked; // 抵押金额
    }
    LaunchpadInfo[] public launchpads; //launchpad集合
    mapping(uint256 => mapping(address => bool)) public launchpadOfWhiltaddress; //launchpad白名单地址
    mapping(uint256 => mapping(address => bool)) public isExchanged; //用户是否已兑换
    mapping(uint256 => TrackCheckpoint) public trackCheckpoints; //轨道检查点
    mapping(uint256 => mapping(address => uint256)) public exchangeAmount; // 返回每一个账户兑换了多少
    mapping(address => bool) public whiltAddress; // 顶层白名单
    mapping(uint256 => bytes32) public merkleRoot; //launchpad积分默克尔书根结点
    mapping(uint256 => uint256) public totalPoints; //launchpad总积分
    mapping(uint256 => mapping(address => uint256)) public userCheckpointCounts; // 用户质押数量总数
    mapping(uint256 => mapping(address => mapping(uint256 => UserCheck)))
        public UserChecks; // 用户在轨道上的检查点
    event AddLaunchpad(
        uint256 indexed launchpadId,
        address indexed launchedAddress,
        uint256 indexed chainID,
        string _name
    );
    // Claimed(用户地址，lanuchpad 的编号 ，消耗积分，转给用户的token的合约，转给用户的token数量，兑换时间)
    event Claimed(
        address indexed user,
        uint256 indexed launchpadId,
        uint256 indexed points,
        address token,
        uint256 amount,
        uint256 timestamp,
        uint256 chainID
    );

    // 用户质押代币事件Staked(用户地址，lanuchpad编号，用户质押账单数量，质押代币合约，质押代币数量，质押时间)
    event Staked(
        address indexed user,
        uint256 indexed launchpadId,
        uint256 indexed index,
        address token,
        uint256 amount,
        uint256 timestamp,
        uint256 chainID
    );

    event UnStaked(
        address indexed user,
        uint256 indexed launchpadId,
        uint256 indexed index,
        address token,
        uint256 amount,
        uint256 timestamp,
        uint256 chainID
    );

    // 顶层白名单调用
    modifier onlyWhiltAddress() {
        require(
            whiltAddress[msg.sender],
            "Launchpad: caller is not a whitelisted address"
        );
        _;
    }

    // launchpad子管理员调用
    modifier onlyLaunchpadAdministrator(uint256 _launchpadId) {
        require(
            launchpadOfWhiltaddress[_launchpadId][msg.sender],
            "Launchpad: caller is not a launchpad administrator"
        );
        _;
    }

    constructor() {
        whiltAddress[msg.sender] = true; // 设置合约创建者为白名单地址
    }

    function addLaunchpad(
        string calldata _name,
        ERC20 _stakeToken,
        ERC20 _launchedToken,
        uint32 _startTime,
        uint32 _endTime,
        uint256 _chainID,
        address _stakingAddress,
        address _launchedAddress,
        uint256 _LowStakingAmount,
        uint256 _totalAllocation
    ) external onlyWhiltAddress {
        launchpads.push(
            LaunchpadInfo({
                name: _name,
                startTime: _startTime,
                endTime: _endTime,
                LowStakingTime: 0,
                // LowStakingTime: 1 hours,
                chainID: _chainID,
                LowStakingAmount: _LowStakingAmount,
                stakingAddress: _stakingAddress,
                launchedAddress: _launchedAddress,
                totalAllocation: _totalAllocation
            })
        );

        trackCheckpoints[launchpads.length - 1] = TrackCheckpoint({
            stakeToken: _stakeToken,
            launchedToken: _launchedToken,
            allowsWithdraw: false,
            timestamp: block.timestamp,
            totalStaked: 0,
            status: true
        });

        emit AddLaunchpad(
            launchpads.length - 1,
            _launchedAddress,
            _chainID,
            _name
        );
        emit AddLaunchpad(
            launchpads.length - 1,
            _launchedAddress,
            _chainID,
            _name
        );
    }

    function stake(uint256 _launchpadId, uint256 _amount) external {
        LaunchpadInfo memory launchpad = launchpads[_launchpadId];
        TrackCheckpoint storage trackCheckpoint = trackCheckpoints[
            _launchpadId
        ];
        require(
            _amount >= launchpad.LowStakingAmount,
            "Launchpad: Insufficient amount"
        );
        require(trackCheckpoint.status, "Launchpad: Not active");
        require(
            trackCheckpoint.stakeToken.balanceOf(msg.sender) >= _amount,
            "Launchpad: Insufficient balance"
        );
        require(
            trackCheckpoint.stakeToken.allowance(msg.sender, address(this)) >=
                _amount,
            "Launchpad: Insufficient allowance"
        );
        require(
            block.timestamp > launchpad.startTime &&
                block.timestamp < launchpad.endTime,
            "Launchpad: Not active"
        );

        userCheckpointCounts[_launchpadId][msg.sender]++;
        uint256 userCheckpointCount = userCheckpointCounts[_launchpadId][
            msg.sender
        ];
        UserChecks[_launchpadId][msg.sender][userCheckpointCount] = UserCheck(
            block.timestamp,
            _amount
        );
        trackCheckpoint.stakeToken.safeTransferFrom(
            msg.sender,
            launchpad.stakingAddress,
            _amount
        );
        trackCheckpoint.totalStaked += _amount;
        emit Staked(
            msg.sender,
            _launchpadId,
            userCheckpointCount,
            address(trackCheckpoint.stakeToken),
            _amount,
            block.timestamp,
            launchpad.chainID
        );
    }

    // 取消质押
    function unstake(uint256 _launchpadId, uint256 _index) external {
        TrackCheckpoint storage trackCheckpoint = trackCheckpoints[
            _launchpadId
        ];
        UserCheck memory userCheck = UserChecks[_launchpadId][msg.sender][
            _index
        ];
        LaunchpadInfo memory launchpad = launchpads[_launchpadId];
        require(userCheck.staked > 0, "No staked");
        require(
            block.timestamp - userCheck.timestamp >= launchpad.LowStakingTime,
            "Launchpad: Insufficient time"
        );
        trackCheckpoint.stakeToken.safeTransfer(msg.sender, userCheck.staked);
        trackCheckpoint.totalStaked -= userCheck.staked;
        delete UserChecks[_launchpadId][msg.sender][_index];
        emit UnStaked(
            msg.sender,
            _launchpadId,
            _index,
            address(trackCheckpoint.stakeToken),
            userCheck.staked,
            block.timestamp,
            launchpad.chainID
        );
    }

    // 兑换提取在同一条链
    function claimOfSameChain(
        uint256 _launchpadId,
        uint256 _pointsAmount,
        bytes32[] memory proof
    ) external {
        LaunchpadInfo memory launchpad = launchpads[_launchpadId];
        TrackCheckpoint storage trackCheckpoint = trackCheckpoints[
            _launchpadId
        ];
        require(launchpad.chainID == block.chainid, "Launchpad: Invalid chain");
        require(
            verify(merkleRoot[_launchpadId], proof, msg.sender, _pointsAmount),
            "Launchpad: Invalid proof"
        );
        require(trackCheckpoint.allowsWithdraw);
        require(
            block.timestamp < launchpad.endTime &&
                block.timestamp > launchpad.startTime,
            "Launchpad: Not active"
        );
        require(trackCheckpoint.status, "Launchpad: Not active");
        require(
            !isExchanged[_launchpadId][msg.sender],
            "Launchpad: Already exchanged"
        );
        // TODO 积分兑换
        uint256 amount = (_pointsAmount / totalPoints[_launchpadId]) *
            launchpad.totalAllocation;
        trackCheckpoint.launchedToken.safeTransfer(msg.sender, amount);
        exchangeAmount[_launchpadId][msg.sender] = amount;
        emit Claimed(
            msg.sender,
            _launchpadId,
            _pointsAmount,
            address(trackCheckpoint.launchedToken),
            amount,
            block.timestamp,
            launchpad.chainID
        );
        isExchanged[_launchpadId][msg.sender] = true;
    }

    function verify(
        bytes32 root,
        bytes32[] memory proof,
        address addr,
        uint256 amount
    ) public pure returns (bool) {
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(addr, amount)))
        );
        if (MerkleProof.verify(proof, root, leaf)) {
            return true;
        } else {
            return false;
        }
    }

    // 更新是否允许用户提取资金
    function updateAllowsWithdraw(
        uint256 _launchpadId,
        bool _status
    ) external onlyLaunchpadAdministrator(_launchpadId) {
        require(
            trackCheckpoints[_launchpadId].allowsWithdraw != _status,
            "Launchpad: status not changed"
        );
        trackCheckpoints[_launchpadId].allowsWithdraw = _status;
    }

    // 更新launchpad状态
    function updateLaunchpadStatus(
        uint256 _launchpadId,
        bool _status
    ) external onlyLaunchpadAdministrator(_launchpadId) {
        require(
            trackCheckpoints[_launchpadId].status != _status,
            "Launchpad: status not changed"
        );
        trackCheckpoints[_launchpadId].status = _status;
    }

    // 设置launchpad的根结点和总积分
    function setLaunchpadRoot(
        uint256 _launchpadId,
        uint256 _totalPoints,
        bytes32 _root
    ) external onlyLaunchpadAdministrator(_launchpadId) {
        require(
            merkleRoot[_launchpadId] == bytes32(0),
            "Launchpad: root already set"
        );
        require(
            totalPoints[_launchpadId] == 0,
            "Launchpad: totalPoints already set"
        );
        require(_totalPoints > 0, "Launchpad: totalPoints not set");
        merkleRoot[_launchpadId] = _root;
        totalPoints[_launchpadId] = _totalPoints;
    }

    // 设置lanuchpad子管理员方法：可以让合作方进行有限的设置
    function setLaunchpadAdministrator(
        uint256 _launchpadId,
        address[] calldata _administrator
    ) external onlyWhiltAddress {
        for (uint256 i = 0; i < _administrator.length; i++) {
            address admin = _administrator[i];
            require(admin != address(0), "Launchpad: invalid address");
            launchpadOfWhiltaddress[_launchpadId][admin] = true;
        }
    }

    // 设置lanuchpad的质押资金去向地址更新
    function setLaunchpadStakingAddress(
        uint256 _launchpadId,
        address _stakingAddress
    ) external onlyLaunchpadAdministrator(_launchpadId) {
        require(
            launchpads[_launchpadId].stakingAddress != _stakingAddress,
            "Launchpad: staking address not changed"
        );
        require(_stakingAddress != address(0), "Launchpad: invalid address");
        launchpads[_launchpadId].stakingAddress = _stakingAddress;
    }

    // 设置lanuchpad的发行资金去向地址更新
    function setLaunchpadLaunchedAddress(
        uint256 _launchpadId,
        address _launchedAddress
    ) external onlyLaunchpadAdministrator(_launchpadId) {
        require(
            launchpads[_launchpadId].launchedAddress != _launchedAddress,
            "Launchpad: launched address not changed"
        );
        require(_launchedAddress != address(0), "Launchpad: invalid address");
        launchpads[_launchpadId].launchedAddress = _launchedAddress;
    }

    // 更改lanuchpad是否开启兑换
    function changeLaunchpadStatus(
        uint256 _launchpadId,
        bool _status
    ) external onlyLaunchpadAdministrator(_launchpadId) {
        require(
            trackCheckpoints[_launchpadId].status != _status,
            "Launchpad: status not changed"
        );
        trackCheckpoints[_launchpadId].status = _status;
    }

    // 更改lanuchpad名称
    function changeLaunchpadName(
        uint256 _launchpadId,
        string calldata _name
    ) external onlyLaunchpadAdministrator(_launchpadId) {
        require(
            keccak256(abi.encodePacked(launchpads[_launchpadId].name)) !=
                keccak256(abi.encodePacked(_name)),
            "Launchpad: name not changed"
        );
        require(bytes(_name).length > 0, "Launchpad: invalid name");
        launchpads[_launchpadId].name = _name;
    }

    // 设置lanuchpad最低质押多久才可以兑换
    function setLaunchpadLowStakingTime(
        uint256 _launchpadId,
        uint32 _LowStakingTime
    ) external onlyLaunchpadAdministrator(_launchpadId) {
        require(
            launchpads[_launchpadId].LowStakingTime != _LowStakingTime,
            "Launchpad: time not changed"
        );
        require(_LowStakingTime > 0, "Launchpad: invalid time");
        launchpads[_launchpadId].LowStakingTime = _LowStakingTime;
    }

    //中心化服务器和合约对账的方法（返回每一个账户兑换了多少）
    function getExchangeAmount(address _user) external view returns (uint256) {
        return exchangeAmount[launchpads.length][_user];
    }

    // 添加顶层白名单管理
    function addWhiltAddress(address _whiltAddress) external {
        require(_whiltAddress != address(0), "Launchpad: Invalid address");
        whiltAddress[_whiltAddress] = true;
    }

    // 移除底层白名单管理
    function removeWhiltAddress(address _whiltAddress) external {
        require(whiltAddress[_whiltAddress], "Launchpad: Invalid address");
        whiltAddress[_whiltAddress] = false;
    }
}
