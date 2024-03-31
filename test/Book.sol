// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Book.sol"; // Adjust the path according to your project structure

contract BookTest is Test {
    Book book;

    function setUp() public {
        book = new Book();
    }

    function test_mintCertificate() public {
        book.mintCertificate("CF-001", address(this));
        (string memory uid, address owner) = book.getCertificate(0);
        assertEq(uid, "CF-001", "Incorrect UID after minting");
        assertEq(owner, address(this), "Incorrect owner after minting");
    }

    function test_transferOwnership() public {
        address newOwner = address(0x1);
        book.mintCertificate("CF-001", address(this));
        book.transferOwnership(0, newOwner);
        (string memory uid, address owner) = book.getCertificate(0);
        assertEq(uid, "CF-001", "Incorrect UID after transfer");
        assertEq(owner, newOwner, "Incorrect owner after transfer");
    }

    function test_burnCertificate() public {
        book.mintCertificate("CF-001", address(this));
        assertEq(book.length(), 1, "Incorrect length after minting");
        book.burnCertificate(0);
        assertEq(book.length(), 0, "Incorrect length after burning");
    }

    function test_getCertificateIndexByUID() public {
        book.mintCertificate("CF-001", address(this));
        book.mintCertificate("CF-002", address(this));
        book.mintCertificate("CF-003", address(this));

        assertEq(book.length(), 3, "Incorrect length after minting");

        uint index = book.getCertificateIndexByUID("CF-002");

        assertEq(index, 1, "Incorrect index for CF-002");
    }

    function test_getCertificate() public {
        book.mintCertificate("CF-001", address(this));
        book.mintCertificate("CF-002", address(this));
        book.mintCertificate("CF-003", address(this));

        assertEq(book.length(), 3, "Incorrect length after minting");

        (string memory uid, address owner) = book.getCertificate(1);

        assertEq(uid, "CF-002", "Incorrect UID for index 1");
        assertEq(owner, address(this), "Incorrect owner for index 1");
    }

    function test_setOwner() public {
        address newOwner = address(0x2);
        book.setOwner(newOwner);
        assertEq(book.owner(), newOwner, "Owner not set correctly");
    }
}
