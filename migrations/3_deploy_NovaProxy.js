const { deploy } = require("truffle-contract/lib/execute");

const NovaRouter = artifacts.require("NovaRouter");
const NovaProxy = artifacts.require("NovaProxy");

module.exports = async function (deployer, network, accounts) {

  await deployer.deploy(NovaRouter);
  console.log('NovaRouter deploy succeed:', NovaRouter.address)

  const novaProxyInstance = await deployer.deploy(NovaProxy, NovaRouter.address, "0x")
  
  const novaLogicInstanceAtProxyAddress = new web3.eth.Contract(NovaRouter.abi, novaProxyInstance.address);

  await novaLogicInstanceAtProxyAddress.methods.initialize().send({ from: accounts[0] });
};