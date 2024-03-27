const { deploy } = require("truffle-contract/lib/execute");

const TokenFactory = artifacts.require("TokenFactory");

module.exports = async function (deployer) {
  
  await deployer.deploy(TokenFactory);
  console.log('deployed TokenFactory', TokenFactory.address)
};