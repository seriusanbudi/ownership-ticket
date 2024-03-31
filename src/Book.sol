// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

contract Book {
    struct Certificate {
        string uid;
        address owner;
    }

    Certificate[] public certificates;
    mapping(string => bool) private existingUIDs;

    address private owner;
    bool public paused; // State variable to track the pause state

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

    function pause() public onlyContractOwner {
        paused = true;
        emit Paused();
    }

    function unpause() public onlyContractOwner {
        paused = false;
        emit Unpaused();
    }

    function length() public view returns (uint) {
        return certificates.length;
    }

    modifier onlyCertificateOwner(uint index) {
        require(
            msg.sender == certificates[index].owner,
            "Not the certificate owner"
        );
        require(!paused, "Contract is paused");
        _;
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

    function transferOwnership(
        uint index,
        address newOwner
    ) public onlyCertificateOwner(index) whenNotPaused {
        address oldOwner = certificates[index].owner;
        certificates[index].owner = newOwner;
        emit OwnershipTransferred(certificates[index].uid, oldOwner, newOwner);
    }

    function burnCertificate(
        uint index
    ) public onlyCertificateOwner(index) whenNotPaused {
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
}
