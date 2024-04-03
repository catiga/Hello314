// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

struct TokenInfo {
    address ca;
    string name;
    string symbol;
    uint256 decimals;
    uint256 totalSupply;
    uint256 blockToUnlockLiquidity;
    address liquidityProvider;
    bool tradingEnable;
    bool liquidityAdded;
    uint256 pool0p;
    uint256 pool1p;
    uint256 tokenProp;
}

interface INova {
    error ERCGeneralExternalError(bytes data);
    
    event IVRSwap(
        address indexed sender,
        address indexed token0In,
        address indexed token1Out,
        uint amount0In,
        uint amount1Out
    );
    event IVRFee(
        address indexed sender,
        uint256 amount
    );
}