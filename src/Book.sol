// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Book {
    struct Certificate {
        string uid;
        address owner;
    }

    Certificate[] public certificates;
    address private owner;

    event CertificateMinted(string uid, address owner);
    event OwnershipTransferred(string uid, address from, address to);
    event CertificateBurned(string uid);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyContractOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier onlyCertificateOwner(uint index) {
        require(
            msg.sender == certificates[index].owner,
            "Not the certificate owner"
        );
        _;
    }

    function mintCertificate(
        string memory _uid,
        address _owner
    ) public onlyContractOwner {
        certificates.push(Certificate(_uid, _owner));
        emit CertificateMinted(_uid, _owner);
    }

    function transferOwnership(
        uint index,
        address newOwner
    ) public onlyCertificateOwner(index) {
        address oldOwner = certificates[index].owner;
        certificates[index].owner = newOwner;
        emit OwnershipTransferred(certificates[index].uid, oldOwner, newOwner);
    }

    function burnCertificate(uint index) public onlyCertificateOwner(index) {
        emit CertificateBurned(certificates[index].uid);
        delete certificates[index];
    }
}
