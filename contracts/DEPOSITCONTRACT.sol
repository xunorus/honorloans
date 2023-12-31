//SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
// COMO FUNCIONA
// PRE: autorizar al contrato DEPOSITCONTRACT a ejecutar la funcion en el HLOANtoken usando GRANTMINER con la address del DEPOSITCONTRACT
// El usuario que quiere el token (ver minter para saber su address), viene a este contrato DEPOSIT, 
//  y recibe lo que deposita en tokens con relacion al dolar
//  DEPOSITONBEHALF (tokenshop)SEPOLIA 0x9c58908d4d841C11Ca654395275cB94F20b6c1dE
//  HLOAN TOKEN SEPOLIA 0x0118148a6E156b5B39d1D184F8763e65Df8d36C7
 
 
// DATA FEED
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

interface TokenInterface {
        function xmint (address to, uint256 amount) external returns (bool);
}


contract depositOnBehalf {

    AggregatorV3Interface internal priceFeed;
    TokenInterface public minter;
    uint256 public tokenPrice  = 20000; // 1 token 200.00 usd, with 2 decimal places
    address public owner;

    constructor (address tokenAddress) {
        minter = TokenInterface (tokenAddress);
               /**
        Network: sepolia
        Aggregator: ETH / USD
        Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        https://docs.chain.link/data-feeds/price-feeds/addresses?network=ethereum&page=1&search=
        */
           
            priceFeed = AggregatorV3Interface (0x694AA1769357215DE4FAC081bf1f309aDC325306);
            owner = msg.sender;
           

    } 
 

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
        uint256 ethUsd = uint256 (getLatestPrice());
        uint256 amountUSD = amountETH * ethUsd / 1000000000000000000;//ETH 18 décimal places
        uint256 amountToken = amountUSD/ tokenPrice / 100; //2 decimals places
        return amountToken;
    }


    receive() external payable {
        uint256 amountToken = tokenAmount (msg.value);
        minter.xmint (msg.sender, amountToken);//ejecuta la funcion mint de la addres de minter(el hloan token)
    }

 function depositToCustomAddress(address customAddress) external payable {
        require(customAddress != address(0), "Invalid custom address");
        uint256 amountToken = tokenAmount(msg.value);
        minter.xmint(customAddress, amountToken);
    }


    modifier onlyOwner(){
        require (msg.sender == owner);
        _;
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }


}
