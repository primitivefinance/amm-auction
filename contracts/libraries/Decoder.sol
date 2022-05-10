// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

/// @title    Decoder Library
/// @dev      Solidity library to manipulate and covert bytes
/// @author   Primitive
library Decoder {
    /// @dev            Separates the nibbles of a byte into two bytes
    /// @param data     Byte to separate
    /// @return upper   Upper nibble
    /// @return lower   Lower nibble
    function separate(bytes1 data) internal pure returns (bytes1 upper, bytes1 lower) {
        upper = data >> 4;
        lower = data & 0x0f;
    }

    /// @dev           Converts an array of bytes into a byte32
    /// @param raw     Array of bytes to convert
    /// @return data   Converted data
    function toBytes32(bytes memory raw) internal pure returns (bytes32 data) {
        assembly {
            data := mload(add(raw, 32))
            let shift := mul(sub(32, mload(raw)), 8)
            data := shr(shift, data)
        }
    }

    /// @dev             Converts an array of bytes into an uint256, the array must adhere
    ///                  to the the following format:
    ///                  - First byte: Amount of trailing zeros
    ///                  - Rest of the array: A hexadecimal number
    /// @param raw       Array of bytes to convert
    /// @return amount   Converted amount
    function toAmount(bytes calldata raw) internal pure returns (uint256 amount) {
        uint8 power = uint8(raw[0]);
        amount = uint256(toBytes32(raw[1:raw.length]));
        amount = amount * 10**power;
    }

    function toAmount(bytes calldata raw, uint8 power) internal pure returns (uint256 amount) {
        amount = uint256(toBytes32(raw));
        amount = amount * 10**power;
    }

    /// @param raw Fully encoded calldata.
    /// @return amount Decoded amount data using second byte's lower order bit as amount of zeroes to append.
    function encodedBytesToAmount(bytes calldata raw) internal pure returns (uint256 amount) {
        uint8 info = uint8(bytes1(raw[1]) >> 4);
        // If the higher order bit is 1, it means we have an amount of decimals > 16, so use the full bit.
        // [0xyz], y = ? or count, z = count, if y == 1, count = 0xyz, else count = 0x0z
        uint8 power = uint8(info == 1 ? bytes1(raw[1]) : bytes1(raw[1]) & 0x0f);
        bytes memory value = raw[2:raw.length - 1];
        amount = uint256(bytes32(value) >> ((32 - uint8(value.length)) * 8)) * 10**power;
    }
}
