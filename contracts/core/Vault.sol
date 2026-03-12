// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title Vault
 * @notice 资金托管合约，管理用户存入的资金
 * @dev 支持多链、多代币的资金管理
 */
contract Vault is ReentrancyGuard, Ownable, Pausable {
    using SafeERC20 for IERC20;

    // 用户余额: user => token => amount
    mapping(address => mapping(address => uint256)) public balances;

    // 策略授权额度: user => strategy => token => amount
    mapping(address => mapping(address => mapping(address => uint256))) public allowances;

    // 受信任的策略合约
    mapping(address => bool) public trustedStrategies;

    // 事件
    event Deposit(address indexed user, address indexed token, uint256 amount);
    event Withdraw(address indexed user, address indexed token, uint256 amount);
    event ApproveStrategy(address indexed user, address indexed strategy, address indexed token, uint256 amount);
    event StrategyAdded(address indexed strategy);
    event StrategyRemoved(address indexed strategy);

    constructor() Ownable(msg.sender) {}

    /**
     * @notice 存入资金
     * @param token 代币地址
     * @param amount 存入数量
     */
    function deposit(address token, uint256 amount) external nonReentrant whenNotPaused {
        require(amount > 0, "Amount must be greater than 0");

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        balances[msg.sender][token] += amount;

        emit Deposit(msg.sender, token, amount);
    }

    /**
     * @notice 提取资金
     * @param token 代币地址
     * @param amount 提取数量
     */
    function withdraw(address token, uint256 amount) external nonReentrant whenNotPaused {
        require(balances[msg.sender][token] >= amount, "Insufficient balance");
        require(amount > 0, "Amount must be greater than 0");

        balances[msg.sender][token] -= amount;
        IERC20(token).safeTransfer(msg.sender, amount);

        emit Withdraw(msg.sender, token, amount);
    }

    /**
     * @notice 授权策略使用资金
     * @param strategy 策略合约地址
     * @param token 代币地址
     * @param amount 授权数量
     */
    function approveStrategy(
        address strategy,
        address token,
        uint256 amount
    ) external whenNotPaused {
        require(trustedStrategies[strategy], "Strategy not trusted");
        require(balances[msg.sender][token] >= amount, "Insufficient balance");

        allowances[msg.sender][strategy][token] = amount;

        emit ApproveStrategy(msg.sender, strategy, token, amount);
    }

    /**
     * @notice 策略执行转账（仅限受信任的策略）
     * @param user 用户地址
     * @param token 代币地址
     * @param amount 转账数量
     * @param recipient 接收地址
     */
    function strategyTransfer(
        address user,
        address token,
        uint256 amount,
        address recipient
    ) external nonReentrant whenNotPaused {
        require(trustedStrategies[msg.sender], "Caller not trusted strategy");
        require(allowances[user][msg.sender][token] >= amount, "Insufficient allowance");

        allowances[user][msg.sender][token] -= amount;
        balances[user][token] -= amount;

        IERC20(token).safeTransfer(recipient, amount);
    }

    /**
     * @notice 添加受信任的策略
     * @param strategy 策略合约地址
     */
    function addStrategy(address strategy) external onlyOwner {
        trustedStrategies[strategy] = true;
        emit StrategyAdded(strategy);
    }

    /**
     * @notice 移除受信任的策略
     * @param strategy 策略合约地址
     */
    function removeStrategy(address strategy) external onlyOwner {
        trustedStrategies[strategy] = false;
        emit StrategyRemoved(strategy);
    }

    /**
     * @notice 暂停合约
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice 恢复合约
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @notice 查询用户余额
     * @param user 用户地址
     * @param token 代币地址
     * @return 用户余额
     */
    function getBalance(address user, address token) external view returns (uint256) {
        return balances[user][token];
    }

    /**
     * @notice 查询策略授权额度
     * @param user 用户地址
     * @param strategy 策略地址
     * @param token 代币地址
     * @return 授权额度
     */
    function getAllowance(
        address user,
        address strategy,
        address token
    ) external view returns (uint256) {
        return allowances[user][strategy][token];
    }
}
