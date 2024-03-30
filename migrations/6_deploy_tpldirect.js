const { deploy } = require("truffle-contract/lib/execute");

const TplStandard = artifacts.require("TplStandard");

module.exports = async function (deployer) {
  
  await deployer.deploy(TplStandard, "0xe38533e11B680eAf4C9519Ea99B633BD3ef5c2F8", 'First Token 314', 'FT', 33333333, "6666666600000000000000000");
  console.log('deployed TplStandard', TplStandard.address)
};