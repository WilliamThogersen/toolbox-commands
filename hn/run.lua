return function(args)
  if args.count < 1 or args.count > 50 then error("count must be between 1 and 50", 0) end
  local res = http.get("https://hn.algolia.com/api/v1/search", {
    query = { tags = "front_page", hitsPerPage = args.count },
  })
  if res.status ~= 200 then error("Hacker News search returned HTTP " .. res.status, 0) end
  local stories = {}
  for i, h in ipairs(res.json.hits) do
    stories[i] = {
      rank = i,
      title = h.title,
      url = h.url,
      points = h.points,
      comments = h.num_comments,
      comments_url = "https://news.ycombinator.com/item?id=" .. h.objectID,
      by = h.author,
    }
  end
  return stories
end
