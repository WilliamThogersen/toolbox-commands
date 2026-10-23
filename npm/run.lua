return function(args)
  local name = args.name
  if not name:match("^@?[%w%._%-]+/?[%w%._%-]*$") then
    error("invalid package name '" .. name .. "'", 0)
  end
  local res = http.get("https://registry.npmjs.org/" .. url.encode(name), {
    headers = { Accept = "application/vnd.npm.install-v1+json, application/json" },
  })
  if res.status == 404 then error("package '" .. name .. "' not found on npm", 0) end
  if res.status ~= 200 then error("npm registry returned HTTP " .. res.status, 0) end
  local p = res.json
  local latest = p["dist-tags"] and p["dist-tags"].latest
  if not latest then error("package '" .. name .. "' has no latest version", 0) end

  -- the abbreviated document has no description or repository, so ask for the full one
  local full = http.get("https://registry.npmjs.org/" .. url.encode(name) .. "/" .. url.encode(latest))
  local v = full.status == 200 and full.json or {}

  local downloads
  local d = http.get("https://api.npmjs.org/downloads/point/last-month/" .. url.encode(name))
  if d.status == 200 and d.json then downloads = d.json.downloads end

  local repo = v.repository
  if type(repo) == "table" then repo = repo.url end
  if type(repo) == "string" then
    repo = repo:gsub("^git%+", ""):gsub("^git://", "https://"):gsub("%.git$", "")
  end
  return {
    name = v.name or name,
    version = latest,
    description = v.description,
    downloads_last_month = downloads,
    license = v.license,
    repository = repo,
    homepage = v.homepage,
    url = "https://www.npmjs.com/package/" .. name,
  }
end
