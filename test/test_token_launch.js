const Nova314 = artifacts.require('Tp2510');


contract('Nova314 Launch', (accounts) => {
    describe("add liquidity", function() {
        it(`should return Name:`, async () => {
            let tokenIns = await Nova314.at('0xe36f9e84e07e1b9569d199ec9c3b534cfe7b2775')
            
            const result = await tokenIns.addLiquidity(58771879 + 1000000,
                { from: accounts[2], gasPrice:8000000000, gas:5000000, value: web3.utils.toWei('0.1', 'ether') }
            );
            console.log('添加流动性结果', result)
        });
    })
  
});
