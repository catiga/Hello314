// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "./interfaces/IEERC314.sol";
import "./eips/IERC2510.sol";
import "./interfaces/IVR.sol";

contract NovaRouter is Initializable, INova { //, OwnableUpgradeable, INova {
    
    address public dever;
    uint256 public buyTax;
    uint256 public sellTax;

    address[] private _tokenList;
    mapping(address => bool) public suppTokens;
    mapping(address => mapping(address => uint256)) private tokenWalletBalances;
    mapping(address => uint256) public tokenTvl;

    uint256 private _gasLimit;

    bool private _locked;

    function initialize() public initializer {
        dever = msg.sender;
        buyTax = 10;
        sellTax = 10;
        _gasLimit = 500000;
    }

    modifier onlyDev {
        require(msg.sender == dever, "permissionless to make this operation");
        _;
    }

    modifier noReentrancy() {
        require(!_locked, "No re-entrancy");
        _locked = true;
        _;
        _locked = false;
    }

    function reinitialize(uint256 gaslimit) onlyDev external {
        _gasLimit = gaslimit;
    }

    function claimTradingFee(uint256 amount) onlyDev external {
        if(amount==0 || amount >= address(this).balance) {
            payable(msg.sender).transfer(address(this).balance);
        } else {
            payable(msg.sender).transfer(amount);
        }
    }

    function adjustTax(uint256 _buyTax, uint256 _sellTax) onlyDev external {
        require(_buyTax < 1000 && _sellTax < 1000, "exceed max tax amount");
        buyTax = _buyTax;
        sellTax = _sellTax;
    }

    function tokenLength() view public returns(uint256) {
        return _tokenList.length;
    }

    function balanceOf(address _token) view public returns(uint256 ext, uint256 ins) {
        (ext, ins) = (IEERC314Meta(_token).balanceOf(msg.sender), tokenWalletBalances[_token][msg.sender]);
    }

    function tokenListSimple(uint256 _from, uint256 _to) view external returns(address[] memory) {
        require(_from <= _to, "Invalid indexes");
        require(_to <= _tokenList.length, "Index out of bounds");
        uint256 length = _to - _from + 1;
        address[] memory partialList = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            partialList[i] = _tokenList[_from + i];
        }
        return partialList;
    }

    function tokenListRich(uint256 _from, uint256 _to) view external returns(TokenInfo[] memory) {
        require(_from <= _to, "Invalid indexes");
        require(_to <= _tokenList.length, "Index out of bounds");
        uint256 length = _to - _from + 1;
        TokenInfo[] memory partialList = new TokenInfo[](length);
        for (uint256 i = 0; i < length; i++) {
            partialList[i] = getTokenInfo(_tokenList[_from + i]);
        }
        return partialList;
    }

    function checkSupportsInterface(address _contract, bytes4 _interfaceId) public view returns (bool) {
        (bool success, bytes memory result) = _contract.staticcall(abi.encodeWithSelector(IERC165.supportsInterface.selector, _interfaceId));
        return (success && result.length == 32 && abi.decode(result, (bool)));
    }

    function getTokenInfo(address _token314) view public returns(TokenInfo memory data) {
        if(checkSupportsInterface(_token314, type(IEERC314Meta).interfaceId)) {
            return getIEERC314MetaInfo(_token314);
        } else if(checkSupportsInterface(_token314, type(IERC2510).interfaceId)) {
            return getIERC2510Info(_token314);
        }
        revert("unsupported protocol");
    }

    function getIEERC314MetaInfo(address _token314) public view returns (TokenInfo memory data) {
        data.ca = _token314;
        data.blockToUnlockLiquidity = IEERC314Meta(_token314).blockToUnlockLiquidity();
        data.decimals = IEERC314Meta(_token314).decimals();
        (data.pool0p, data.pool1p) = IEERC314Meta(_token314).getReserves();
        data.liquidityAdded = IEERC314Meta(_token314).liquidityAdded();
        data.liquidityProvider = IEERC314Meta(_token314).liquidityProvider();
        data.name = IEERC314Meta(_token314).name();
        // data.owner = IEERC314Meta(_token314).owner();
        data.symbol = IEERC314Meta(_token314).symbol();
        data.totalSupply = IEERC314Meta(_token314).totalSupply();
        data.tradingEnable = IEERC314Meta(_token314).tradingEnable();
        data.tokenProp = 1;
        return data;
    }

    function getIERC2510Info(address _token314) public view returns (TokenInfo memory data) {
        data.ca = _token314;
        data.decimals = IERC2510(_token314).decimals();
        (data.pool0p, data.pool1p) = IERC2510(_token314).getReserves();
        data.name = IERC2510(_token314).name();
        data.symbol = IERC2510(_token314).symbol();
        data.totalSupply = IERC2510(_token314).totalSupply();
        data.tokenProp = 2;
        return data;
    }

    function routeBuyOut(address _t0Addr, uint256 _t0Amount) view public returns(uint256) {
        require(_t0Addr!=address(0) && _t0Amount > 0, "invalid params");
        return IEERC314Meta(_t0Addr).getAmountOut(_t0Amount, true);
    }

    function routeSellOut(address _t0Addr, uint256 _t0Amount) view public returns(uint256) {
        require(_t0Addr!=address(0) && _t0Amount > 0, "invalid params");
        return IEERC314Meta(_t0Addr).getAmountOut(_t0Amount, false);
    }

    // swaptype 0:buy; 1:sell
    function _renounceTradeFee(uint256 _coinAmount, uint256 _swapType) internal returns(uint256) {
        uint256 maxFee = 0;
        if(_swapType==0) {
            if(buyTax > 0 && _coinAmount > 0 && buyTax < 1000) {
                maxFee = _coinAmount * buyTax / 10000;
            }
        } else if(_swapType==1) {
            if(sellTax > 0 && _coinAmount > 0 && sellTax < 1000) {
                maxFee = _coinAmount * sellTax / 10000;
            }
        }
        if(maxFee > 0 && address(this).balance > maxFee) {
            payable(dever).transfer(maxFee);
            emit IVRFee(msg.sender, maxFee);
        }
        return _coinAmount - maxFee;
    }

    function _checkTokenList(address _token) internal {
        if(!suppTokens[_token]) {
            _tokenList.push(_token);
            suppTokens[_token] = true;
        }
    }

    function _deductBalance(address _token, uint256 _amount) internal returns(bool) {
        (, uint256 ins) = balanceOf(_token);
        if(ins >= _amount) {
            tokenWalletBalances[_token][msg.sender] = ins - _amount;
            return true;
        }
        return false;
    }

    function claimMyToken(address _token, uint256 _amount) external {
        require(tokenWalletBalances[_token][msg.sender] >= _amount, "exceed allowance");
        require(_amount > 0 && _token != address(0), "invalid params");
        IEERC314Meta(_token).transfer(msg.sender, _amount);
    }

    function swapBuyLimit(address _token, uint256 _minAmount) external payable noReentrancy {
        require(_token != address(0), "invalid token address");
        require(msg.value > 0, "pay value should be greater than 0");
        _checkTokenList(_token);
        uint256 payValue = _renounceTradeFee(msg.value, 0);
        if(_minAmount > 0 && routeBuyOut(_token, payValue) < _minAmount) {
            revert("slippage overflow reverted");
        }
        uint256 _balanceBefore = IEERC314Meta(_token).balanceOf(address(this));
        // bool success = payable(_token).send(payValue);
        (bool success, bytes memory data) = payable(_token).call{value: payValue, gas:_gasLimit}("");
        if(!success) {
            revert ERCGeneralExternalError(data);
        }
        uint256 _realOut = IEERC314Meta(_token).balanceOf(address(this)) - _balanceBefore;
        require(_realOut >= _minAmount, "slippage overflow failed");
        // IEERC314Meta(_token).transfer(msg.sender, _realOut);
        tokenWalletBalances[_token][msg.sender] += _realOut;
        tokenTvl[_token] += _realOut;

        emit IVRSwap(msg.sender, address(0), _token, payValue, _realOut);
    }

    function swapBuyReck(address _token) external payable noReentrancy {
        require(_token != address(0), "invalid token address");
        require(msg.value > 0, "pay value should be greater than 0");
        _checkTokenList(_token);
        uint256 payValue = _renounceTradeFee(msg.value, 0);
        
        uint256 _balanceBefore = IEERC314Meta(_token).balanceOf(address(this));
        (bool success, bytes memory data) = payable(_token).call{value: payValue, gas: _gasLimit}("");
        if(!success) {
            revert ERCGeneralExternalError(data);
        }
        uint256 _realOut = IEERC314Meta(_token).balanceOf(address(this)) - _balanceBefore;
        // IEERC314Meta(_token).transfer(msg.sender, _realOut);
        tokenWalletBalances[_token][msg.sender] += _realOut;
        tokenTvl[_token] += _realOut;

        emit IVRSwap(msg.sender, address(0), _token, payValue, _realOut);
    }

    function swapSellLimit(address _token, uint256 _sellAmount, uint256 _minAmount) external noReentrancy {
        require(_token != address(0), "invalid token address");
        _checkTokenList(_token);

        uint256 _balanceBefore = address(this).balance;
        require(_deductBalance(_token, _sellAmount), "insufficient balance");
        // require(IEERC314Meta(_token).transfer(_token, _sellAmount), "token transfer failed");
        (bool ok, bytes memory data) = _token.call{gas: _gasLimit}(abi.encodeWithSignature("transfer(address,uint256)", _token, _sellAmount));
        if(!ok) {
            revert ERCGeneralExternalError(data);
        }
        uint256 _balanceAfter = address(this).balance;

        require(_balanceAfter > _balanceBefore, "solid error with balance check");

        uint256 renonceValue = _renounceTradeFee(_balanceAfter - _balanceBefore, 1);
        require(renonceValue >= _minAmount, "slippage overflow reverted");
        tokenTvl[_token] -= _sellAmount;
        payable(msg.sender).transfer(renonceValue);

        emit IVRSwap(msg.sender, _token, address(0), _sellAmount, renonceValue);
    }

    function swapSellReck(address _token, uint256 _sellAmount) external noReentrancy {
        require(_token != address(0), "invalid token address");
        _checkTokenList(_token);

        uint256 _balanceBefore = address(this).balance;
        require(_deductBalance(_token, _sellAmount), "insufficient token balance");
        // require(IEERC314Meta(_token).transfer(_token, _sellAmount), "token transfer failed");
        (bool ok, bytes memory data) = _token.call{gas: _gasLimit}(abi.encodeWithSignature("transfer(address,uint256)", _token, _sellAmount));
        if(!ok) {
            revert ERCGeneralExternalError(data);
        }
        uint256 _balanceAfter = address(this).balance;

        require(_balanceAfter >= _balanceBefore, "solid error with balance check");

        uint256 renonceValue = _renounceTradeFee(_balanceAfter - _balanceBefore, 1);
        tokenTvl[_token] -= _sellAmount;
        payable(msg.sender).transfer(renonceValue);

        emit IVRSwap(msg.sender, _token, address(0), _sellAmount, renonceValue);
    }



    function uintToString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

}