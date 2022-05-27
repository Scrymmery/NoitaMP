#!/usr/bin/env lua
dofile("mods/noita-mp/files/scripts/init/init_.lua")

local lu = require("luaunit")
local util = require("util")

TestUtil = {}

function TestUtil:setUp()
    print("\nsetUp")
end

function TestUtil:tearDown()
    print("tearDown\n")
end

function TestUtil:testSleep()
    lu.assertErrorMsgContains("Unable to wait if parameter 'seconds' isn't a number:", util.Sleep, "seconds")

    local seconds_to_wait = 4
    local timestamp_before = os.clock()
    util.Sleep(seconds_to_wait)
    local timestamp_after = os.clock()
    local diff = timestamp_before + seconds_to_wait
    logger:debug("timestamp_before=%s, timestamp_after=%s, diff=%s", timestamp_before, timestamp_after, diff)
    lu.almostEquals(diff, timestamp_after, 0.1)
end

function TestUtil:testIsEmpty()
    local tbl = {}
    table.insert(tbl, "1234")
    lu.assertIsFalse(util.IsEmpty(tbl))

    lu.assertIsTrue(util.IsEmpty(nil))
    lu.assertIsTrue(util.IsEmpty(""))
    lu.assertIsTrue(util.IsEmpty({}))
end

os.exit(lu.LuaUnit.run())
