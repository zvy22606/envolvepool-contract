// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StakingToken is ERC20 {
    constructor() ERC20("StakingToken", "StakingToken") {}

    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }
}
