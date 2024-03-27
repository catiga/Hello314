const NovaRouter = artifacts.require('NovaRouter');
const NovaProxy = artifacts.require('NovaProxy');

contract('NovaRouter Buy', (accounts) => {
    describe("buy", function() {
        let novaRouterInstance;
        let novaProxyInstance;

        it(`should return Name:`, async () => {
            novaRouterInstance = await NovaRouter.at('0x8f230039551B019d371482a0FDb805232Aa443A0')
            novaProxyInstance = await NovaProxy.at('0x8F68B5B6E9ef006a543c37109aBf9F31D37fEE73')
            const owner = await novaProxyInstance.owner();
            const impl = await novaProxyInstance.getImplementation()
            console.log(owner, impl)
            
            const novaLogicInstanceAtProxyAddress = new web3.eth.Contract(NovaRouter.abi, novaProxyInstance.address);

            // await novaLogicInstanceAtProxyAddress.methods.initialize().send({ from: accounts[0], gasPrice:8000000000, gas:5000000 });
            const result = await novaLogicInstanceAtProxyAddress.methods.swapBuyReck('0xf506Ec19d64ab3850A52FAEC139D2b2fb071e839').send({ from: accounts[0], gasPrice:8000000000, gas:5000000 })
            console.log('买入交易结果', result)
            
        });
    })
  
});
