const NovaRouter = artifacts.require('NovaRouter');
const NovaProxy = artifacts.require('NovaProxy');

contract('NovaRouter through NovaProxy', (accounts) => {
    describe("cleanState", function() {
        let novaRouterInstance;
        let novaProxyInstance;

        it(`should return Name:`, async () => {
            novaRouterInstance = await NovaRouter.at('0x398257729721c4070459496ba1cACD254ceA3CEc')
            novaProxyInstance = await NovaProxy.at('0x765dE71f18b444C4EAd36786b22b71E19BC71D58')
            const owner = await novaProxyInstance.owner();
            const impl = await novaProxyInstance.getImplementation()
            const novaLogicInstanceAtProxyAddress = new web3.eth.Contract(NovaRouter.abi, novaProxyInstance.address);

            // await novaLogicInstanceAtProxyAddress.methods.initialize().send({ from: accounts[0], gasPrice:8000000000, gas:5000000 });
            const selltax = await novaLogicInstanceAtProxyAddress.methods.sellTax().call()
            console.log('owner', owner)
            console.log('impl', impl)
            console.log('sell tax', selltax)
            console.log('accounts', accounts)

            const tokenLength = await novaLogicInstanceAtProxyAddress.methods.tokenLength().call()
            console.log('tokenLength', tokenLength)

            const tokenInfo = await novaLogicInstanceAtProxyAddress.methods.getTokenInfo('0x10F86D3C97A0dF10a5399363Af175a4F9bB69363').call()
            console.log('tokenInfo', tokenInfo)

            // const result = await novaLogicInstanceAtProxyAddress.methods.adjustTax(20, 20).send({ from: accounts[0], gasPrice:8000000000, gas:5000000 });
            // console.log('adjust tax result', result)
            
            // const result = await novaLogicInstanceAtProxyAddress.methods.reinitialize(500000).send({ from: accounts[0], gasPrice:8000000000, gas:5000000 });
            // console.log('adjust reinitialize result', result)
        });
    })
  
});
