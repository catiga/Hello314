// SPDX-License-Identifier: MIT

//https://linktr.ee/simplifyerc

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./TplStandard.sol";

contract TokenFactory is Ownable {
    event NewDeployed(address indexed deployer, address indexed contractAddr);

    mapping(address => address[]) public deployedContracts;
    mapping(bytes32 codeHash => bool) public securityCodes;
    bytes32[] public tpls;

    constructor() Ownable(msg.sender){
        bytes memory bytecode = type(TplStandard).creationCode;
        bytes32 codeHash = keccak256(bytecode);
        securityCodes[codeHash] = true;
        tpls.push(codeHash);
    }

    function getTpls() public view returns(bytes32[] memory) {
        return tpls;
    }

    function deployContract(bytes memory bytecode, bytes memory constructorArgs) public {
        bytes32 codeHash = keccak256(bytecode);
        require(securityCodes[codeHash], string(abi.encodePacked("Invalid bytecode hash:", bytes32ToHexString(codeHash))));

        bytes memory fullBytecode = bytes.concat(bytecode, constructorArgs);
        address contractAddr;
        assembly {
            contractAddr := create(0, add(fullBytecode, 0x20), mload(fullBytecode))
        }

        require(contractAddr != address(0), "Failed to deploy contract");

        emit NewDeployed(msg.sender, contractAddr);
    }

    function configCode(bytes32 codeHash, bool enable) onlyOwner public {
        securityCodes[codeHash] = enable;
    }

    bytes16 private constant ALPHABET = "0123456789abcdef";

    function bytes32ToHexString(bytes32 value) public pure returns (string memory) {
        bytes memory buffer = new bytes(64);
        for (uint256 i = 0; i < 32; i++) {
            buffer[i*2] = ALPHABET[uint8(value[i] >> 4)];
            buffer[1+i*2] = ALPHABET[uint8(value[i] & 0x0f)];
        }

        return string(abi.encodePacked("0x", buffer));
    }
    
}