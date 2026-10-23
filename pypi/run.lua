return function(args)
  local name = args.name
  if not name:match("^[%w%._%-]+$") then
    error("invalid package name '" .. name .. "': use letters, digits, . - and _", 0)
  end
  local res = http.get("https://pypi.org/pypi/" .. url.encode(name) .. "/json")
  if res.status == 404 then error("package '" .. name .. "' not found on PyPI", 0) end
  if res.status ~= 200 then error("PyPI returned HTTP " .. res.status, 0) end
  local i = res.json.info
  return {
    name = i.name,
    version = i.version,
    summary = i.summary,
    license = i.license_expression or i.license,
    requires_python = i.requires_python,
    author = i.author,
    links = i.project_urls,
    homepage = i.home_page,
    url = i.package_url,
  }
end
