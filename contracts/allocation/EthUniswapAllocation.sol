pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./UniswapAllocation.sol";

contract EthUniswapAllocation is UniswapAllocation {

    address WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    constructor(address _token, address core) 
        UniswapAllocation(_token, core) 
    public {}

    function deposit(uint256 ethAmount) external override payable {
    	require(ethAmount == msg.value, "Bonding Curve: Sent value does not equal input");
        uint256 feiAmount = getAmountFeiToDeposit(ethAmount);
        _addLiquidity(ethAmount, feiAmount);
    }

    function addLiquidity(uint256 feiAmount) public payable onlyGovernor {
        require(msg.value > 0);
        _addLiquidity(msg.value, feiAmount);
    } 

    function removeLiquidity(uint256 liquidity, uint256 amountETHMin) internal override returns (uint256) {
        (, uint256 amountWithdrawn) = router().removeLiquidityETH(
            address(fei()),
            liquidity,
            0,
            0,
            address(this),
            uint256(-1)
        );
        return amountWithdrawn;
    }

    function transferWithdrawn(address to, uint256 amount) internal override {
        payable(to).transfer(amount);
    }

    function _addLiquidity(uint256 ethAmount, uint256 feiAmount) internal {
        mintFei(feiAmount);
        router().addLiquidityETH{value : ethAmount}(address(fei()),
            feiAmount,
            0,
            0,
            address(this),
            uint256(-1)
        );
    }

    fallback () external payable {

    }
}