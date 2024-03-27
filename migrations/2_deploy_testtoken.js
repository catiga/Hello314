const { deploy } = require("truffle-contract/lib/execute");

const Nova314 = artifacts.require("Nova314");

module.exports = async function (deployer) {
  
  await deployer.deploy(Nova314);
  console.log('deployed Nova314', Nova314.address)
};