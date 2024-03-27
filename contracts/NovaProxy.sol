// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NovaProxy is ERC1967Proxy, Ownable {

    constructor(address _logic, bytes memory _data) ERC1967Proxy(_logic, _data) Ownable(msg.sender) {
    }

    function getImplementation() view public returns(address) {
        return _implementation();
    }

    function upgradeTo(address newImplementation, bytes memory data) external onlyOwner {
        ERC1967Utils.upgradeToAndCall(newImplementation, data);
    }

    receive() external payable {}
}