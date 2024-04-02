// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./IEERC314.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

abstract contract ERC314 is IEERC314Meta, IERC165 {
    mapping(address account => uint256) private _balances;

    uint256 private _totalSupply;
    uint256 public blockToUnlockLiquidity;

    string private _name;
    string private _symbol;
    bool public tradingEnable;
    bool public liquidityAdded;

    mapping(address account => uint32) private lastTransaction;

    bool internal initialized;

    /**
     * @dev Sets the values for {name}, {symbol} and {totalSupply}. 
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_, uint256 totalSupply_) {
        _name = name_;
        _symbol = symbol_;
        _totalSupply = totalSupply_;

        tradingEnable = false;
    }

    modifier assignedOnce {
        require(!initialized, "can not assign again after initialized");
        _;
    }

    modifier assigned {
        require(!initialized, "can not assign again after initialized");
        _;
        initialized = true;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId 
            || interfaceId == type(IEERC314).interfaceId
            || interfaceId == type(IEERC314Meta).interfaceId;
    }

    function assignedTo(address account, uint256 amount) internal virtual assignedOnce {
        _balances[account] += amount;
    }

    /**
     * @dev This method will be extended to ERC2334
     */
    function batchTransfer(address[] memory wallets, uint256 amount) public {
        require(wallets.length > 0 && amount > 0, "invalid batch params");
        uint256 _totalAmount = wallets.length * amount;
        require(_balances[msg.sender] >= _totalAmount, "insufficient balance");

        for (uint256 i = 0; i < wallets.length; i++) {
            _balances[wallets[i]] += amount;
        }
        _balances[msg.sender] -= _totalAmount;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }


    /**
     * @dev Returns the number of decimals used to get its user representation.
     */

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - the caller must have a balance of at least `value`.
     * - if the receiver is the contract, the caller must send the amount of tokens to sell
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        // sell or transfer
        if (to == address(this)) {
            sell(value);
        }
        else{
            _transfer(msg.sender, to, value);
        }
        return true;
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively burns if `to` is the zero address.
     * All customizations to transfers and burns should be done by overriding this function.
     * This function includes MEV protection, which prevents the same address from making two transactions in the same block.(lastTransaction)
     * Emits a {Transfer} event.
     */
    function _transfer(address from, address to, uint256 value) internal virtual {
        
        require(lastTransaction[msg.sender] != block.number, "You can't make two transactions in the same block");

        lastTransaction[msg.sender] = uint32(block.number);

        require (_balances[from] >= value, "ERC20: transfer amount exceeds balance");

        unchecked {
            _balances[from] = _balances[from] - value;
        }

        if (to == address(0)) {
            unchecked {
                _totalSupply -= value;
            }
        } else {
            unchecked {
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
    * @dev Returns the amount of ETH and tokens in the contract, used for trading.
    */
    function getReserves() public view returns (uint256, uint256) {
        return (address(this).balance, _balances[address(this)]);
    }

    /**
    * @dev Enables or disables trading.
    * @param _tradingEnable: true to enable trading, false to disable trading.
    * onlyOwner modifier
    */
    // function enableTrading(bool _tradingEnable) external onlyOwner {
    //     tradingEnable = _tradingEnable;
    // }

    /**
    * @dev Enables or disables the max wallet.
    * @param _maxWalletEnable: true to enable max wallet, false to disable max wallet.
    * onlyOwner modifier
    */
    // function enableMaxWallet(bool _maxWalletEnable) external onlyOwner {
    //     maxWalletEnable = _maxWalletEnable;
    // }

    /**
    * @dev Sets the max wallet.
    * @param _maxWallet_: the new max wallet.
    * onlyOwner modifier
    */
    // function setMaxWallet(uint256 _maxWallet_) external onlyOwner {
    //     _maxWallet = _maxWallet_;
    // }

    /**
    * @dev Transfers the ownership of the contract to zero address
    * onlyOwner modifier
    */
    // function renounceOwnership() external onlyOwner {
    //     owner = address(0);
    // }

    // /**
    // * @dev Adds liquidity to the contract.
    // * @param _blockToUnlockLiquidity: the block number to unlock the liquidity.
    // * value: the amount of ETH to add to the liquidity.
    // * onlyOwner modifier
    // */
    // function addLiquidity(uint32 _blockToUnlockLiquidity) public onlyOwner payable {

    //     require(liquidityAdded == false, "Liquidity already added");

    //     liquidityAdded = true;

    //     require(msg.value > 0, "No ETH sent");
    //     require(block.number < _blockToUnlockLiquidity, "Block number too low");
        
    //     blockToUnlockLiquidity = _blockToUnlockLiquidity;
    //     tradingEnable = true;
    //     liquidityProvider = msg.sender;
        
    //     emit AddLiquidity(_blockToUnlockLiquidity, msg.value);
    // }

    // /**
    // * @dev Removes liquidity from the contract.
    // * onlyLiquidityProvider modifier
    // */
    // function removeLiquidity() public onlyLiquidityProvider {

    //     require(block.number > blockToUnlockLiquidity, "Liquidity locked");

    //     tradingEnable = false;

    //     payable(msg.sender).transfer(address(this).balance);

    //     emit RemoveLiquidity(address(this).balance);

    // }

    // /**
    // * @dev Extends the liquidity lock, only if the new block number is higher than the current one.
    // * @param _blockToUnlockLiquidity: the new block number to unlock the liquidity.
    // * onlyLiquidityProvider modifier
    // */
    // function extendLiquidityLock(uint32 _blockToUnlockLiquidity) public onlyLiquidityProvider {

    //     require(blockToUnlockLiquidity < _blockToUnlockLiquidity, "You can't shorten duration");

    //     blockToUnlockLiquidity = _blockToUnlockLiquidity;
    // }

    /**
    * @dev Estimates the amount of tokens or ETH to receive when buying or selling.
    * @param value: the amount of ETH or tokens to swap.
    * @param _buy: true if buying, false if selling.
    */
    function getAmountOut(uint256 value, bool _buy) public view returns(uint256) {

        (uint256 reserveETH, uint256 reserveToken) = getReserves();

        if (_buy) {
            return (value * reserveToken) / (reserveETH + value);
        } else {
            return (value * reserveETH) / (reserveToken + value);
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /**
    * @dev Buys tokens with ETH.
    * internal function
    */
    function buy() internal {
        require(tradingEnable, "Trading not enable");
        
        uint256 token_amount = (msg.value * _balances[address(this)]) / (address(this).balance);
        _beforeTokenTransfer(address(this), msg.sender, token_amount);
        // if (maxWalletEnable) {
        //     require(token_amount + _balances[msg.sender] <= _maxWallet, "Max wallet exceeded");
        // }

        _transfer(address(this), msg.sender, token_amount);

        emit Swap(msg.sender, msg.value,0,0,token_amount);
        _afterTokenTransfer(address(this), msg.sender, token_amount);
    }

    /**
    * @dev Sells tokens for ETH.
    * internal function
    */
    function sell(uint256 sellAmount) internal {

        require(tradingEnable, "Trading not enable");

        uint256 ethAmount = (sellAmount * address(this).balance) / (_balances[address(this)] + sellAmount);
        _beforeTokenTransfer(address(this), msg.sender, sellAmount);

        require(ethAmount > 0, "Sell amount too low");
        require(address(this).balance >= ethAmount, "Insufficient ETH in reserves");

        _transfer(msg.sender, address(this), sellAmount);
        payable(msg.sender).transfer(ethAmount);

        emit Swap(msg.sender, 0,sellAmount,ethAmount,0);
        _afterTokenTransfer(address(this), msg.sender, sellAmount);
    }

    /**
    * @dev Fallback function to buy tokens with ETH.
    */
    receive() external payable {
        buy();
    }
}