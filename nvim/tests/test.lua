-- lua_ls diagnostics (no config needed)
-- Expected: warning on `unused`, warning on `x` arithmetic with string

local function add(a, b)
    return a + b
end

local unused = "never used"  -- lua_ls: unused variable

local result = add(1, 2)
print(result)
