// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts@4.7.3/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.7.3/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts@4.7.3/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.7.3/security/Pausable.sol";
import "@openzeppelin/contracts@4.7.3/access/AccessControl.sol";
import "@openzeppelin/contracts@4.7.3/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts@4.7.3/utils/Counters.sol";

contract YuliOriginGenOne is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    Pausable,
    AccessControl,
    ERC721Burnable
{
    /* ========== LIBs ========== */
    using Counters for Counters.Counter;
    using Strings for uint256;

    /* ========== STATE VARIABLES ========== */
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    Counters.Counter private _tokenIdCounter;

    struct MintInfo {
        address caller;
        address holder;
        uint256 ts;
        uint256 platform;
        uint256 boxType;
        uint256 roleType;
    }

    mapping(uint256 => MintInfo) private tokenMintInfo;
    mapping(uint256 => bool) public boxTypeMap;
    mapping(uint256 => bool) public roleTypeMap;
    mapping(uint256 => bool) public platformMap;

    string public baseURI = "https://yf.yuliverse.com/prod/md/json/";
    string public baseExtension = ".json";

    constructor() ERC721("YuliOriginGenOne", "YOG1") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);

        boxTypeMap[3] = true; 
        boxTypeMap[4] = true; 
        boxTypeMap[5] = true; 
        boxTypeMap[6] = true; 
        boxTypeMap[7] = true; 

        roleTypeMap[2] = true; 
        roleTypeMap[3] = true; 
        roleTypeMap[4] = true; 
        roleTypeMap[5] = true; 
        roleTypeMap[6] = true; 

        platformMap[1] = true; 
        platformMap[99] = true; 

        _tokenIdCounter._value = 100000000;
    }

    fallback() external {}

    /* ========== MODIFIER FUNCTIONS ========== */

    /* ========== READ FUNCTIONS ========== */
    function getTokenIdMintInfo(uint256 tokenId)
        public
        view
        returns (MintInfo memory)
    {
        return tokenMintInfo[tokenId];
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function walletOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        _requireMinted(tokenId);
        string memory currentBaseURI = _baseURI();

        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    /* ========== WRITE FUNCTIONS ========== */
    function setBaseURI(string memory _newBaseURI)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        baseExtension = _newBaseExtension;
    }


    function setBoxType(uint256 _new, bool _val)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        boxTypeMap[_new] = _val;
    }

    function setPlatform(uint256 _new, bool _val)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        platformMap[_new] = _val;
    }

    function setRoleType(uint256 _new, bool _val)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        roleTypeMap[_new] = _val;
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function safeMint(
        address to,
        uint256 boxType,
        uint256 platform,
        uint256 roleType,
        uint256 newId
    ) public onlyRole(MINTER_ROLE) {
        require(boxTypeMap[boxType], "boxType invalid");
        require(platformMap[platform], "platform invalid");
        require(roleTypeMap[roleType], "roleType invalid");

        uint256 tokenId = _tokenIdCounter.current();
        if (newId == 0) {
            _tokenIdCounter.increment();
        } else {
            require(newId >= 1000000000, "newId invalid");
            tokenId = newId;
        }

        _safeMint(to, tokenId);

        tokenMintInfo[tokenId] = MintInfo({
            caller: msg.sender,
            holder: to,
            ts: block.timestamp,
            platform: platform,
            boxType: boxType,
            roleType: roleType
        });
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
