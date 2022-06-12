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

contract HagiaCurations is ERC1155URIStorage, ERC1155Burnable, ERC1155Supply, Ownable {
	
	enum SaleStatus {
		NoSale,
		SaleOpen,
		SaleFinished
	}
	
	SaleStatus saleStatus = SaleStatus.NoSale;
	
	uint256 public price = 0.03 ether;
	uint256 public discountPrice = 0.03 ether;
	
	uint256 private _tokenId = 1;
	
	address public treasuryAddress;
	
	mapping(address => uint256) internal _totalBalanceOf;
	
	constructor() ERC1155("") {}
	
	function setPrice(uint256 _price, uint256 _discountPrice) external onlyOwner {
		price = _price;
		discountPrice = _discountPrice;
	}
	
	function getSaleStatus() external view returns (SaleStatus) {
		return saleStatus;
	}
	
	function setSaleStatus(uint256 _saleStatus) external onlyOwner {
		saleStatus = SaleStatus(_saleStatus);
	}
	
	function setTokenId(uint256 _newId, string calldata _tokenUri) external onlyOwner {
		_tokenId = _newId;
		_setURI(_tokenId, _tokenUri);
	}
	
	function getTotalBalanceOf(address _account) external view returns(uint256) {
		return _totalBalanceOf[_account];
	}
	
	function _hasBalance(address _account) internal view returns(bool) {
		if (_totalBalanceOf[_account] > 0)
			return true;

		return false;
	}
	
	function mint(uint256 _amount) external payable {
		require(tx.origin == msg.sender, "ONLY HUMANS ALLOWED");
		require(msg.value >= _amount * (_hasBalance(msg.sender) ? discountPrice : price), "NOT ENOUGH ETHERS SEND");
		
		_mint(msg.sender, _tokenId, _amount, "");
	}
	
	function mintAdmin(address[] calldata _to, uint256 _id, uint256[] calldata _amount) external onlyOwner {
		require(_to.length == _amount.length, "AMOUNT MUST MATCH DATA");
		
		for (uint i; i < _to.length; i++) {
			_mint(_to[i], _id, _amount[i], "");
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
		for (uint i; i < amounts.length; i++) {
			if (from != address(0))
				_totalBalanceOf[from] = _totalBalanceOf[from] - amounts[i];
			
			if (to != address(0))
				_totalBalanceOf[to] = _totalBalanceOf[to] + amounts[i];
		}
		
		super._afterTokenTransfer(operator, from, to, ids, amounts, data);
	}
	
	function withdraw() external onlyOwner {
		require(saleStatus == SaleStatus.SaleFinished, "CAN'T WITHDRAW DURING SALE");
		require(address(this).balance > 0, "INSUFFICIENT FUNDS");
		
		payable(treasuryAddress).transfer(address(this).balance);
	}
	
}