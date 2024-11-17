local moonwave = require("../moonwave-luau")

return function(doc: moonwave.moonwave_high): string
	local buf = moonwave.docgen.new()

    buf:pushClass(doc.DateTime)

	return buf:finalize()
end
