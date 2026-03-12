// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title GridStrategy
 * @notice 网格交易策略合约
 * @dev 实现趋势+网格混合策略
 */
contract GridStrategy is Ownable, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    struct GridConfig {
        address tokenA;           // 交易对 Token A
        address tokenB;           // 交易对 Token B
        uint256 gridCount;        // 网格数量
        uint256 priceLower;       // 价格下限 (1e18 precision)
        uint256 priceUpper;       // 价格上限
        uint256 amountPerGrid;    // 每格交易金额
        bool isTrendFollowing;    // 是否开启趋势跟随
    }

    struct GridState {
        uint256[] gridPrices;     // 各网格价格点
        int256 currentGrid;       // 当前所在网格 (int256 for signed arithmetic)
        uint256 totalInvested;    // 总投入 (tokenA)
        uint256 totalProfit;      // 总收益 (tokenB)
        bool isActive;            // 是否激活
        uint256 createdAt;        // 创建时间
    }

    struct TrendParams {
        uint256 ma20;             // 20周期均线
        uint256 ma50;             // 50周期均线
        uint256 lastAdjustTime;   // 上次调整时间
        int256 trendDirection;    // 趋势方向: 1=上涨, -1=下跌, 0=震荡
    }

    GridConfig public config;
    GridState public state;
    TrendParams public trendParams;

    address public vault;
    address public priceOracle;
    address public router;        // DEX router for swaps

    // 交易记录
    struct Trade {
        uint256 gridIndex;
        bool isBuy;
        uint256 amountIn;
        uint256 amountOut;
        uint256 price;
        uint256 timestamp;
    }

    Trade[] public trades;

    // 事件
    event GridExecuted(uint256 indexed gridIndex, bool isBuy, uint256 amountIn, uint256 amountOut, uint256 price);
    event StrategyCreated(GridConfig config);
    event StrategyPaused();
    event StrategyResumed();
    event TrendAdjusted(int256 direction, uint256 newPriceLower, uint256 newPriceUpper);
    event ParametersUpdated(uint256 gridCount, uint256 amountPerGrid);

    constructor(
        GridConfig memory _config,
        address _vault,
        address _priceOracle,
        address _router
    ) Ownable(msg.sender) {
        require(_config.gridCount >= 2 && _config.gridCount <= 100, "Invalid grid count");
        require(_config.priceLower < _config.priceUpper, "Invalid price range");
        require(_config.amountPerGrid > 0, "Invalid amount per grid");

        config = _config;
        vault = _vault;
        priceOracle = _priceOracle;
        router = _router;

        _initializeGrid();
        
        state.isActive = true;
        state.createdAt = block.timestamp;

        emit StrategyCreated(_config);
    }

    /**
     * @notice 初始化网格
     */
    function _initializeGrid() internal {
        uint256 priceRange = config.priceUpper - config.priceLower;
        uint256 gridGap = priceRange / config.gridCount;

        for (uint256 i = 0; i <= config.gridCount; i++) {
            state.gridPrices.push(config.priceLower + gridGap * i);
        }
    }

    /**
     * @notice 执行网格交易 (由后端机器人或 keeper 调用)
     * @param gridIndex 目标网格索引
     * @param isBuy 是否为买入
     * @param currentPrice 当前价格
     * @param amountIn 输入金额
     * @return amountOut 输出金额
     */
    function executeGrid(
        uint256 gridIndex,
        bool isBuy,
        uint256 currentPrice,
        uint256 amountIn
    ) external onlyOwner nonReentrant whenNotPaused returns (uint256 amountOut) {
        require(state.isActive, "Strategy not active");
        require(gridIndex < config.gridCount, "Invalid grid index");
        require(amountIn > 0, "Invalid amount");

        // 价格验证 (允许 1% 滑点)
        uint256 expectedPrice = state.gridPrices[gridIndex];
        require(_priceWithinTolerance(currentPrice, expectedPrice, 100), "Price slippage too high");

        // 更新当前网格
        state.currentGrid = int256(gridIndex);

        // 执行交易 (这里简化实现，实际应调用 DEX router)
        // amountOut = _executeSwap(isBuy, amountIn);

        // 记录交易
        trades.push(Trade({
            gridIndex: gridIndex,
            isBuy: isBuy,
            amountIn: amountIn,
            amountOut: amountOut,
            price: currentPrice,
            timestamp: block.timestamp
        }));

        // 更新统计
        if (isBuy) {
            state.totalInvested += amountIn;
        } else {
            state.totalProfit += amountOut;
        }

        emit GridExecuted(gridIndex, isBuy, amountIn, amountOut, currentPrice);

        return amountOut;
    }

    /**
     * @notice 趋势跟随 - 调整价格区间
     * @param newPriceLower 新价格下限
     * @param newPriceUpper 新价格上限
     * @param direction 趋势方向
     */
    function adjustTrend(
        uint256 newPriceLower,
        uint256 newPriceUpper,
        int256 direction
    ) external onlyOwner whenNotPaused {
        require(config.isTrendFollowing, "Trend following not enabled");
        require(newPriceLower < newPriceUpper, "Invalid price range");

        config.priceLower = newPriceLower;
        config.priceUpper = newPriceUpper;

        // 重新初始化网格
        delete state.gridPrices;
        _initializeGrid();

        trendParams.trendDirection = direction;
        trendParams.lastAdjustTime = block.timestamp;

        emit TrendAdjusted(direction, newPriceLower, newPriceUpper);
    }

    /**
     * @notice 更新移动平均线参数
     * @param ma20 20周期均线
     * @param ma50 50周期均线
     */
    function updateTrendParams(uint256 ma20, uint256 ma50) external onlyOwner {
        trendParams.ma20 = ma20;
        trendParams.ma50 = ma50;
    }

    /**
     * @notice 暂停策略
     */
    function pause() external onlyOwner {
        _pause();
        state.isActive = false;
        emit StrategyPaused();
    }

    /**
     * @notice 恢复策略
     */
    function resume() external onlyOwner {
        _unpause();
        state.isActive = true;
        emit StrategyResumed();
    }

    /**
     * @notice 更新策略参数
     * @param gridCount 新网格数量
     * @param amountPerGrid 新每格金额
     */
    function updateParameters(uint256 gridCount, uint256 amountPerGrid) external onlyOwner {
        require(gridCount >= 2 && gridCount <= 100, "Invalid grid count");
        require(amountPerGrid > 0, "Invalid amount");

        config.gridCount = gridCount;
        config.amountPerGrid = amountPerGrid;

        // 重新初始化网格
        delete state.gridPrices;
        _initializeGrid();

        emit ParametersUpdated(gridCount, amountPerGrid);
    }

    /**
     * @notice 获取交易历史
     * @param start 开始索引
     * @param limit 数量限制
     * @return trades 交易列表
     */
    function getTrades(uint256 start, uint256 limit) external view returns (Trade[] memory) {
        require(start < trades.length, "Start index out of bounds");

        uint256 end = start + limit;
        if (end > trades.length) {
            end = trades.length;
        }

        Trade[] memory result = new Trade[](end - start);
        for (uint256 i = start; i < end; i++) {
            result[i - start] = trades[i];
        }

        return result;
    }

    /**
     * @notice 获取策略统计信息
     * @return totalTrades 总交易数
     * @return winRate 胜率
     * @return totalPnL 总盈亏
     */
    function getStats() external view returns (
        uint256 totalTrades,
        uint256 winRate,
        int256 totalPnL
    ) {
        totalTrades = trades.length;

        if (totalTrades == 0) {
            return (0, 0, 0);
        }

        uint256 wins = 0;
        int256 pnl = 0;

        for (uint256 i = 0; i < trades.length; i++) {
            if (trades[i].isBuy) {
                pnl -= int256(trades[i].amountIn);
            } else {
                pnl += int256(trades[i].amountOut);
                wins++;
            }
        }

        winRate = (wins * 100) / totalTrades;
        totalPnL = pnl;
    }

    /**
     * @notice 价格容差检查
     * @param actual 实际价格
     * @param expected 期望价格
     * @param toleranceBps 容差基点 (100 = 1%)
     */
    function _priceWithinTolerance(
        uint256 actual,
        uint256 expected,
        uint256 toleranceBps
    ) internal pure returns (bool) {
        uint256 diff = actual > expected ? actual - expected : expected - actual;
        uint256 tolerance = (expected * toleranceBps) / 10000;
        return diff <= tolerance;
    }

    /**
     * @notice 紧急提取资金
     * @param token 代币地址
     * @param amount 数量
     */
    function emergencyWithdraw(address token, uint256 amount) external onlyOwner {
        IERC20(token).safeTransfer(owner(), amount);
    }
}
