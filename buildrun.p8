pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
#include px9_comp.lua
#include px9_decomp.lua

SpriteSheet1Addr = 0x0000
SpriteSheetMapSharedAddr = 0X1000
Map1Addr = 0x2000

function _init()
    -- Wipe the cartridge
    for addr=0x0000, 0x3100 do
        poke(addr, 0)
    end
    cstore(0x0000, 0x0000, 0x3000)

    local offset = 0
    offset += packSpriteSheet("introanimation.p8", 128, 128, "picomonred.p8", Map1Addr)

    offset += packSpriteSheet("introcarousel.p8", 128, 88, "picomonred.p8", Map1Addr + offset)

    do return end

    -- Load the spritesheet
    local length = 0x2000
    reload(0x0000, 0x0000, length, "introanimation.p8")

    -- Read 128x128 pixels (2 bits each) from the sprite sheet into the map region
    clen = px9_comp(0, 0, 128, 128, 0x2000, sget)

    -- Save the compressed data to the map region
    cstore(0x2000, 0x2000, clen)

    -- Wipe the sprite sheet
    for addr=0x0000, 0x1fff do
        poke(addr, 0)
    end
    cstore(0x0000, 0x0000, 0x2)

    -- Decompress back into the spritesheet and save it
    px9_decomp(0, 0, 0x2000, sget, sset)
    cstore(0x000, 0x000, 0x2000)

    -- -- Wipe the map region
    -- for addr=0x2000, 0x2fff do
    --     poke(addr, 0)
    -- end
    -- cstore(0x2000, 0x2000, 0x1000)
end

function packSpriteSheet(fromCart, width, height, intoCart, memDestination)
    local length = 0x2000
    reload(0x0000, memStart, length, fromCart)

    -- Use the map space as our scribble sheet
    local clen = px9_comp(0, 0, width, height, Map1Addr, sget)

    printh("Compressed " .. fromCart .. " into " .. intoCart .. " with length " .. clen)

    -- Write to the destination file
    cstore(memDestination, Map1Addr, clen, intoCart)

    return clen

    -- Write to our own map and spritesheet for debugging
    -- cstore(Map1Addr, Map1Addr, clen)
    -- px9_decomp(0, 0, 0x2000, sget, sset)
    -- cstore(0x000, 0x000, 0x2000)
end

