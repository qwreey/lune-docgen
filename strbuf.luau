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

function strbuf.indent(str: string, indent: string): string
	return `{indent}{string.gsub(str, "\n", `\n{indent}`)}`
end

function strbuf:pushAttrs(
	item: moonwave.moonwave_high_field | moonwave.moonwave_high_function | moonwave.moonwave_high_class
): strbuf
	local pushed = false

	-- unreleased tag
	if item.unreleased then
		self:push("**@unreleased**\n")
		pushed = true
	end

	-- readonly tag
	if (item :: moonwave.moonwave_high_field).readonly then
		self:push("**@readonly**\n")
		pushed = true
	end

	-- since tag
	local since = item.since
	if since then
		self:push(`**@since** {strbuf.strip(since)}\n`)
		pushed = true
	end

	-- deprecated
	local deprecated = item.deprecated
	if deprecated then
		self:push(
			`**@deprecated** {strbuf.inline(strbuf.strip(deprecated.version))} {strbuf.strip(deprecated.description)}\n`
		)
		pushed = true
	end

	if pushed then
		self:push("\n")
	end

	return self
end

-- Push properties
function strbuf:pushProps(props: { moonwave.moonwave_high_field }, _titleIndent: number?, noTitle: boolean?): strbuf
	local titleIndent = _titleIndent or 2
	if not noTitle then
		self:pushTitle("Properties", titleIndent)
	end
	for index, item in props do
		if item.ignore then
			continue
		end

		-- name
		self:pushTitle(strbuf.strip(item.name), titleIndent + 1)

		-- attrs
		self:pushAttrs(item)

		-- inline type
		if item.type then
			self:push(`{strbuf.inline(strbuf.strip(item.type))}\n\n`)
		end

		-- comments
		if item.comments ~= "" then
			self:push(`{strbuf.strip(item.comments)}\n`)
		end

		-- hr
		if props[index + 1] then
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

function strbuf:pushFunctions(
	functions: { moonwave.moonwave_high_function },
	_titleIndent: number?,
	noTitle: boolean?
): strbuf
	local titleIndent = _titleIndent or 2
	if not noTitle then
		self:pushTitle("Functions", titleIndent)
	end
	for index, item in functions do
		if item.ignore then
			continue
		end

		-- name
		self:pushTitle(strbuf.strip(item.name), titleIndent + 1)

		-- attrs
		self:pushAttrs(item)

		-- comments
		if item.comments ~= "" then
			self:push(`{strbuf.strip(item.comments)}\n\n`)
		end

		-- params
		if item.params then
			self:pushTitle("Parameters", titleIndent + 2)
			for _, param in item.params do
				self:push(`- {strbuf.inline(strbuf.strip(param.name))} {strbuf.strip(param.description)}\n`)
			end
			if item.returns then
				self:push("\n")
			end
		end

		-- returns
		if item.returns then
			self:pushTitle("Returns", titleIndent + 2)
			for _, return_ in item.returns do
				self:push(`- {strbuf.strip(return_.description)}\n`)
			end
		end

		-- hr
		if functions[index + 1] then
			self:pushHr()
		end
	end
	self:push("\n")
	return self
end

function strbuf:pushMethods(
	methods: { moonwave.moonwave_high_function },
	titleIndent: number?,
	noTitle: boolean?
): strbuf
	if not noTitle then
		self:pushTitle("Methods", titleIndent or 2)
	end
	self:pushFunctions(methods, titleIndent, true)
	return self
end

function strbuf.filterConstructor(
	methods: { moonwave.moonwave_high_function }
): ({ moonwave.moonwave_high_function }, { moonwave.moonwave_high_function }?)
	local filtered = {}
	local constructors = {}

	for _, method in methods do
		if method.tags and table.find(method.tags, "Constructor") then
			table.insert(constructors, method)
			continue
		end
		table.insert(filtered, method)
	end

	return filtered, if #constructors == 0 then nil else constructors
end

function strbuf:pushClass(class: moonwave.moonwave_high_class, _titleIndent: number?): strbuf
	local titleIndent = _titleIndent or 1
	local childrenIndent = titleIndent + 1
	self:pushTitle(class.name, titleIndent)

	-- attrs
	self:pushAttrs(class)

	-- Filter constructors
	local functions: { moonwave.moonwave_high_function }?
	local functionConstructors: { moonwave.moonwave_high_function }?
	local methods: { moonwave.moonwave_high_function }?
	local methodConstructors: { moonwave.moonwave_high_function }?
	if class.functions then
		functions, functionConstructors = strbuf.filterConstructor(class.functions)
	end
	if class.methods then
		methods, methodConstructors = strbuf.filterConstructor(class.methods)
	end

	-- Push comments
	if class.comments ~= "" then
		self:pushComments(class.comments)
	end

	-- Push constructors
	if functionConstructors or methodConstructors then
		self:pushTitle("Constructors", childrenIndent)
		if functionConstructors then
			self:pushFunctions(functionConstructors, childrenIndent, false)
		end
		if methodConstructors then
			self:pushFunctions(methodConstructors, childrenIndent, false)
		end
	end

	-- Children
	if class.fields then
		self:pushFields(class.fields, childrenIndent)
	end
	if class.props then
		self:pushProps(class.props, childrenIndent)
	end
	if functions then
		self:pushFunctions(functions, childrenIndent)
	end
	if methods then
		self:pushMethods(methods, childrenIndent)
	end
	-- TODO: type

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
	indent: (str: string, indent: string) -> string,
	pushHr: (self: strbuf) -> strbuf,
	pushProps: (
		self: strbuf,
		props: { moonwave.moonwave_high_field },
		titleIndent: number?,
		noTitle: boolean?
	) -> strbuf,
	pushFields: (
		self: strbuf,
		fields: { moonwave.moonwave_high_field },
		titleIndent: number?,
		noTitle: boolean?
	) -> strbuf,
	pushFunctions: (
		self: strbuf,
		functions: { moonwave.moonwave_high_function },
		titleIndent: number?,
		noTitle: boolean?
	) -> strbuf,
	pushMethods: (
		self: strbuf,
		methods: { moonwave.moonwave_high_function },
		titleIndent: number?,
		noTitle: boolean?
	) -> strbuf,
	pushAttrs: (
		self: strbuf,
		item: moonwave.moonwave_high_field | moonwave.moonwave_high_function | moonwave.moonwave_high_class
	) -> strbuf,
	pushClass: (self: strbuf, class: moonwave.moonwave_high_class, titleIndent: number?) -> strbuf,
	filterConstructor: (
		methods: { moonwave.moonwave_high_function }
	) -> ({ moonwave.moonwave_high_function }, { moonwave.moonwave_high_function }?),
	pushComments: (self: strbuf, comments: string) -> strbuf,
}

return strbuf :: { new: () -> strbuf }
