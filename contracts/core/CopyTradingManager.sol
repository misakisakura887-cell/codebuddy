// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title CopyTradingManager
 * @notice 社交跟单交易管理合约
 * @dev 支持多种跟单模式和风险控制
 */
contract CopyTradingManager is AccessControl, ReentrancyGuard, Pausable {
    
    bytes32 public constant STRATEGIST_ROLE = keccak256("STRATEGIST_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    enum CopyMode {
        MIRROR,           // 实时镜像
        STRATEGY_COPY,    // 策略复制
        SMART_ALLOCATE    // 智能分配
    }

    struct CopyConfig {
        address strategist;       // 策略师地址
        address follower;         // 跟单者地址
        CopyMode mode;            // 跟单模式
        uint256 maxAllocation;    // 最大分配金额
        uint256 maxLossPercent;   // 最大亏损比例 (basis points, 2000 = 20%)
        uint256 leverageRatio;    // 杠杆倍数 (basis points, 10000 = 1x)
        bool isActive;            // 是否激活
        uint256 startTime;        // 开始时间
    }

    struct FollowerInfo {
        uint256 totalCopied;      // 总跟单金额
        uint256 totalProfit;      // 总收益
        uint256 activeStrategies; // 活跃策略数
        uint256 totalTrades;      // 总交易数
    }

    struct StrategistInfo {
        uint256 totalFollowers;   // 总跟随者
        uint256 totalAUM;         // 管理总资金
        uint256 totalTrades;      // 总交易数
        uint256 winRate;          // 胜率 (basis points)
        uint256 avgROI;           // 平均投资回报率 (basis points)
    }

    // 跟单配置: strategist => follower => config
    mapping(address => mapping(address => CopyConfig)) public copyConfigs;

    // 策略师信息
    mapping(address => StrategistInfo) public strategistInfo;

    // 跟单者信息
    mapping(address => FollowerInfo) public followerInfo;

    // 交易记录
    struct CopyTrade {
        address strategist;
        address follower;
        uint256 amount;
        uint256 profit;
        uint256 timestamp;
    }

    CopyTrade[] public copyTrades;

    // 事件
    event CopyTradingStarted(address indexed strategist, address indexed follower, CopyConfig config);
    event CopyTradingStopped(address indexed strategist, address indexed follower);
    event TradeCopied(address indexed strategist, address indexed follower, uint256 amount, uint256 profit);
    event RiskLimitReached(address indexed follower, uint256 lossPercent);
    event StrategistVerified(address indexed strategist);
    event StrategistUnverified(address indexed strategist);

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(OPERATOR_ROLE, msg.sender);
    }

    /**
     * @notice 开始跟单
     * @param strategist 策略师地址
     * @param mode 跟单模式
     * @param maxAllocation 最大分配金额
     * @param maxLossPercent 最大亏损比例
     * @param leverageRatio 杠杆倍数
     */
    function startCopyTrading(
        address strategist,
        CopyMode mode,
        uint256 maxAllocation,
        uint256 maxLossPercent,
        uint256 leverageRatio
    ) external nonReentrant whenNotPaused {
        require(strategist != msg.sender, "Cannot copy self");
        require(maxAllocation > 0, "Invalid allocation");
        require(maxLossPercent <= 10000, "Invalid loss percent"); // Max 100%
        require(hasRole(STRATEGIST_ROLE, strategist), "Strategist not verified");

        CopyConfig storage config = copyConfigs[strategist][msg.sender];
        require(!config.isActive, "Already following");

        config.strategist = strategist;
        config.follower = msg.sender;
        config.mode = mode;
        config.maxAllocation = maxAllocation;
        config.maxLossPercent = maxLossPercent;
        config.leverageRatio = leverageRatio;
        config.isActive = true;
        config.startTime = block.timestamp;

        strategistInfo[strategist].totalFollowers++;
        strategistInfo[strategist].totalAUM += maxAllocation;
        followerInfo[msg.sender].activeStrategies++;

        emit CopyTradingStarted(strategist, msg.sender, config);
    }

    /**
     * @notice 停止跟单
     * @param strategist 策略师地址
     */
    function stopCopyTrading(address strategist) external nonReentrant {
        CopyConfig storage config = copyConfigs[strategist][msg.sender];
        require(config.isActive, "Not following");

        config.isActive = false;

        strategistInfo[strategist].totalFollowers--;
        strategistInfo[strategist].totalAUM -= config.maxAllocation;
        followerInfo[msg.sender].activeStrategies--;

        emit CopyTradingStopped(strategist, msg.sender);
    }

    /**
     * @notice 执行跟单交易 (由 operator 调用)
     * @param strategist 策略师地址
     * @param followers 跟单者列表
     * @param amounts 交易金额列表
     */
    function executeCopyTrades(
        address strategist,
        address[] calldata followers,
        uint256[] calldata amounts
    ) external onlyRole(OPERATOR_ROLE) nonReentrant whenNotPaused {
        require(followers.length == amounts.length, "Arrays length mismatch");

        for (uint256 i = 0; i < followers.length; i++) {
            CopyConfig storage config = copyConfigs[strategist][followers[i]];

            if (!config.isActive) continue;

            // 计算跟单金额
            uint256 copyAmount = _calculateCopyAmount(config, amounts[i]);

            // 检查风控限制
            if (_checkRiskLimit(config, followers[i])) {
                // 记录跟单交易
                copyTrades.push(CopyTrade({
                    strategist: strategist,
                    follower: followers[i],
                    amount: copyAmount,
                    profit: 0,
                    timestamp: block.timestamp
                }));

                followerInfo[followers[i]].totalCopied += copyAmount;
                followerInfo[followers[i]].totalTrades++;

                emit TradeCopied(strategist, followers[i], copyAmount, 0);
            } else {
                emit RiskLimitReached(followers[i], config.maxLossPercent);
            }
        }

        strategistInfo[strategist].totalTrades++;
    }

    /**
     * @notice 更新跟单收益
     * @param strategist 策略师地址
     * @param follower 跟单者地址
     * @param profit 收益金额
     */
    function updateCopyProfit(
        address strategist,
        address follower,
        uint256 profit
    ) external onlyRole(OPERATOR_ROLE) {
        CopyConfig storage config = copyConfigs[strategist][follower];
        require(config.isActive, "Not active");

        followerInfo[follower].totalProfit += profit;
    }

    /**
     * @notice 验证策略师
     * @param strategist 策略师地址
     */
    function verifyStrategist(address strategist) external onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(STRATEGIST_ROLE, strategist);
        emit StrategistVerified(strategist);
    }

    /**
     * @notice 取消策略师验证
     * @param strategist 策略师地址
     */
    function unverifyStrategist(address strategist) external onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(STRATEGIST_ROLE, strategist);
        emit StrategistUnverified(strategist);
    }

    /**
     * @notice 更新策略师统计信息
     * @param strategist 策略师地址
     * @param winRate 胜率
     * @param avgROI 平均投资回报率
     */
    function updateStrategistStats(
        address strategist,
        uint256 winRate,
        uint256 avgROI
    ) external onlyRole(OPERATOR_ROLE) {
        strategistInfo[strategist].winRate = winRate;
        strategistInfo[strategist].avgROI = avgROI;
    }

    /**
     * @notice 计算跟单金额
     */
    function _calculateCopyAmount(CopyConfig storage config, uint256 sourceAmount) internal view returns (uint256) {
        if (config.mode == CopyMode.MIRROR) {
            return (sourceAmount * config.leverageRatio) / 10000;
        } else if (config.mode == CopyMode.STRATEGY_COPY) {
            return config.maxAllocation;
        } else if (config.mode == CopyMode.SMART_ALLOCATE) {
            return _smartAllocation(config, sourceAmount);
        }
        return sourceAmount;
    }

    /**
     * @notice 智能分配算法
     */
    function _smartAllocation(CopyConfig storage config, uint256 amount) internal view returns (uint256) {
        // 基于策略师历史表现和风险偏好计算
        StrategistInfo storage stats = strategistInfo[config.strategist];
        
        // 评分 = 胜率权重 * 胜率 + ROI权重 * ROI
        uint256 score = (stats.winRate * 60 + stats.avgROI * 40) / 100;
        
        // 风险系数 = (10000 - maxLossPercent) / 10000
        uint256 riskFactor = (10000 - config.maxLossPercent);
        
        // 最终分配 = 最大分配 * 评分 * 风险系数 / 10000
        return (config.maxAllocation * score * riskFactor) / 100000000;
    }

    /**
     * @notice 检查风控限制
     */
    function _checkRiskLimit(CopyConfig storage config, address follower) internal view returns (bool) {
        FollowerInfo storage info = followerInfo[follower];
        
        if (info.totalCopied == 0) return true;
        
        // 计算当前亏损比例
        int256 pnl = int256(info.totalProfit) - int256(info.totalCopied);
        
        if (pnl >= 0) return true;
        
        uint256 lossPercent = (uint256(-pnl) * 10000) / info.totalCopied;
        
        return lossPercent < config.maxLossPercent;
    }

    /**
     * @notice 获取策略师信息
     * @param strategist 策略师地址
     */
    function getStrategistInfo(address strategist) external view returns (StrategistInfo memory) {
        return strategistInfo[strategist];
    }

    /**
     * @notice 获取跟单者信息
     * @param follower 跟单者地址
     */
    function getFollowerInfo(address follower) external view returns (FollowerInfo memory) {
        return followerInfo[follower];
    }

    /**
     * @notice 获取跟单配置
     * @param strategist 策略师地址
     * @param follower 跟单者地址
     */
    function getCopyConfig(address strategist, address follower) external view returns (CopyConfig memory) {
        return copyConfigs[strategist][follower];
    }

    /**
     * @notice 暂停合约
     */
    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    /**
     * @notice 恢复合约
     */
    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }
}
