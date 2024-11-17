local moonwave = require("../moonwave-luau")
local strbuf = require("../strbuf")

local function filterCTypeInfo(
	fields: { moonwave.moonwave_high_field }
): ({ moonwave.moonwave_high_field }, { moonwave.moonwave_high_field })
	local filtered = {}
	local types = {}

	for _, field in fields do
		if field.type == "CTypeInfo" then
			table.insert(types, field)
			continue
		end
		table.insert(filtered, field)
	end

	return filtered, types
end

local function pushTypes(buf: strbuf.strbuf, types: { moonwave.moonwave_high_field })
	for _, ctype in types do
		buf:push(`- {buf.inline(buf.strip(ctype.name))}\n\n{buf.indent(buf.strip(ctype.comments), "  ")}\n\n`)
	end
end

return function(doc: moonwave.moonwave_high): string
	local buf = strbuf.new()
	-- buf:pushClass(doc.FFI):pushClass(doc.C)

	local ffiProps, ffiTypes = filterCTypeInfo(doc.FFI.props :: any)
	buf:pushTitle("FFI")
		:pushComments(doc.FFI.comments)
		:pushFunctions(doc.FFI.functions)
		:pushProps(ffiProps)
		:pushTitle("Types", 2)
		:pushComments("Fixed size `CTypeInfo`s")
	pushTypes(buf, ffiTypes)

	local _cProps, cTypes = filterCTypeInfo(doc.C.props :: any)
	buf:pushTitle("C")
		:pushComments(doc.C.comments)
		:pushFunctions(doc.C.functions)
		:pushTitle("Types", 2)
		:pushComments("Compile time size `CTypeInfo`s")
	pushTypes(buf, cTypes)

	buf:pushTitle("Data")
		:pushComments("Classes for handling memory")
		:pushClass(doc.BoxData, 2)
		:pushClass(doc.RefData, 2)
		:pushClass(doc.LibData, 2)
		:pushClass(doc.CallableData, 2)
		:pushClass(doc.ClosureData, 2)

	buf:pushTitle("Info")
		:pushComments("Type informations, which provide type conversion, casting, stringify, etc...")
		:pushClass(doc.CTypeInfo, 2)
		:pushClass(doc.CPtrInfo, 2)
		:pushClass(doc.CArrInfo, 2)
		:pushClass(doc.CFnInfo, 2)
		:pushClass(doc.CStructInfo, 2)
		:pushClass(doc.CVoidInfo, 2)

	return buf:finalize()
end
