local CODES = {
  [0] = "Clear sky", [1] = "Mainly clear", [2] = "Partly cloudy", [3] = "Overcast",
  [45] = "Fog", [48] = "Rime fog",
  [51] = "Light drizzle", [53] = "Drizzle", [55] = "Heavy drizzle",
  [56] = "Freezing drizzle", [57] = "Heavy freezing drizzle",
  [61] = "Light rain", [63] = "Rain", [65] = "Heavy rain",
  [66] = "Freezing rain", [67] = "Heavy freezing rain",
  [71] = "Light snow", [73] = "Snow", [75] = "Heavy snow", [77] = "Snow grains",
  [80] = "Light showers", [81] = "Showers", [82] = "Violent showers",
  [85] = "Snow showers", [86] = "Heavy snow showers",
  [95] = "Thunderstorm", [96] = "Thunderstorm with hail", [99] = "Severe thunderstorm with hail",
}

local function describe(code) return CODES[code] or ("Weather code " .. tostring(code)) end

return function(args)
  local place = args.place
  if place:match("^%s*$") then error("place must not be empty", 0) end
  local days = args.days
  if days < 1 or days > 16 then error("days must be between 1 and 16", 0) end
  local units = args.units
  if units ~= "metric" and units ~= "imperial" then error("units must be 'metric' or 'imperial'", 0) end

  -- the geocoder matches a plain name, so "Austin, Texas" is searched as "Austin"
  local query = place:match("^([^,]+)") or place
  local geo = http.get("https://geocoding-api.open-meteo.com/v1/search", {
    query = { name = query, count = 1, language = "en", format = "json" },
  })
  if geo.status ~= 200 then error("geocoding failed with HTTP " .. geo.status, 0) end
  local hit = geo.json and geo.json.results and geo.json.results[1]
  if not hit then error("no place found for '" .. place .. "'", 0) end

  local q = {
    latitude = hit.latitude, longitude = hit.longitude, timezone = "auto", forecast_days = days,
    current = "temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,precipitation,weather_code",
    daily = "weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,precipitation_probability_max",
  }
  if units == "imperial" then
    q.temperature_unit = "fahrenheit"; q.wind_speed_unit = "mph"; q.precipitation_unit = "inch"
  end
  local res = http.get("https://api.open-meteo.com/v1/forecast", { query = q })
  if res.status ~= 200 then error("forecast failed with HTTP " .. res.status, 0) end
  local w = res.json
  local u = w.current_units or {}

  local forecast = {}
  for i, date in ipairs(w.daily.time) do
    forecast[i] = {
      date = date,
      summary = describe(w.daily.weather_code[i]),
      min = w.daily.temperature_2m_min[i],
      max = w.daily.temperature_2m_max[i],
      precipitation = w.daily.precipitation_sum[i],
      rain_chance_percent = w.daily.precipitation_probability_max[i],
    }
  end
  return {
    place = { name = hit.name, region = hit.admin1, country = hit.country, timezone = w.timezone },
    units = { temperature = u.temperature_2m, wind = u.wind_speed_10m, precipitation = u.precipitation },
    current = {
      time = w.current.time,
      summary = describe(w.current.weather_code),
      temperature = w.current.temperature_2m,
      feels_like = w.current.apparent_temperature,
      humidity_percent = w.current.relative_humidity_2m,
      wind = w.current.wind_speed_10m,
      precipitation = w.current.precipitation,
    },
    forecast = forecast,
  }
end
