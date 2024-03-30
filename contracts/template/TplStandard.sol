/**
 *Submitted for verification at Etherscan.io on 2024-03-20
*/

// SPDX-License-Identifier: MIT

//https://linktr.ee/simplifyerc

pragma solidity ^0.8.20;

import "../interfaces/ERC314.sol";

/**
 * @title ERC314
 * @dev Implementation of the ERC314 interface.
 * ERC314 is a derivative of ERC20 which aims to integrate a liquidity pool on the token in order to enable native swaps, notably to reduce gas consumption. 
 */

contract TplStandard is ERC314 {

    uint256 public _maxWallet;
    address public owner;
    address public liquidityProvider;
    bool public maxWalletEnable;
    uint256 presaleAmount;
    bool public presaleEnable = false;

    uint256 public tokenDecimals;

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyLiquidityProvider() {
        require(msg.sender == liquidityProvider, "You are not the liquidity provider");
        _;
    }

    constructor(address _owner_, string memory name_, string memory symbol_, 
        uint256 _totalSupply, uint256 _decimals, uint256 _maxWallet_) assigned ERC314(name_, symbol_, _totalSupply) {
        owner = _owner_;    // transfer owner

        _maxWallet = _maxWallet_;
        tradingEnable = false;
        if(_maxWallet_ > 0) {
            maxWalletEnable = true;
        }
        tokenDecimals = _decimals;

        presaleAmount = (_totalSupply - _totalSupply/10) / 2;
        assignedTo(owner, _totalSupply/10 + presaleAmount);
        assignedTo(address(this), presaleAmount);
        liquidityAdded = false;
    }

    /**
     * @dev Sends the presale amount to the investors
     */
    function presale(address[] memory _investors) public onlyOwner {
        require(presaleEnable == false, "Presale already enabled");
        
        uint256 _amount = presaleAmount / _investors.length;
        batchTransfer(_investors, _amount);
        presaleEnable = true;
    }

    function decimals() public view virtual override returns (uint8) {
        return uint8(tokenDecimals);
    }

    /**
    * @dev Enables or disables trading.
    * @param _tradingEnable: true to enable trading, false to disable trading.
    * onlyOwner modifier
    */
    function enableTrading(bool _tradingEnable) external onlyOwner {
        tradingEnable = _tradingEnable;
    }

    /**
    * @dev Enables or disables the max wallet.
    * @param _maxWalletEnable: true to enable max wallet, false to disable max wallet.
    * onlyOwner modifier
    */
    function enableMaxWallet(bool _maxWalletEnable) external onlyOwner {
        maxWalletEnable = _maxWalletEnable;
    }

    /**
    * @dev Sets the max wallet.
    * @param _maxWallet_: the new max wallet.
    * onlyOwner modifier
    */
    function setMaxWallet(uint256 _maxWallet_) external onlyOwner {
        _maxWallet = _maxWallet_;
    }

    /**
    * @dev Transfers the ownership of the contract to zero address
    * onlyOwner modifier
    */
    function renounceOwnership() external onlyOwner {
        owner = address(0);
    }

    /**
    * @dev Adds liquidity to the contract.
    * @param _blockToUnlockLiquidity: the block number to unlock the liquidity.
    * value: the amount of ETH to add to the liquidity.
    * onlyOwner modifier
    */
    function addLiquidity(uint32 _blockToUnlockLiquidity) public onlyOwner payable {

        require(liquidityAdded == false, "Liquidity already added");

        liquidityAdded = true;

        require(msg.value > 0, "No ETH sent");
        require(block.number < _blockToUnlockLiquidity, "Block number too low");
        
        blockToUnlockLiquidity = _blockToUnlockLiquidity;
        tradingEnable = true;
        liquidityProvider = msg.sender;
        
        emit AddLiquidity(_blockToUnlockLiquidity, msg.value);
    }

    /**
    * @dev Removes liquidity from the contract.
    * onlyLiquidityProvider modifier
    */
    function removeLiquidity() public onlyLiquidityProvider {

        require(block.number > blockToUnlockLiquidity, "Liquidity locked");

        tradingEnable = false;

        payable(msg.sender).transfer(address(this).balance);

        emit RemoveLiquidity(address(this).balance);
    }

    /**
    * @dev Extends the liquidity lock, only if the new block number is higher than the current one.
    * @param _blockToUnlockLiquidity: the new block number to unlock the liquidity.
    * onlyLiquidityProvider modifier
    */
    function extendLiquidityLock(uint32 _blockToUnlockLiquidity) public onlyLiquidityProvider {

        require(blockToUnlockLiquidity < _blockToUnlockLiquidity, "You can't shorten duration");

        blockToUnlockLiquidity = _blockToUnlockLiquidity;
    }

    function _beforeTokenTransfer(address, address to, uint256 amount) internal override virtual {
        if (maxWalletEnable) {
            require(amount + balanceOf(to) <= _maxWallet, "Max wallet exceeded");
        }
    }
}