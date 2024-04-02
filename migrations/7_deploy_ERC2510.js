const { deploy } = require("truffle-contract/lib/execute");

const ERC2510 = artifacts.require("ERC2510");

module.exports = async function (deployer) {
  
  await deployer.deploy(ERC2510, 'First Token 2510', 'FTN', web3.utils.toWei('33333333', 'ether'));
  console.log('deployed ERC2510', ERC2510.address)
};