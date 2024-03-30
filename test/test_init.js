const NovaRouter = artifacts.require('NovaRouter');
const NovaProxy = artifacts.require('NovaProxy');

contract('NovaRouter through NovaProxy', (accounts) => {
    describe("cleanState", function() {
        let novaRouterInstance;
        let novaProxyInstance;

        it(`should return Name:`, async () => {
            novaRouterInstance = await NovaRouter.at('0x4Ae16fA80CAFFD6De15D38Ad0429601d8245e182')
            novaProxyInstance = await NovaProxy.at('0x09dCc8616358e0D0B4f2789aF2BD81c9c9c69E51')
            const owner = await novaProxyInstance.owner();
            const impl = await novaProxyInstance.getImplementation()
            const novaLogicInstanceAtProxyAddress = new web3.eth.Contract(NovaRouter.abi, novaProxyInstance.address);

            await novaLogicInstanceAtProxyAddress.methods.initialize().send({ from: accounts[0], gasPrice:8000000000, gas:5000000 });
            const selltax = await novaLogicInstanceAtProxyAddress.methods.sellTax().call()
            console.log('owner', owner)
            console.log('impl', impl)
            console.log('sell tax', selltax)
            console.log('accounts', accounts)

            // const result = await novaLogicInstanceAtProxyAddress.methods.adjustTax(20, 20).send({ from: accounts[0], gasPrice:8000000000, gas:5000000 });
            // console.log('adjust tax result', result)
            
            // const result = await novaLogicInstanceAtProxyAddress.methods.reinitialize(500000).send({ from: accounts[0], gasPrice:8000000000, gas:5000000 });
            // console.log('adjust reinitialize result', result)
            // novaLogicInstanceAtProxyAddress.methods.
        });
    })
  
});
