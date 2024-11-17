local moonwave = require("../moonwave-luau")
local strbuf = require("../strbuf")

return function(doc: moonwave.moonwave_high): string
    local buf = strbuf.new()
    buf
        :pushTitle("FFI")
        :pushComments(doc.FFI.comments)
        :pushProps(doc.FFI.props)
        :pushFunctions(doc.FFI.functions)

        :pushTitle("BoxData")
        :pushComments(doc.BoxData.comments)
        :pushFields(doc.BoxData.fields)
        :pushMethods(doc.BoxData.methods)

        :pushTitle("RefData")
        :pushComments(doc.RefData.comments)
        :pushMethods(doc.RefData.methods)

    return buf:finalize()
end
