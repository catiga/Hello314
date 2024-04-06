const { deploy } = require("truffle-contract/lib/execute");

const ERC2510 = artifacts.require("Tp2510");

module.exports = async function (deployer) {
  
  await deployer.deploy(ERC2510, '0xFaD652ad544a85c87F00285EB64acDa7d79E20B6', 'First Token 2510', 'FTN', web3.utils.toWei('99999', 'ether'), 9, 1000, 4500, 
    {
      value: web3.utils.toWei('0.01', 'ether')
    });
  console.log('deployed ERC2510', ERC2510.address)
};