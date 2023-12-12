//SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

// DEPLOYED ON Fuji at 0x6D0260C0E12883a7582ba0c434B53a75E2F3e680
// for token 0x0c08791679577b50671C6540766C9A4684D2745f 
// DATA FEED
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

interface TokenInterface {
        function mint (address account, uint256 amount) external returns (bool);
}


contract depositContract {

    AggregatorV3Interface internal priceFeed;
    TokenInterface public minter;
    uint256 public tokenPrice  = 20000; // 1 token 200.00 usd, with 2 decimal places
    address public owner;

    constructor (address tokenAddress) {
        minter = TokenInterface (tokenAddress);
           /**
        Network: fuji
        Aggregator: AVAX / USD
        Address: 0x5498BB86BC934c8D34FDA08E81D444153d0D06aD
        https://docs.chain.link/data-feeds/price-feeds/addresses?network=ethereum&page=1&search=
        */
            priceFeed = AggregatorV3Interface (0x5498BB86BC934c8D34FDA08E81D444153d0D06aD);
            owner = msg.sender;

    } 
 

// Returns the latest price
function getLatestPrice() public view returns (int) {
    (
        /*uint80 roundID*/,
        int price,
        /*uint startedAt*/,
        /* uint timeStamp*/, 
        /*uint80 answeredInRound*/ 
    ) = priceFeed.latestRoundData(); 
    return price;
    }


    function tokenAmount (uint256 amountETH) public view returns (uint256){

        //Sent amountETH,  how many usd I have
        uint256 ethUsd = uint256 (getLatestPrice());
        uint256 amountUSD = amountETH * ethUsd / 1000000000000000000;//ETH 18 décimal places
        uint256 amountToken = amountUSD/ tokenPrice / 100; //2 decimals places
        return amountToken;
    }


    receive() external payable {
        uint256 amountToken = tokenAmount (msg.value);
        minter.mint (msg.sender, amountToken);
    }

    modifier onlyOwner(){
        require (msg.sender == owner);
        _;
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }


}
