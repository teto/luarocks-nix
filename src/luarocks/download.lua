local download = {}

local path = require("luarocks.path")
local fetch = require("luarocks.fetch")
local search = require("luarocks.search")
local queries = require("luarocks.queries")
local fs = require("luarocks.fs")
local dir = require("luarocks.dir")
local util = require("luarocks.util")


-- @return boolean or (nil, string): true if successful or nil followed
function download.get_file(filename)
   local protocol, pathname = dir.split_url(filename)
   if protocol == "file" then
      local ok, err = fs.copy(pathname, fs.current_dir(), "read")
      if ok then
         return pathname
      else
         return nil, err
      end
   else
      return fetch.fetch_url(filename)
   end
end

--- Driver function for the "download" command.
-- @param name string: a rock name.
-- @param version string or nil: if the name of a package is given, a
-- version may also be passed.
-- @return boolean or (nil, string): true if successful or nil followed
-- by an error message.
function download.download(arch, name, namespace, version, all, check_lua_versions)
   local substring = (all and name == "")
   local query = queries.new(name, namespace, version, substring, arch)
   local search_err

   if all then
      local results = search.search_repos(query)
      local has_result = false
      local all_ok = true
      local any_err = ""
      for name, result in pairs(results) do
         for version, items in pairs(result) do
            for _, item in ipairs(items) do
               -- Ignore provided rocks.
               if item.arch ~= "installed" then
                  has_result = true
                  local filename = path.make_url(item.repo, name, version, item.arch)
                  local ok, err = download.get_file(filename)
                  if not ok then
                     all_ok = false
                     any_err = any_err .. "\n" .. err
                  end
               end
            end
         end
      end

      if has_result then
         return all_ok, any_err
      end
   else
      local url
      url, search_err = search.find_rock_checking_lua_versions(query, check_lua_versions)
      if url then
		  -- todo could reutrn the url too
         return download.get_file(url), url
      end
   end
   local rock = util.format_rock_name(name, namespace, version)
   return nil, "Could not find a result named "..rock..(search_err and ": "..search_err or ".")
end

return download
