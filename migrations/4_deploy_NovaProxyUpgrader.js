const { deploy } = require("truffle-contract/lib/execute");

const NovaProxy = artifacts.require("NovaProxy");
const NovaRouter = artifacts.require("NovaRouter");

const _deployedRouter_ = "0x88D93a27430D29FDD52D9236649af5F668461FCa"
const _deployedProxy_ = "0x765dE71f18b444C4EAd36786b22b71E19BC71D58"

module.exports = async function (deployer) {
  let novaProxyInstance = await NovaProxy.at(_deployedProxy_);

  console.log("deploying new contract")
  await deployer.deploy(NovaRouter)

  console.log('NovaRouter match succeed:', NovaRouter.address)

  const replaceResult = await novaProxyInstance.upgradeTo(NovaRouter.address, "0x");
  console.log('replace logic contract:', replaceResult)
};