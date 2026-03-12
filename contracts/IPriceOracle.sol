// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IPriceOracle
 * @notice 价格预言机接口
 */
interface IPriceOracle {
    function getPrice(address tokenA, address tokenB) external view returns (uint256);
    function getPriceWithDecimals(address tokenA, address tokenB) external view returns (uint256 price, uint8 decimals);
}
