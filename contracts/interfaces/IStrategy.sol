// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IStrategy
 * @notice 策略接口
 */
interface IStrategy {
    function execute(uint256 amount, bytes calldata data) external returns (uint256);
    function pause() external;
    function resume() external;
    function getStats() external view returns (
        uint256 totalTrades,
        uint256 winRate,
        int256 totalPnL
    );
}
