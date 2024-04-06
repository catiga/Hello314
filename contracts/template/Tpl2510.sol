// SPDX-License-Identifier: MIT

//https://linktr.ee/erc2510

pragma solidity ^0.8.20;

import "../eips/ERC2510.sol";

contract Tp2510 is ERC2510 {

    address public owner;
    address public liquidityProvider;
    bool public maxWalletEnable;
    uint256 presaleAmount;
    bool public presaleEnable = false;

    uint256 public tokenDecimals;

    bool public liquidityAdded;
    bool public tradingEnable;

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyLiquidityProvider() {
        require(msg.sender == liquidityProvider, "You are not the liquidity provider");
        _;
    }

    constructor(address _owner_, string memory name_, string memory symbol_, 
        uint256 _totalSupply, uint256 _decimals,
        uint256 _teamPartial, uint256 _presalePartial) payable ERC2510(name_, symbol_, _totalSupply) {
        require((_teamPartial + _presalePartial) <= 10_000, "partial params is invalid");

        owner = _owner_;    // transfer owner
        tokenDecimals = _decimals;

        if(_presalePartial > 0) {
            presaleAmount = _totalSupply * _presalePartial / 10_000;
        }
        uint256 teamAmount = 0;
        if(_teamPartial > 0) {
            teamAmount = _totalSupply * _teamPartial /  10_000;
        }
        if(presaleAmount + teamAmount > 0) {
            _mint(owner, presaleAmount + teamAmount);  // team + presale
        }
        if(_totalSupply - presaleAmount - teamAmount > 0) {
            _mint(address(this), _totalSupply - presaleAmount - teamAmount);   // liquidity pool
        }
        
        liquidityAdded = false;
    }

    /**
     * @dev This method will batch transfer token to multiple wallets
     */
    function batchTransfer(address[] memory wallets, uint256 amount) public {
        require(wallets.length > 0 && amount > 0, "invalid batch params");
        uint256 _totalAmount = wallets.length * amount;
        require(balanceOf(msg.sender) >= _totalAmount, "insufficient balance");

        for (uint256 i = 0; i < wallets.length; i++) {
            _transfer(msg.sender, wallets[i], amount);
        }
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
    function retriveLiquidity() public onlyLiquidityProvider {
        super.removeLiquidity();
    }

    /**
    * @dev Extends the liquidity lock, only if the new block number is higher than the current one.
    * @param _blockToUnlockLiquidity: the new block number to unlock the liquidity.
    * onlyLiquidityProvider modifier
    */
    function prolongLiquidityLock(uint32 _blockToUnlockLiquidity) public onlyLiquidityProvider {
        super.extendLiquidityLock(_blockToUnlockLiquidity);
    }
}