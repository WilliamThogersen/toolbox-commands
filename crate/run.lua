return function(args)
  local name = args.name
  if not name:match("^[%w_%-]+$") then
    error("invalid crate name '" .. name .. "': use letters, digits, - and _", 0)
  end
  local res = http.get("https://crates.io/api/v1/crates/" .. url.encode(name), {
    headers = { ["User-Agent"] = "toolbox-crate (https://github.com/WilliamThogersen/toolbox-commands)" },
  })
  if res.status == 404 then error("crate '" .. name .. "' not found on crates.io", 0) end
  if res.status ~= 200 then error("crates.io returned HTTP " .. res.status, 0) end
  local c = res.json.crate
  return {
    name = c.name,
    version = c.max_stable_version or c.newest_version,
    newest_version = c.newest_version,
    description = c.description,
    downloads = c.downloads,
    recent_downloads = c.recent_downloads,
    repository = c.repository,
    homepage = c.homepage,
    documentation = c.documentation,
    updated_at = c.updated_at,
    url = "https://crates.io/crates/" .. c.name,
  }
end
