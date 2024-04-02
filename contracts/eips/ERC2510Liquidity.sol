// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IERC2510.sol";

abstract contract ERC2510Liquidity is IERC2510 {
    uint256 public blockToUnlockLiquidity;

    /**
    * @dev Adds liquidity to the contract.
    * @param _blockToUnlockLiquidity: the block number to unlock the liquidity.
    * value: the amount of ETH to add to the liquidity.
    * onlyOwner modifier
    */
    function addLiquidity(uint256 _blockToUnlockLiquidity) external virtual payable {
        require(blockToUnlockLiquidity == 0, "Liquidity already added");

        require(msg.value > 0, "No ETH sent");
        require(block.number < _blockToUnlockLiquidity, "Block number too low");
        
        blockToUnlockLiquidity = _blockToUnlockLiquidity;
        
        emit AddLiquidity(_blockToUnlockLiquidity, msg.value);
    }

    /**
    * @dev Removes liquidity from the contract.
    * onlyLiquidityProvider modifier
    */
    function removeLiquidity() internal {
        require(block.number > blockToUnlockLiquidity, "Liquidity locked");

        payable(msg.sender).transfer(address(this).balance);

        emit RemoveLiquidity(address(this).balance);
    }

    /**
    * @dev Extends the liquidity lock, only if the new block number is higher than the current one.
    * @param _blockToUnlockLiquidity: the new block number to unlock the liquidity.
    * onlyLiquidityProvider modifier
    */
    function extendLiquidityLock(uint32 _blockToUnlockLiquidity) internal {

        require(blockToUnlockLiquidity < _blockToUnlockLiquidity, "You can't shorten duration");

        blockToUnlockLiquidity = _blockToUnlockLiquidity;
    }
}