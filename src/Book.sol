// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

contract Book {
    struct Certificate {
        string uid;
        address owner;
    }

    Certificate[] private certificates;
    mapping(string => bool) private existingUIDs;

    address public owner;
    bool public paused;

    event CertificateMinted(string uid, address owner);
    event OwnershipTransferred(string uid, address from, address to);
    event CertificateBurned(string uid);
    event Paused();
    event Unpaused();

    constructor() {
        owner = msg.sender;
        paused = false;
    }

    modifier onlyContractOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    function length() public view returns (uint) {
        return certificates.length;
    }

    function isPaused() public view returns (bool) {
        return paused;
    }

    function mintCertificate(
        string memory _uid,
        address _owner
    ) public onlyContractOwner whenNotPaused {
        require(!existingUIDs[_uid], "UID must be unique");

        certificates.push(Certificate(_uid, _owner));
        existingUIDs[_uid] = true;
        emit CertificateMinted(_uid, _owner);
    }

    function getCertificateIndexByUID(
        string memory _uid
    ) public view returns (uint) {
        require(existingUIDs[_uid], "Certificate with this UID does not exist");

        bytes32 uidHash = keccak256(abi.encodePacked(_uid));

        for (uint i = 0; i < certificates.length; i++) {
            bytes32 certUidHash = keccak256(
                abi.encodePacked(certificates[i].uid)
            );
            if (certUidHash == uidHash) {
                return i;
            }
        }

        revert("Certificate not found");
    }

    function getCertificate(
        uint index
    ) public view returns (string memory, address) {
        require(index < certificates.length, "Invalid index");

        Certificate memory cert = certificates[index];
        return (cert.uid, cert.owner);
    }

    function transferOwnership(
        uint index,
        address newOwner
    ) public onlyContractOwner whenNotPaused {
        address oldOwner = certificates[index].owner;
        certificates[index].owner = newOwner;
        emit OwnershipTransferred(certificates[index].uid, oldOwner, newOwner);
    }

    function burnCertificate(
        uint index
    ) public onlyContractOwner whenNotPaused {
        string memory uid = certificates[index].uid;
        emit CertificateBurned(uid);

        existingUIDs[uid] = false;

        uint lastIndex = certificates.length - 1;
        if (index != lastIndex) {
            certificates[index] = certificates[lastIndex];
            existingUIDs[certificates[index].uid] = true;
        }
        certificates.pop();
    }

    function pause() public onlyContractOwner {
        paused = true;
        emit Paused();
    }

    function unpause() public onlyContractOwner {
        paused = false;
        emit Unpaused();
    }

    function setOwner(address _newOwner) public onlyContractOwner {
        owner = _newOwner;
    }
}
