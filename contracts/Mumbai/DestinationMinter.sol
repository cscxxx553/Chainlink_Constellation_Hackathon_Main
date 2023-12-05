// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";
import "openzeppelin-contracts/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
// import "./Function_GetWeather.sol";
import {CCIPReceiver} from "chainlink/contracts/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {Client} from "chainlink/contracts/src/v0.8/ccip/libraries/Client.sol";

contract MyNFT1155 is ERC1155, Ownable, ERC1155Burnable {
    constructor(address initialOwner) ERC1155("https://fuchsia-colossal-blackbird-501.mypinata.cloud/ipfs/QmYaeUzcg1GXnVAXq7oLGerdez7xc73g5mBwwFTjZJqRy6/{id}.json") Ownable(initialOwner) {

    }

    // function setURI(string memory newuri) public onlyOwner {
    //     _setURI(newuri);
    // }

    function mint(address account)
        public
    {
        // string memory catType = getCatTypeBaseOnWeather();
        // uint256 id = uint256(uint8(bytes(catType)[0])-48);
        bytes memory data;
        _mint(account, 2, 1, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

    // Override the URI for token-specific metadata
    function uri(uint256 _tokenid) public pure override returns(string memory){
	    return
		    string(
			    abi.encodePacked(
				    "https://fuchsia-colossal-blackbird-501.mypinata.cloud/ipfs/QmYaeUzcg1GXnVAXq7oLGerdez7xc73g5mBwwFTjZJqRy6/",
				    Strings.toString(_tokenid),
				    ".json"
			    )
		    );
    }

    function contractURI() public pure returns(string memory) {
	return
		"https://fuchsia-colossal-blackbird-501.mypinata.cloud/ipfs/QmYaeUzcg1GXnVAXq7oLGerdez7xc73g5mBwwFTjZJqRy6/collection.json";
	}

    // function getCatTypeBaseOnWeather() public view returns(string memory) {
    //     GettingStartedFunctionsConsumer gsfc = GettingStartedFunctionsConsumer(0x62E96c6A62be0031d21d6EFdB4Ea4f5231f925c0);
    //     return gsfc.character();
    // }
}

contract DestinationMinter is CCIPReceiver {
    MyNFT1155 nft;

    event MintCallSuccessfull();

    constructor(address router, address nftAddress) CCIPReceiver(router) {
        nft = MyNFT1155(nftAddress);
    }

    function _ccipReceive(
        Client.Any2EVMMessage memory message
    ) internal override {
        (bool success, ) = address(nft).call(message.data);
        require(success);
        emit MintCallSuccessfull();
    }
}
