local HEADERS = { Accept = "application/vnd.github+json", ["User-Agent"] = "toolbox-gh-repo" }

local function check(res, what)
  if res.status == 403 or res.status == 429 then
    error("GitHub rate limit reached for unauthenticated requests, try again later", 0)
  end
  if res.status ~= 200 then error("GitHub returned HTTP " .. res.status .. " for " .. what, 0) end
end

return function(args)
  local repo = args.repo
  if not repo:match("^[%w%._%-]+/[%w%._%-]+$") then
    error("repo must look like owner/name, got '" .. repo .. "'", 0)
  end
  local res = http.get("https://api.github.com/repos/" .. repo, { headers = HEADERS })
  if res.status == 404 then error("repo '" .. repo .. "' not found (or it is private)", 0) end
  check(res, repo)
  local r = res.json

  local release = http.get("https://api.github.com/repos/" .. repo .. "/releases/latest", { headers = HEADERS })
  local tag, released
  if release.status == 200 then
    tag, released = release.json.tag_name, release.json.published_at
  elseif release.status ~= 404 then
    check(release, "releases of " .. repo)
  end

  return {
    repo = r.full_name,
    description = r.description,
    language = r.language,
    stars = r.stargazers_count,
    forks = r.forks_count,
    open_issues = r.open_issues_count,
    latest_release = tag,
    released_at = released,
    license = r.license and r.license.spdx_id,
    archived = r.archived,
    pushed_at = r.pushed_at,
    url = r.html_url,
  }
end
