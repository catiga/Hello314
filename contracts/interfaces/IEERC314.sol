// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface IEERC314 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event AddLiquidity(uint32 _blockToUnlockLiquidity, uint256 value);
    event RemoveLiquidity(uint256 value);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out
    );
}

interface IEERC314Meta is IEERC314 {
    function owner() external view returns(address);
    function liquidityProvider() external view returns(address);
    function blockToUnlockLiquidity() external view returns(uint256);
    function tradingEnable() external view returns(bool);
    function liquidityAdded() external view returns(bool);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function getAmountOut(uint256 value, bool _buy) external view returns(uint256);
    function getReserves() external view returns (uint256, uint256);

    function transfer(address to, uint256 value) external returns (bool);
    function addLiquidity(uint32 _blockToUnlockLiquidity) external payable;
    function removeLiquidity() external;
}

interface IEERC31420 {
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}