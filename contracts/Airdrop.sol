// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Airdrop is Ownable {
    struct TokenInfo {
        bytes32 root;
        uint256 startTime;
        uint256 endTime;
    }
    // 代币地址对应的信息
    mapping(address => TokenInfo) public tokenOfInfo;

    mapping(address => mapping(address => bool)) public isClaimed;

    constructor() Ownable(msg.sender) {}

    function addTokenAirDrop(
        address _address,
        bytes32 _root,
        uint256 _startTime,
        uint256 _endTime
    ) external onlyOwner {
        require(_startTime < _endTime, "Start time must be before end time");
        require(_endTime > block.timestamp, "End time must be in the future");
        tokenOfInfo[_address] = TokenInfo(_root, _startTime, _endTime);
    }

    // 提取
    function claim(
        address _tokenAddress,
        bytes32[] memory proof,
        uint256 amount
    ) external {
        TokenInfo memory tokenInfo = tokenOfInfo[_tokenAddress];
        require(
            block.timestamp > tokenInfo.startTime &&
                block.timestamp < tokenInfo.endTime,
            "Not active"
        );
        require(
            isClaimed[_tokenAddress][msg.sender] == false,
            "Already claimed"
        );
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(msg.sender, amount)))
        );
        require(
            MerkleProof.verify(proof, tokenInfo.root, leaf),
            "Invalid proof"
        );
        IERC20(_tokenAddress).transfer(msg.sender, amount);
        isClaimed[_tokenAddress][msg.sender] = true;
    }

    function update(
        address _address,
        bytes32 _root,
        uint256 _startTime,
        uint256 _endTime
    ) external onlyOwner {
        require(_startTime < _endTime, "Start time must be before end time");
        require(_endTime > block.timestamp, "End time must be in the future");
        TokenInfo storage tokenInfo = tokenOfInfo[_address];
        require(tokenInfo.root != bytes32(0), "Please add the token first");
        require(_root != tokenInfo.root, "Root unchanged");
        tokenInfo.root = _root;
        tokenInfo.startTime = _startTime;
        tokenInfo.endTime = _endTime;
    }
}
