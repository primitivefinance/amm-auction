// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

enum SearchDirection {
    Left,
    Right
}

function flip(uint256 bitmap, uint8 index) pure returns (uint256 flipped) {
    assembly {
        flipped := xor(bitmap, shl(index, 1))
    }
}

function hasLiquidity(uint256 bitmap, uint8 index) pure returns (bool has) {
    assembly {
        has := and(bitmap, shl(index, 1))
    }
}

function getSlotPositionInBitmap(int24 slotIndex) pure returns (int16 chunk, uint8 bit) {
    chunk = int16(slotIndex / 256);
    bit = uint8(uint24(slotIndex % 256));
}

function findNextSlotWithinChunk(
    uint256 chunk,
    uint8 bit,
    SearchDirection searchDirection
) pure returns (bool hasNextSlot, uint8 nextSlotBit) {
    if (chunk != 0) {
        hasNextSlot = true;

        if (searchDirection == SearchDirection.Left) {
            nextSlotBit = leastSignificantBit(chunk >> (bit + 1)) + bit + 1;
        } else {
            nextSlotBit = mostSignificantBit(chunk & ((1 << bit) - 1));
        }
    } else {
        nextSlotBit = searchDirection == SearchDirection.Left ? 255 : 0;
    }
}

/// @notice Returns the index of the most significant bit of the number,
///     where the least significant bit is at index 0 and the most significant bit is at index 255
/// @dev The function satisfies the property:
///     x >= 2**mostSignificantBit(x) and x < 2**(mostSignificantBit(x)+1)
/// @param x the value for which to compute the most significant bit, must be greater than 0
/// @return r the index of the most significant bit
function mostSignificantBit(uint256 x) pure returns (uint8 r) {
    require(x > 0);

    if (x >= 0x100000000000000000000000000000000) {
        x >>= 128;
        r += 128;
    }
    if (x >= 0x10000000000000000) {
        x >>= 64;
        r += 64;
    }
    if (x >= 0x100000000) {
        x >>= 32;
        r += 32;
    }
    if (x >= 0x10000) {
        x >>= 16;
        r += 16;
    }
    if (x >= 0x100) {
        x >>= 8;
        r += 8;
    }
    if (x >= 0x10) {
        x >>= 4;
        r += 4;
    }
    if (x >= 0x4) {
        x >>= 2;
        r += 2;
    }
    if (x >= 0x2) r += 1;
}

/// @notice Returns the index of the least significant bit of the number,
///     where the least significant bit is at index 0 and the most significant bit is at index 255
/// @dev The function satisfies the property:
///     (x & 2**leastSignificantBit(x)) != 0 and (x & (2**(leastSignificantBit(x)) - 1)) == 0)
/// @param x the value for which to compute the least significant bit, must be greater than 0
/// @return r the index of the least significant bit
function leastSignificantBit(uint256 x) pure returns (uint8 r) {
    require(x > 0);

    r = 255;
    if (x & type(uint128).max > 0) {
        r -= 128;
    } else {
        x >>= 128;
    }
    if (x & type(uint64).max > 0) {
        r -= 64;
    } else {
        x >>= 64;
    }
    if (x & type(uint32).max > 0) {
        r -= 32;
    } else {
        x >>= 32;
    }
    if (x & type(uint16).max > 0) {
        r -= 16;
    } else {
        x >>= 16;
    }
    if (x & type(uint8).max > 0) {
        r -= 8;
    } else {
        x >>= 8;
    }
    if (x & 0xf > 0) {
        r -= 4;
    } else {
        x >>= 4;
    }
    if (x & 0x3 > 0) {
        r -= 2;
    } else {
        x >>= 2;
    }
    if (x & 0x1 > 0) r -= 1;
}
