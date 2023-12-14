// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
 
// DEPLOYED EN SEPOLIA  0x38025261cF3D98A41fad897bb23Ad2c383163796

// router sepolia:0x0bf3de8c5d3e8a2b34d2beeb17abfcebaf363a59 
// NFTaddress 0xBd37873Db48E7E082265FF08294F201D8E554BfD

// QUE HACE?
//  implementa ccipReceiver, y ejecuta la funcion mint en el avalncheNFT


import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {HonorloansNFT} from "./HONORLOANSnft.sol";
 
contract DestinationMinter is CCIPReceiver {
    HonorloansNFT nft;
 
    event MintCallSuccessfull();
 
    constructor(address router, address nftAddress) CCIPReceiver(router) {
        nft = HonorloansNFT(nftAddress);
    }
 
    function _ccipReceive(Client.Any2EVMMessage memory message) internal override {
        (bool success, ) = address(nft).call(message.data);
        require(success);
        emit MintCallSuccessfull();
    }

  
}