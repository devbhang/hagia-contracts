# HagiaCurations

### The Drop

Our main goal is to create a sustainable contract that will be used in future photography curations that Hagia Community will hold.

Photographers and artists will have to mint a HagiaCurations token, which will allow them to send photos and artworks to curations. Photos and artworks selected by Hagia Curation Team will be used in the drops.

### Whitelist

There will be 2 different sales:

1. Private Sale
3. Public Sale

#### Private Sale

Whitelist will be consist of 10 wallet addresses.
Restrictions:

* Max allowed min per wallet: 100 ``uint256 public constant MAX_MINT_PRIVATE``

#### Public Sale

There will be no whitelist. Public sale will be held on 22th of May.
Restrictions:

* Max allowed mint per wallet: 10 ``uint256 public constant MAX_MINT_PUBLIC``

### Contract

HagiaCurations.sol - created by Hagia Dev Team

### Minting

A metadata and media file which represents the upcoming drop will be added to ipfs, and the ID of the token and the URL of the metadata will be set before minting.

``function setToken(uint256 _newId, string calldata _tokenUri) external onlyOwner``

After setting the new token ID and URL artists can mint their own token like a regular ERC1155 minting process.


# RaffleGraphy

### The Drop

RaffleGraphy drop consists of 50 artworks with 20 editions each from 50 artists.

50 artwork x 20 editions => 1000 pieces total

### Whitelist

There will be 3 different sales:

1. Private Sale
2. Pre Sale
3. Public Sale

#### Private Sale

Whitelist will be consist of 10 wallet addresses.
Restrictions:

* Max allowed min per wallet: 20 ``uint256 public constant MAX_MINT_PRIVATE``

#### Pre Sale

Whitelist will be consist of 100 wallet addresses.
Restrictions:

* Max allowed mint per wallet: 10 ``uint256 public constant MAX_MINT_PUBLIC``

#### Public Sale

There will be no whitelist. Public sale will be held on 22th of May.
Restrictions:

* Max allowed mint per wallet: 10 ``uint256 public constant MAX_MINT_PUBLIC``

### Contracts

1. RaffleGraphy.sol - created by Hagia Dev Team
2. ERC721A.sol - created by Chiru Labs (Azuki) and modified by Hagia Dev Team

### The Process

#### Adding Creators (Artists)

We will add the wallet addresses of artists in the right order with metadata files so we can match the creator with the right token.

``
[
  "WalletOfArtist1",
  "WalletOfArtist2",
  "WalletOfArtist3",
  .
  .
  "WalletOfArtist48",
  "WalletOfArtist49",
  "WalletOfArtist50",
]
``

#### Metadata Structure

We don't want a buyer to keep mint the same artwork over and over again. We want the buyer to mint different artworks from different artists. 
While trying to achive that we also don't want to use nested for loops since it can break things when so many transactions are send and also causes high gas fees.
So the table below shows how we are going to sort the metadata which we think that will save us from nested loops.

| Metadata | Artwok            | Creator  | 
|----------|-------------------|----------|
| 0.json   | ArtworkOfArtist1  | Artist1  |
| 1.json   | ArtworkOfArtist2  | Artist2  |
| 2.json   | ArtworkOfArtist3  | Artist3  |
| ...      | ...               | ...      |
| 47.json  | ArtworkOfArtist48 | Artist48 |
| 48.json  | ArtworkOfArtist49 | Artist49 |
| 49.json  | ArtworkOfArtist50 | Artist50 |
| 50.json  | ArtworkOfArtist1  | Artist1  |
| 51.json  | ArtworkOfArtist2  | Artist2  |
| 52.json  | ArtworkOfArtist3  | Artist3  |
| ...      | ...               | ...      |
| ...      | ...               | ...      |
| 97.json  | ArtworkOfArtist48 | Artist48 |
| 98.json  | ArtworkOfArtist49 | Artist49 |
| 99.json  | ArtworkOfArtist50 | Artist50 |
| 100.json | ArtworkOfArtist1  | Artist1  |
| 101.json | ArtworkOfArtist2  | Artist2  |
| 102.json | ArtworkOfArtist3  | Artist3  |
| ...      | ...               | ...      |
| ...      | ...               | ...      |
| ...      | ...               | ...      |
| 997.json | ArtworkOfArtist48 | Artist48 |
| 998.json | ArtworkOfArtist49 | Artist49 |
| 999.json | ArtworkOfArtist50 | Artist50 |

#### Minting

Wen minting we will first airdrop the token from null address to the artist who created it by matching the creator index with the tokenId (tokenId % 50 will give us the right index).
Then we will transfer the token to the buyer. With that we want to show the artist of that token to be shown as the creator in marketplaces like OS.

For that:

1. We modified minting function of ERC721A.sol contract to be able to match the token with the artist (creator).
2. We will add ``created_by`` tag to metadata json files with the name of the artist.
3. We will get in touch with OS to honor that information and make it to show creator info the way we want except showing the contract deployer as creator. (Like they did on muratpak's ASH TWO: Metamorphosis drop)


