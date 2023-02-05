// Contract based on https://docs.openzeppelin.com/contracts/3.x/erc721
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


import "erc721a/contracts/ERC721A.sol";

contract MTM_Contract is ERC721A, Ownable {
    using Strings for uint256;

    bool public _isSaleActive = true;
    bool public _isPreSaleActive=true;
    bool public _revealed = false;

    // Constants
    uint256 public constant MAX_SUPPLY = 2000;
    uint256 public mintPrice = 0.01 ether;
    //持有上限
    uint256 public maxBalance = 350;
    uint256 public maxMint = 30;

    string baseURI="ipfs://";
    string public notRevealedUri="ipfs://";
    string public baseExtension = ".json";

    //Fomo
    bool public _isFomo=false;

    //WhiteList
    mapping(address=>bool) WhiteList;

    mapping(uint256 => string) private _tokenURIs;

        constructor() ERC721A("MTM_Contract", "MTM"){}
    
    //721A mints
    function mint721A(uint256 quantity)  public  payable {
    // _safeMint's second argument now takes in a quantity, not a tokenId.
    _safeMint(msg.sender, quantity);
  }


    function mintNFT(uint256 tokenQuantity) public payable {
        require(totalSupply() + tokenQuantity <= MAX_SUPPLY,"Sale would exceed max supply");
        require(_isSaleActive, "Sale must be active to mint NFT");
        require(
        //一人可持有的上限
            balanceOf(msg.sender) + tokenQuantity <= maxBalance,
            "Sale would exceed max balance"
        );
        // require(
        //     tokenQuantity * mintPrice < msg.value,
        //     "Not enough ether sent"
        // );
        require(tokenQuantity <= maxMint, "Can only mint 10 tokens at a time");

        // _mintNFT(tokenQuantity);
        mint721A(tokenQuantity);
    }

    function mintNFTToOther(uint256 tokenQuantity,address to) onlyOwner public payable {
        require(totalSupply() + tokenQuantity <= MAX_SUPPLY,"Sale would exceed max supply");
        require(_isSaleActive, "Sale must be active to mint NFT");
        require(
            balanceOf(msg.sender) + tokenQuantity <= maxBalance,
            "Sale would exceed max balance"
        );
        require(tokenQuantity <= maxMint, "Can only mint 20 tokens at a time");

        _mintNFTToOther(tokenQuantity,to);
    }



    function _mintNFTToOther(uint256 tokenQuantity,address to) internal {
        _safeMint(to, tokenQuantity);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (_revealed == false) {
            return notRevealedUri;
        }

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return
            string(abi.encodePacked(base, tokenId.toString(), baseExtension));
    }


    function addWhiteList() public returns (bool success) {
        require(WhiteList[msg.sender]!=true,"Error:Already have WhiteList");
        WhiteList[msg.sender]=true;
        return true;
    }



    function preSale(uint256 tokenQuantity) external payable{
        require(_isPreSaleActive==true,"Error:Not Begin");
        require(WhiteList[msg.sender]==true,"Error:Not in WhiteList");
        mintNFT(tokenQuantity);

    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    //only owner
    function flipSaleActive() public onlyOwner {
        _isSaleActive = !_isSaleActive;
    }

    function flipReveal() public onlyOwner {
        _revealed = !_revealed;
    }

    function setMintPrice(uint256 _mintPrice) public onlyOwner {
        mintPrice = _mintPrice;
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    function setMaxBalance(uint256 _maxBalance) public onlyOwner {
        maxBalance = _maxBalance;
    }

    function setMaxMint(uint256 _maxMint) public onlyOwner {
        maxMint = _maxMint;
    }
      
    function setisFomo() public onlyOwner {
        _isFomo = !_isFomo;
    }

    function setisPreSaleActive() public onlyOwner {
    _isPreSaleActive = !_isPreSaleActive;
    }

   

    function withdraw(address to) public onlyOwner {
        uint256 balance = address(this).balance;
        payable(to).transfer(balance);
    }
}