-- rockspec format available at
-- https://github.com/luarocks/luarocks/wiki/Rockspec-format
-- this should be converted to an addon
-- https://github.com/luarocks/luarocks/wiki/Addon-author's-guide
-- needs at least one json library, for instance luaPackages.cjson
local nix = {}
package.loaded["luarocks.nix"] = nix

local pack = require("luarocks.pack")
local path = require("luarocks.path")
local util = require("luarocks.util")
local repos = require("luarocks.repos")
local fetch = require("luarocks.fetch")
local search = require("luarocks.search")
local unpack = require("luarocks.unpack")
local download = require("luarocks.download")
local fs = require("luarocks.fs")
local dir = require("luarocks.dir")
local deps = require("luarocks.deps")
local manif = require("luarocks.manif")
local remove = require("luarocks.remove")
local cfg = require("luarocks.cfg")

local nixpkgs_folder = "pkgs/development/lua-modules"
local filename = "luarocks-packages.nix"

util.add_run_function(nix)
nix.help_summary = "Build/compile a rock."
nix.help_arguments = "[--pack-binary-rock] [--keep] {<rockspec>|<rock>|<name> [<version>]}"
nix.help = [[
toto test
]]..util.deps_mode_help()


function table2str(s)
local t = { }
for k,v in pairs(s) do
	t[#t+1] = k.."="..tostring(v)..";"
end
return "{\n"..table.concat(t,"\n").." }\n"
end

local function do_build(name, version, deps_mode, build_only_deps)
	-- only support rockspec for now
   if name:match("%.rockspec$") then
      return build.build_rockspec(name, true, false, deps_mode, build_only_deps)
   -- elseif name:match("%.src%.rock$") then
   --    return build.build_rock(name, false, deps_mode, build_only_deps)
   -- elseif name:match("%.all%.rock$") then
   --    local install = require("luarocks.install")
   --    local install_fun = build_only_deps and install.install_binary_rock_deps or install.install_binary_rock
   --    return install_fun(name, deps_mode)
   -- elseif name:match("%.rock$") then
   --    return build.build_rock(name, true, deps_mode, build_only_deps)
   -- elseif not name:match(dir.separator) then
   --    local search = require("luarocks.search")
   --    return search.act_on_src_or_rockspec(do_build, name:lower(), version, nil, deps_mode, build_only_deps)
   end
   return nil, "Don't know what to do with "..name
end

-- return header
-- function nix.header()
-- 	local header = "/* "..filename.." is an auto-generated file -- DO NOT EDIT! */"
-- 	return header
-- end
local function generate_metadata(spec)

end

local function convert2nixLicense(spec)
	-- should parse spec.description.license instead !
	return "stdenv.lib.licenses.mit"
end


-- build 'src' component of the derivation
-- function get_src2(spec, url)
-- 	-- todo use url
-- 	local success, msg=	unpack.command(flags, name, version)
-- end

function get_src(spec, url)
-- end
-- function nix.get_checksum(spec)
-- TODO download the src.rock unpack it and get the hash around it ?
	local prefetch_url_program = "/run/current-system/sw/bin/nix-prefetch-url"
	local prefetch_git_program = "/home/teto/.nix-profile/bin/nix-prefetch-git"

	-- local url = spec.source.url
	-- TODO just write fetchrock
	-- msg is path to rockspec
	local command = prefetch_url_program.." "..url
	local checksum = nil
	local fetch_method = nil
	-- fetchgit url/rev/sha256
	-- todo check lua-msgpack
	-- if spec.source.url:match("^git")  then
	-- 	-- with quiet flag we get only json"--quiet"
	-- 	-- quiet to print only the json
	-- 	command = prefetch_git_program.." --quiet --rev "..tostring(spec.source.tag).." "..spec.source.url
	-- 	-- a nil value ?
	-- 	local json_ok, json = util.require_json()
	-- 	if not json_ok then
	-- 		util.printerr("No json available")
	-- 		return nil, "A JSON library is required for this command. "..json
	-- 	end

	-- 	-- print("running command: "..command)
	-- 	local r = io.popen(command, 'r')
	-- 	-- hwy did I need a * here ?
	-- 	local out, err, retcode = r:read("*a")
	-- 	-- print("output")
	-- 	-- print(out)
	-- 	-- # table.concat(out)
	-- 	local res = json.decode(out)
	-- 	-- print("res=", res)
	-- 	-- util.printout("res=", res.sha256)
	-- 	checksum = res.sha256
	-- 	fetchmethod = ""

	-- 	local rev = spec.source.branch or spec.source.tag
	-- 	util.printerr(spec.package..": rev=", rev)
 		-- return " fetchfromgit "..table2str({
	-- 		url=util.LQ(spec.source.url),
	-- 		rev=util.LQ(rev),
	-- 		sha256=util.LQ(checksum)
	-- 	})
	-- else
		-- utils.printout()
		local r = io.popen(command)
		checksum=r:read()
		fetchmethod = "fetchurl"
		-- spec.source.url
		return " fetchurl "..table2str({url=(url), sha256=util.LQ(checksum)})
	-- end

end



--TODO override the execution done in builtin.run(spec)
-- maybe we can add nix as a specific platform
function nix.generateBuildInstructions(spec)
	-- chcek build folder, builtin
	if spec.build.type == "builtins" then

		--monkeypatch builtin.execute
		-- todo save & restore it
		commands = ""
		builtin.execute = function (...)
			commands = commands ..  (table.concat({...}, " ").."\n")
		end
		builtin.run(spec)
		return {
			preBuild=commands
		}
	end

end
--
--
--
function convert_license(value)
	return value
end
-- function nix.convert2nix(name)

-- for now accept only *.rosckspec files
--
--  Attemps to generate the following package
--
--  luabitop = buildLuaPackage rec {
--    version = "1.0.2";
--    name = "bitop-${version}";
--    src = fetchurl {
--      url = "http://bitop.luajit.org/download/LuaBitOp-${version}.tar.gz";
--      sha256 = "16fffbrgfcw40kskh2bn9q7m3gajffwd2f35rafynlnd7llwj1qj";
--    };
--
--

-- TODO
function convert_rock2nix(rock)
end



function convert_rockspec2nix(rockspec)
end

-- TODO take into account external_dependencies !!
-- @param name lua package name e.g.: 'lpeg', 'mpack' etc
function nix.convert2nix(name)
	-- todo just download/unpack
	-- for now we accept only rockspec_filename
	flags = {
		source= 1
	}
	version=nil
    -- local query = search.make_query(name, version)
	-- arch can be "src" or "rockspec"
	-- query.arch = "rockspec"
    -- local url, search_err = search.find_suitable_rock(query)
	-- if not url then
		-- return false, search_err
	-- end

    -- local filename, err = download.get_file(url)
	-- arch, name, version, all
	-- util.printout("name:", name)
    local rock_filename, msg = download.download("src", name, version, nil)
	if not rock_filename then

-- source = {
--   url = 'https://github.com/neovim/lua-client/archive/' .. version .. '.tar.gz',
--   dir = 'lua-client-' .. version,
-- }
		print("failure while downloading ? src=", msg)
		return msg, "failure while downloading ?"
	end

	-- to speed up testing
	-- url = "https://luarocks.org/luabitop-1.0.2-1.src.rock"
	-- filename = "/home/teto/luarocks/src/luabitop-1.0.2-1.src.rock"
	local url = msg
	util.printout("downloading from url ", url)
	util.printout("got file ", rock_filename)

	-- local path, msg = download.command(flags, name, version)

	-- to overwrite folders 
	flags["force"] = 1
	-- can get url from rockspec.url maybe ?

	-- should work for both
	local spec, msg =	unpack.command(flags, rock_filename, version)
	if not spec then
		print("failure while unpacking ?")
		return nil, msg
	end

   -- rockspec_filename = msg
   -- util.printout("trying to load ", success, rockspec_filename)
   -- local spec, err = unpack.unpack_rock(
	-- local unpack_dir, err = fetch.fetch_and_unpack_rock(rock_filename, "..")
   -- if not unpack_dir then
	   -- return nil, err
	-- end 
   -- local spec, err, errcode = fetch.load_rockspec(rockspec_filename, "..")
   -- if not spec then
	   -- util.printerr(err)
	   -- return nil, err
	-- end

   -- deps.parse_dep(dep) is called fetch.load_local_rockspec so 
   -- so we havebuildLuaPackage defined in
   local dependencies = ""
   for id, dep in ipairs(spec.dependencies)
   do
	   -- todo can I use a "join" func ?
		-- deps.constraints is a table {op, version}
		dependencies = dependencies.." "..dep.name
	   -- print("name; ", id, "dep:", dep.name)
   end

    -- the good thing is zat nix-prefetch-zip caches downloads in the store
	-- local checksum = nix.get_checksum(spec)
	-- util.printerr("checksum=",checksum)

	local function installStr(spec)
		-- what if nil ?
		-- TODO maybe we should inject our own fs.lua
		-- and overwrite the functions called by
		-- function repos.deploy_files(name, version, wrap_bin_scripts, deps_mode)
		for file, path in pairs(spec.build.install)
		do
		end
	end



	-- todo check constraints to choose the correct version of lua
	local attrs = {
		pname=util.LQ(spec.name),
		version=util.LQ(spec.version),
		-- we should run sthg to get sha
		src=get_src(spec, url),
		-- src=get_src2(spec),
		-- add license ? MAINTAINERS
		-- add convert_license(spec.description.license) in meta
		meta= table2str({
			homepage=spec.description.homepage or spec.source.url,
			description=util.LQ(spec.description.summary),
			license=convert2nixLicense(spec)
		}),
		-- nativeInputs etc will depend on the type of package (binary or ...)

		-- preBuild=nix.generateBuildInstructions(spec),
		propagatedBuildInputs = "[".. dependencies .."]",
		-- todo this is wrong
		-- installPhase = [[''
		-- mkdir -p $out/lib/lua/${lua.luaversion}
		-- install -p bit.so $out/lib/lua/${lua.luaversion}
		-- '' ]]
	}

   -- todo parse license too
   -- see https://stackoverflow.com/questions/1405583/concatenation-of-strings-in-lua for the best method to concat strings

	local str = spec.name.." = buildLuaPackage rec "
	str = str..table2str(attrs)..";"
	-- str = str.."\n}\n"
	-- spec.install => install phase
    -- installPhase = ''
    --   mkdir -p $out/lib/lua/${lua.luaversion}
    --   install -p bit.so $out/lib/lua/${lua.luaversion}
    -- '';


   -- ret, err = fd:write(str)
   local err = false
   print(str)
   ret = true
   if not ret then
	   util.printerr("Error happened: "..err)
	end

   return true
end



--- Driver function for "build" command.
-- @param name string: A local or remote rockspec or rock file.
-- If a package name is given, forwards the request to "search" and,
-- if returned a result, installs the matching rock.
-- @param version string: When passing a package name, a version number may
-- also be given.
-- @return boolean or (nil, string, exitcode): True if build was successful; nil and an
-- error message otherwise. exitcode is optionally returned.
function nix.command(flags, name, version)
   if type(name) ~= "string" then
      return nil, "Expects rockspeck filename as first argument. "..util.see_help("build")
   end
   assert(type(version) == "string" or not version)
   -- print("hello world name=", name)
   local res, err = nix.convert2nix(name)
   return res, err

   -- if flags["pack-binary-rock"] then
   --    return pack.pack_binary_rock(name, version, do_build, name, version, deps.get_deps_mode(flags))
   -- else
end


return nix
