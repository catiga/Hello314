const { deploy } = require("truffle-contract/lib/execute");

const NovaProxy = artifacts.require("NovaProxy");
const NovaRouter = artifacts.require("NovaRouter");

const _deployedRouter_ = "0xDBC8f17E165869532ee1E4b7e64D90dAE780f3B6"
const _deployedProxy_ = "0x3E58130455F143C05A0EF6426184b54DF31aA60C"

module.exports = async function (deployer) {
  let novaProxyInstance = await NovaProxy.at(_deployedProxy_);

  console.log("deploying new contract")
  await deployer.deploy(NovaRouter)

  console.log('NovaRouter match succeed:', NovaRouter.address)

  const replaceResult = await novaProxyInstance.upgradeTo(NovaRouter.address, "0x");
  console.log('replace logic contract:', replaceResult)
};