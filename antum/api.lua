--[[ LICENSE HEADER
  
  MIT License
  
  Copyright © 2017 Jordan Irwin
  
  Permission is hereby granted, free of charge, to any person obtaining a copy of
  this software and associated documentation files (the "Software"), to deal in
  the Software without restriction, including without limitation the rights to
  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
  of the Software, and to permit persons to whom the Software is furnished to do
  so, subject to the following conditions:
  
    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.
  
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
  
--]]


-- Displays a message in the log
function antum.log(level, message)
	minetest.log(level, '[' .. minetest.get_current_modname() .. '] ' .. message)
end

function antum.logAction(message)
	antum.log('action', message)
end

function antum.logWarn(message)
	antum.log('warning', message)
end

function antum.logError(message)
	antum.log('error', message)
end


-- Checks if a file exists
function antum.fileExists(file_path)
	local fexists = io.open(file_path, 'r')
	
	if fexists == nil then
		return false
	end
	
	return true
end


-- Retrieves path for currently loaded mod
function antum.getCurrentModPath()
	return minetest.get_modpath(minetest.get_current_modname())
end


--[[
  Loads a mod sub-script.
  
  @param script_name
    Name or base name of the script file
  @param lua_ext
    type: bool
    default: true
    description: If 'true', appends '.lua' extension to script filename
]]--
function antum.loadScript(script_name, lua_ext)
	-- Default 'true'
	if lua_ext == nil then
		lua_ext = true
	end
	
	local script = antum.getCurrentModPath() .. '/' .. script_name
	if lua_ext then
		script = script .. '.lua'
	end
	
	if antum.fileExists(script) then
		dofile(script)
	else
		antum.logError('Could not load, script does not exists: ' .. script)
	end
end


-- Loads multiple mod sub-scripts
function antum.loadScripts(script_list)
	for I in pairs(script_list) do
		antum.loadScript(script_list[I])
	end
end


-- Registers a craft & displays a log message
function antum.registerCraft(def)
	if antum.verbose then
		antum.logAction('Registering craft recipe for "' .. def.output .. '"')
	end
	
	minetest.register_craft(def)
end


-- De-registers a craft by output
function antum.clearCraftOutput(output)
	if antum.verbose then
		antum.logAction('Clearing craft by output: ' .. output)
	end
	
	minetest.clear_craft({
		output = output
	})
end


-- De-registers craft by recipe
function antum.clearCraftRecipe(recipe)
	if antum.verbose then
		local recipe_string = ''
		local icount = 0
		for I in pairs(recipe) do
			icount = icount + 1
		end
		
		for I in pairs(recipe) do
			if I == icount then
				recipe_string = recipe_string .. ' ' .. recipe[I]
			elseif I > 1 then
				recipe_string = recipe_string .. ' + ' .. recipe[I]
			else
				recipe_string = recipe[I]
			end
		end
		
		antum.logAction(' Clearing craft by recipe: ' .. recipe_string)
	end
	
	minetest.clear_craft({
		recipe = {recipe}
	})
end


-- Overrides a previously registered craft using output
function antum.overrideCraftOutput(def)
	antum.clearCraftOutput(def.output)
	antum.registerCraft(def)
end


-- Overrides a previously registered craft using recipe
function antum.overrideCraftRecipe(def)
	antum.clearCraftRecipe(def.replace)
	antum.registerCraft(def)
end


-- Checks if dependencies are satisfied
function antum.dependsSatisfied(depends)
	for index, dep in ipairs(depends) do
		if not minetest.get_modpath(dep) then
			return false
		end
	end
	
	return true
end


--[[
  Retrieves a list of items containing a string.
  
  @param substring
    String to match within item names
  @param case_sensitive
    If 'true', 'substring' case must match that of item name
  @return
    List of item names matching 'substring'
]]--
function antum.getItemNames(substring, case_sensitive)
	antum.logAction('Checking registered items for "' .. substring .. '" in item name ...')
	
	-- Convert to lowercase
	if not case_sensitive then
		substring = string.lower(substring)
	end
	
	local item_names = {}
	
	for index in pairs(minetest.registered_items) do
		local item_name = minetest.registered_items[index].name
		if not case_sensitive then
			item_name = string.lower(item_name)
		end
		
		-- Check item name for substring
		if string.find(item_name, substring) then
			table.insert(item_names, item_name)
		end
	end
	
	return item_names
end


--[[
  Un-registers an item & converts its name to an alias.
  
  @param item_name
    Name of the item to override
  @param alias_of
    Name of the item to be aliased
]]
function antum.convertItemToAlias(item_name, alias_of)
	antum.logAction('Overridding "' .. item_name .. '" with "' .. alias_of .. '"')
	minetest.unregister_item(item_name)
	minetest.register_alias(item_name, alias_of)
end
