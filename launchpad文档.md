# Launchpad合约

## 结构体

**LaunchpadInfo 结构体：**存储每个Launchpad的相关信息。

- `name`: Launchpad名称。
- `startTime`: Launchpad开始时间。
- `endTime`: Launchpad结束时间。
- `LowStakingTime`: 最低抵押时间。
- `chainID`: Launchpad所属链的 ID。
- `LowStakingAmount`: 最低抵押数量。
- `stakingAddress`: 抵押代币存放地址。
- `launchedAddress`: 发行代币存放地址。
- `totalAllocation`: 发行代币的总分配数量。

**TrackCheckpoint 结构体：**跟踪每个Launchpad的抵押活动。

- `stakeToken`: 抵押代币的 ERC20 合约地址。
- `launchedToken`: 发行代币的 ERC20 合约地址。
- `allowsWithdraw`: 是否允许用户提取资金。
- `timestamp`: 时间戳。
- `totalStaked`: 总抵押金额。
- `status`: Launchpad状态。

**UserCheck 结构体：**跟踪用户在Launchpad上的抵押记录。

- `timestamp`: 抵押的时间戳。
- `staked`: 抵押的金额。

## 变量

**Mapping 变量：**

- `launchpads`: 存储所有Launchpad的 LaunchpadInfo 结构体。
- `launchpadOfWhiltaddress`: 存储Launchpad的白名单地址。
- `isExchanged`: 存储用户是否已经兑换过代币。
- `trackCheckpoints`: 存储每个Launchpad的 TrackCheckpoint 结构体。
- `exchangeAmount`: 存储每个用户的兑换金额。
- `whiltAddress`: 存储顶层白名单地址。
- `merkleRoot`: 存储Launchpad的积分 Merkle 根节点。
- `totalPoints`: 存储每个Launchpad的总积分。
- `userCheckpointCounts`: 存储用户在每个Launchpad的抵押记录数量。
- `UserChecks`: 存储用户在每个Launchpad的抵押记录。

## **事件**

- `AddLaunchpad`: 添加Launchpad时触发的事件。
- `Claimed`: 用户领取代币时触发的事件。
- `Staked`: 用户抵押代币时触发的事件。
- `UnStaked`: 用户解除抵押时触发的事件。

## **函数修饰符**

- `onlyWhiltAddress`: 限制只有白名单地址可以调用的修饰符。
- `onlyLaunchpadAdministrator`: 限制只有Launchpad管理员可以调用的修饰符。

## 方法

#### **addLaunchpad**：添加新的Launchpad。

- 接收Launchpad的参数，包括名称、开始时间、结束时间、launchpadToken链ID、抵押代币、发行代币等。
- 创建一个新的 LaunchpadInfo 结构体并将其添加到 `launchpads` 数组中。
- 创建一个新的 TrackCheckpoint 结构体并将其添加到 `trackCheckpoints` 映射中。
- 触发 AddLaunchpad 事件，通知添加Launchpad的操作。

#### **stake**：在指定的Launchpad上抵押代币。

- 检查用户抵押金额是否满足Launchpad的最低抵押要求。
- 检查Launchpad是否处于活动状态，以及当前时间是否在抵押时间范围内。
- 创建一个新的 UserCheck 结构体，记录用户的抵押信息。
- 转移用户的抵押代币到指定的抵押地址。
- 更新Launchpad的总抵押金额。
- 触发 Staked 事件，通知用户已完成抵押操作。

#### **unstake**：在指定的Launchpad上解除抵押。

- 检查用户是否有抵押记录。
- 检查是否已满足Launchpad的最低抵押时间要求。
- 将用户的抵押代币退还给用户。
- 更新Launchpad的总抵押金额。
- 触发 UnStaked 事件，通知用户已完成解除抵押操作。

#### **claimOfSameChain**：在同一条链上领取发行代币。

- 检查Launchpad是否处于活动状态，以及当前时间是否在领取时间范围内。
- 检查用户是否已经领取过发行代币。
- 根据用户持有的积分数量计算应领取的发行代币数量。
- 将发行代币转移给用户。
- 标记用户已经领取过发行代币。
- 触发 Claimed 事件，通知用户已完成发行代币领取操作。

#### **verify**：验证用户的 Merkle 证明。

- 根据用户地址和积分数量生成叶子哈希。
- 使用 MerkleProof 库验证用户的 Merkle 证明是否有效。

#### **updateAllowsWithdraw**：更新Launchpad是否允许用户提取资金的状态。

- 管理员调用此方法更新Launchpad的允许提取状态。

#### **updateLaunchpadStatus**：更新Launchpad的状态。

- 管理员调用此方法更新Launchpad的状态。

#### **setLaunchpadRoot**：设置Launchpad的 Merkle 根节点和总积分。

- 管理员调用此方法设置Launchpad的积分 Merkle 根节点和总积分数量。

#### **setLaunchpadAdministrator**：设置Launchpad的管理员。

- 管理员调用此方法设置Launchpad的管理员地址。

#### **setLaunchpadStakingAddress**：更新Launchpad的抵押资金存放地址。

- 管理员调用此方法更新Launchpad的抵押资金存放地址。

#### **setLaunchpadLaunchedAddress**：更新Launchpad的发行资金存放地址。

- 管理员调用此方法更新Launchpad的发行资金存放地址。

#### **changeLaunchpadStatus**：更改Launchpad的状态。

- 管理员调用此方法更改Launchpad的状态。

#### **setLaunchpadLowStakingTime**：设置Launchpad的最低质押时间。

    - 管理员调用此方法设置Launchpad的最低质押时间。

#### **getExchangeAmount**：获取用户的兑换金额。

- 用户调用此方法查询自己的兑换金额。

#### **addWhiltAddress**：添加白名单地址。

- 管理员调用此方法添加白名单地址。

#### **removeWhiltAddress**：移除白名单地址。

- 管理员调用此方法移除白名单地址。

# AirDrop合约

这个合约用来空投代币使用，在异于l链可以部署一次，后续可以通过addTokenAirDrop方法来添加代币空投活动。

## 方法

#### **addTokenAirDrop：** 添加代币空投活动。

参数：`_address`: 要添加空投活动的代币地址。`_root`: Merkle 树的根节点。`_startTime`: 空投活动开始时间戳。`_endTime`: 空投活动结束时间戳。

- 仅合约所有者（Owner）可以调用该方法。
- 在合约中存储指定代币地址的空投信息，包括 Merkle 树的根节点、开始时间和结束时间。
- 确保指定的开始时间早于结束时间，并且结束时间在未来。
- 如果代币地址已经存在对应的空投信息，则更新现有的空投信息。

#### **claim**： 用户领取代币空投。

参数：`_tokenAddress`: 要领取空投的代币地址。`proof`: 用户的 Merkle 证明路径。`amount`: 领取的代币数量。

- 用户调用此方法来领取指定代币的空投。
- 确保当前时间处于空投活动的开始和结束时间之间。
- 检查用户是否已经领取过该代币的空投。
- 根据用户地址和领取金额生成叶子哈希。
- 使用 MerkleProof 库验证用户的 Merkle 证明是否有效。
- 如果验证通过，则将指定数量的代币转移给用户，并标记该用户已经领取过空投。

