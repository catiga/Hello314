const Nova314 = artifacts.require('Nova314');


contract('Nova314 Launch', (accounts) => {
    describe("add liquidity", function() {
        it(`should return Name:`, async () => {
            let tokenIns = await Nova314.at('0x817872542c8cACE08014a83899829183Bb904D5e')
            
            const result = await tokenIns.addLiquidity(58771879 + 1000000,
                { from: accounts[0], gasPrice:8000000000, gas:5000000, value: web3.utils.toWei('1', 'ether') }
            );
            console.log('添加流动性结果', result)
        });
    })
  
});
