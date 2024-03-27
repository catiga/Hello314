const { deploy } = require("truffle-contract/lib/execute");

const NovaProxy = artifacts.require("NovaProxy");
const NovaRouter = artifacts.require("NovaRouter");


const _deployedRouter_ = "0x6A7E0eA8806EB07D9693541F20644DbAE5e1dcfC" //0x35a25dF6de3193e283c6708a5F30B1Ec606c8D3d
const _deployedProxy_ = "0x8F68B5B6E9ef006a543c37109aBf9F31D37fEE73"

module.exports = async function (deployer) {
  let novaProxyInstance = await NovaProxy.at(_deployedProxy_);

  console.log("deploying new contract")
  await deployer.deploy(NovaRouter)

  console.log('NovaRouter match succeed:', NovaRouter.address)

  await novaProxyInstance.upgradeTo(NovaRouter.address, "0x");
};