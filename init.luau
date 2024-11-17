local moonwave = require("./moonwave-luau")
local fs = require("@lune/fs")
local process = require("@lune/process")

local lunePath = process.args[1] :: string?
if not lunePath then
    print("Please add 'lune_directory' argument")
    process.exit(1)
end
lunePath = string.gsub(lunePath :: string, "/+$", "")

fs.writeDir("./target")
for _, file in fs.readDir("./generator") do
    local gen = require(`./generator/{file}`)
    local parsed = moonwave.parseString(fs.readFile(`{lunePath}/types/{file}`))
    local doc = gen(parsed)
    fs.writeFile(
        `./target/{string.gsub(file, "%.luau$", ".md")}`,
        doc
    )
end
