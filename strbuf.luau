local moonwave = require("./moonwave-luau")

local strbuf = {}
strbuf.__index = strbuf

function strbuf.new()
	return setmetatable({ "<!-- markdownlint-disable -->\n\n" }, strbuf)
end

function strbuf:push(str: string): strbuf
	table.insert(self, str)
	return self
end

function strbuf:finalize(): string
	return string.gsub(table.concat(self), "\n+$", "") .. "\n"
end

function strbuf:pushTitle(str: string, level: number?): strbuf
	self:push(`{string.rep("#", level or 1)} {str}\n\n`)
	return self
end

function strbuf:pushHr(): strbuf
	self:push("\n---\n\n")
	return self
end

function strbuf.inline(str: string): string
	return `\`{string.gsub(str, "`", "\\`")}\``
end

function strbuf.strip(str: string): string
	return string.gsub(string.gsub(str, "^\n+", ""), "\n+$", "")
end

-- Push properties
function strbuf:pushProps(props: { moonwave.moonwave_high_field }, _titleIndent: number?, noTitle: boolean?): strbuf
	local titleIndent = _titleIndent or 2
	if not noTitle then
		self:pushTitle("Properties", titleIndent)
	end
	for index, item in props do
		-- name
		self:pushTitle(strbuf.strip(item.name), titleIndent + 1)

		-- readonly tag
		if item.readonly then
			self:push("**@readonly** ")
		end

		-- inline type
		if item.type then
			self:push(`{strbuf.inline(strbuf.strip(item.type))}\n\n`)
		end

		-- comments
		if item.comments ~= "" then
			self:push(`{strbuf.strip(item.comments)}\n`)
		end

		-- hr
		if props[index+1] then
			self:pushHr()
		end
	end
	self:push("\n")
	return self
end

function strbuf:pushFields(fields: { moonwave.moonwave_high_field }, titleIndent: number?, noTitle: boolean?): strbuf
	if not noTitle then
		self:pushTitle("Fields", titleIndent or 2)
	end
	self:pushProps(fields, titleIndent, true)
	return self
end

function strbuf:pushFunctions(functions: { moonwave.moonwave_high_function }, _titleIndent: number?, noTitle: boolean?): strbuf
	local titleIndent = _titleIndent or 2
	if not noTitle then
		self:pushTitle("Functions", titleIndent)
	end
	for index, item in functions do
		-- name
		self:pushTitle(strbuf.strip(item.name), titleIndent + 1)

		-- comments
		if item.comments ~= "" then
			self:push(`{strbuf.strip(item.comments)}\n\n`)
		end

		-- params
		if item.params then
			self:pushTitle("Parameters", titleIndent + 2)
			for _,param in item.params do
				self:push(`- {strbuf.inline(strbuf.strip(param.name))} {strbuf.strip(param.description)}\n`)
			end
			if item.returns then self:push("\n") end
		end

		-- returns
		if item.returns then
			self:pushTitle("Returns", titleIndent + 2)
			for _,return_ in item.returns do
				self:push(`- {strbuf.strip(return_.description)}\n`)
			end
		end

		-- hr
		if functions[index+1] then
			self:pushHr()
		end
	end
	self:push("\n")
	return self
end

function strbuf:pushMethods(methods: { moonwave.moonwave_high_function }, titleIndent: number?, noTitle: boolean?): strbuf
	if not noTitle then
		self:pushTitle("Methods", titleIndent or 2)
	end
	self:pushFunctions(methods, titleIndent, true)
	return self
end

function strbuf:pushComments(comments: string): strbuf
	self:push(`{strbuf.strip(comments)}\n\n`)
	return self
end

export type strbuf = {
	push: (self: strbuf, str: string) -> strbuf,
	finalize: (self: strbuf) -> string,
	pushTitle: (self: strbuf, str: string, level: number?) -> strbuf,
	inline: (str: string) -> string,
	strip: (str: string) -> string,
	pushHr: (self: strbuf) -> strbuf,
	pushProps: (self: strbuf, props: { moonwave.moonwave_high_field }, titleIndent: number?, noTitle: boolean?) -> strbuf,
	pushFields: (self: strbuf, fields: { moonwave.moonwave_high_field }, titleIndent: number?, noTitle: boolean?) -> strbuf,
	pushFunctions: (self: strbuf, functions: { moonwave.moonwave_high_function }, titleIndent: number?, noTitle: boolean?) -> strbuf,
	pushMethods: (self: strbuf, methods: { moonwave.moonwave_high_function }, titleIndent: number?, noTitle: boolean?) -> strbuf,
	pushComments: (self: strbuf, comments: string) -> strbuf,
}

return strbuf :: { new: () -> strbuf }
