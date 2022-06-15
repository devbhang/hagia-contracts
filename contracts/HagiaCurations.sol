// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

// @creator: HAGIA
// @title: Hagia Curations
// @author: @devbhang - devbhang.eth
// @author: @hazelrah_nft - hazelrah.eth

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                                                    //
//                                                                                                                                                    //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

contract HagiaCurations is ERC1155URIStorage, ERC1155Burnable, ERC1155Supply, Ownable {
	
	enum SaleStatus {
		NoSale,
		PrivateSale,
		PublicSale,
		SaleFinished
	}
	
	SaleStatus saleStatus = SaleStatus.NoSale;
	
	uint256 public constant MAX_MINT_PRIVATE = 101;
	uint256 public constant MAX_MINT_PUBLIC = 11;
	
	uint256 public price = 0.03 ether;
	uint256 public discountPrice = 0.03 ether;
	
	address public treasuryAddress;
	
	uint256 private _tokenId;
	
	bytes32 private _merkleRoot;
	
	mapping(uint256 => mapping(address => uint256)) private _addressMintCountById;
	
	constructor() ERC1155("") {}
	
	function setPrice(uint256 _price, uint256 _discountPrice) external onlyOwner {
		price = _price;
		discountPrice = _discountPrice;
	}
	
	function getSaleStatus() public view returns (SaleStatus) {
		return saleStatus;
	}
	
	function setSaleStatus(uint256 _saleStatus, bytes32 _root) external onlyOwner {
		saleStatus = SaleStatus(_saleStatus);
		_merkleRoot = _root;
	}
	
	function setToken(uint256 _newId, string calldata _tokenUri) external onlyOwner {
		_tokenId = _newId;
		_setURI(_newId, _tokenUri);
	}
	
	function _claimToken(uint256 _amount, uint256 _price, uint256 _maxMint) internal virtual {
		require(tx.origin == msg.sender, "ONLY HUMANS ALLOWED");
		require(_addressMintCountById[_tokenId][msg.sender] + _amount < _maxMint, "MAX MINT PER WALLET IS EXCEEDED");
		require(msg.value >= _price * _amount, "NOT ENOUGH ETHERS SEND");
		
		_mint(msg.sender, _tokenId, _amount, "");
		_addressMintCountById[_tokenId][msg.sender] += _amount;
	}
	
	function claimTokenPrivate(uint256 _amount, bytes32[] calldata _merkleProof) external payable {
		require(saleStatus == SaleStatus.PrivateSale, "PRIVATE SALE IS NOT OPEN");
		require(MerkleProof.verify(_merkleProof, _merkleRoot, keccak256(abi.encodePacked(msg.sender))), "ADDRESS NOT WHITELISTED");
		
		_claimToken(_amount, discountPrice, MAX_MINT_PRIVATE);
	}
	
	function claimTokenPublic(uint256 _amount) external payable {
		require(saleStatus == SaleStatus.PublicSale, "PUBLIC SALE IS NOT OPEN");
		
		_claimToken(_amount, price, MAX_MINT_PUBLIC);
	}
	
	function mintAdmin(address[] calldata _to, uint256[] calldata _amount) external onlyOwner {
		require(saleStatus == SaleStatus.SaleFinished, "CAN'T MINT DURING SALE");
		require(_to.length == _amount.length, "AMOUNT MUST MATCH DATA");
		
		for (uint i; i < _to.length; i++) {
			_mint(_to[i], _tokenId, _amount[i], "");
		}
	}
	
	function uri(uint256 tokenId) public view virtual override(ERC1155, ERC1155URIStorage) returns (string memory) {
		return super.uri(tokenId);
	}
	
	function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
	internal
	override(ERC1155, ERC1155Supply)
	{
		super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
	}
	
	function _afterTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
	internal
	override(ERC1155)
	{
		super._afterTokenTransfer(operator, from, to, ids, amounts, data);
	}
	
	function withdraw() external onlyOwner {
		require(saleStatus == SaleStatus.SaleFinished, "CAN'T WITHDRAW DURING SALE");
		require(address(this).balance > 0, "INSUFFICIENT FUNDS");
		
		payable(treasuryAddress).transfer(address(this).balance);
	}
	
}