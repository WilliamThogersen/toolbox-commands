return function(args)
  if args.limit < 1 or args.limit > 100 then error("limit must be between 1 and 100", 0) end
  local res = http.get("https://api.github.com/search/issues", {
    headers = {
      Authorization = "Bearer " .. vault("github"),
      Accept = "application/vnd.github+json",
      ["User-Agent"] = "toolbox-gh-prs",
    },
    query = { q = "is:pr is:open archived:false review-requested:@me", sort = "updated", per_page = args.limit },
  })
  if res.status == 401 then error("GitHub rejected the token: store a new one with `tb self vault add github --host api.github.com`", 0) end
  if res.status ~= 200 then error("GitHub returned HTTP " .. res.status, 0) end
  local prs = {}
  for i, it in ipairs(res.json.items) do
    prs[i] = {
      repo = it.repository_url:match("repos/(.+)$"),
      number = it.number,
      title = it.title,
      author = it.user and it.user.login,
      draft = it.draft or false,
      updated_at = it.updated_at,
      url = it.html_url,
    }
  end
  return { total = res.json.total_count, pull_requests = prs }
end
