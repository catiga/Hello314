const { deploy } = require("truffle-contract/lib/execute");

const NovaProxy = artifacts.require("NovaProxy");
const NovaRouter = artifacts.require("NovaRouter");


const _deployedRouter_ = "0x4Ae16fA80CAFFD6De15D38Ad0429601d8245e182"
const _deployedProxy_ = "0x09dCc8616358e0D0B4f2789aF2BD81c9c9c69E51"

module.exports = async function (deployer) {
  let novaProxyInstance = await NovaProxy.at(_deployedProxy_);

  console.log("deploying new contract")
  await deployer.deploy(NovaRouter)

  console.log('NovaRouter match succeed:', NovaRouter.address)

  await novaProxyInstance.upgradeTo(NovaRouter.address, "0x");
};