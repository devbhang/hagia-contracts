// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

// @creator: METACOLLECTIVE aka MXC
// @title: MXC : GENESIS
// @author: @berkozdemir - berk.eth
// @author: @devbhang - devbhang.eth
// @author: @hazelrah_nft - hazelrah.eth

import "erc721a/contracts/extensions/ERC721AQueryable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                                                    //
//                                                                                                                                                    //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

contract RaffleGraphy is ERC721AQueryable, Ownable, ERC2981 {
	
	enum SaleStatus {
		NoSale,
		PrivateSale,
		PreSale,
		PublicSale,
		SaleFinished
	}
	
	SaleStatus saleStatus = SaleStatus.NoSale;
	
	string public baseURI;
	
	uint256 public constant MAX_MINT_PRIVATE = 21;
	uint256 public constant MAX_MINT_PUBLIC = 11;
	
	uint256 public price = 0.1 ether;
	
	uint256 public maxSupply = 1001;
	
	address public treasuryAddress;
	
	bytes32 private _merkleRoot;
	
	mapping(address => uint256) private _addressMintCount;
	
	constructor() ERC721A("RaffleGraphy", "RFLGPHY") {}
	
	function addCreators(address[] calldata _creators) external onlyOwner {
		require(creators.length + _creators.length < MAX_MINT_PRIVATE, "TOO MANY CREATORS");
		
		for (uint i; i < _creators.length; i++) {
			creators.push(_creators[i]);
		}
	}
	
	function editCreators(uint _index, address _creator) external onlyOwner {
		require(_index < creators.length, "WRONG INDEX");
		
		creators[_index] = _creator;
	}
	
	function setRoyalty(address _address, uint96 _royalty) external onlyOwner {
		treasuryAddress = _address;
		_setDefaultRoyalty(_address, _royalty);
	}
	
	function setPrice(uint _price) external onlyOwner {
		price = _price;
	}
	
	function editMaxSupply(uint _maxSupply) external onlyOwner {
		require(_maxSupply < maxSupply, "MAX SUPPLY CAN'T EXCEED INITIAL SUPPLY");
		
		maxSupply = _maxSupply;
	}
	
	function setBaseURI(string calldata _newBaseURI) external onlyOwner {
		baseURI = _newBaseURI;
	}
	
	function _baseURI() internal view virtual override returns (string memory) {
		return baseURI;
	}
	
	function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721A, ERC2981) returns (bool) {
		return super.supportsInterface(interfaceId);
	}
	
	function getSaleStatus() public view returns (SaleStatus) {
		return saleStatus;
	}
	
	function setSaleStatus(uint256 _saleStatus, bytes32 _root) external onlyOwner {
		saleStatus = SaleStatus(_saleStatus);
		_merkleRoot = _root;
	}
	
	function _claimToken(uint256 _amount, uint256 _maxMint) internal virtual {
		require(tx.origin == msg.sender, "ONLY HUMANS ALLOWED");
		require(_addressMintCount[msg.sender] + _amount < _maxMint, "MAX MINT PER WALLET IS EXCEEDED");
		require(totalSupply() + _amount < maxSupply, "MAX SUPPLY IS EXCEEDED");
		require(msg.value >= price * _amount, "NOT ENOUGH ETHERS SEND");
		
		_mint(msg.sender, _amount);
		_addressMintCount[msg.sender] += _amount;
	}
	
	function claimTokenPrivate(uint256 _amount, bytes32[] calldata _merkleProof) external payable {
		require(saleStatus == SaleStatus.PrivateSale || saleStatus == SaleStatus.PreSale, "SALE IS NOT OPEN");
		require(MerkleProof.verify(_merkleProof, _merkleRoot, keccak256(abi.encodePacked(msg.sender))), "ADDRESS NOT WHITELISTED");
		
		uint256 _maxMint = saleStatus == SaleStatus.PrivateSale ? MAX_MINT_PRIVATE : MAX_MINT_PUBLIC;
		
		_claimToken(_amount, _maxMint);
	}
	
	function claimTokenPublic(uint256 _amount) external payable {
		require(saleStatus == SaleStatus.PublicSale, "PUBLIC SALE IS NOT OPEN");
		
		_claimToken(_amount, MAX_MINT_PUBLIC);
	}
	
	function mintAdmin(address[] calldata _to, uint _amount) external onlyOwner {
		require(saleStatus == SaleStatus.SaleFinished, "CAN'T MINT DURING SALE");
		require(totalSupply() + (_amount * _to.length) < maxSupply, "MAX SUPPLY IS EXCEEDED");
		
		for (uint i; i < _to.length; i++) {
			_mint(_to[i], _amount);
		}
	}
	
	function withdraw() external onlyOwner {
		require(saleStatus == SaleStatus.SaleFinished, "CAN'T WITHDRAW DURING SALE");
		require(address(this).balance > 0, "INSUFFICIENT FUNDS");
		
		payable(treasuryAddress).transfer(address(this).balance);
	}
	
	function burn(uint256 _tokenId) public {
		require(saleStatus == SaleStatus.SaleFinished, "CAN'T BURN DURING SALE");
		
		_burn(_tokenId, true);
	}
	
}
