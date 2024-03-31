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
        (string memory uid, address owner) = book.certificates(0);
        assertEq(uid, "CF-001");
        assertEq(owner, address(this));
    }

    function test_transferOwnership() public {
        address newOwner = address(0x1);
        book.mintCertificate("CF-001", address(this));
        book.transferOwnership(0, newOwner);
        (string memory uid, address owner) = book.certificates(0);
        assertEq(uid, "CF-001");
        assertEq(owner, newOwner);
    }

    function test_burnCertificate() public {
        book.mintCertificate("CF-001", address(this));
        book.burnCertificate(0);

        (string memory uid, address owner) = book.certificates(0);
        assertEq(uid, "");
        assertEq(owner, address(0));
    }
}