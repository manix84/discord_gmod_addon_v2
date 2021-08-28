local post = "post";
local get = "fetch";
local connectionDelayMultiplier = 0.3;

local function makeRequest(method, route, params, callback, tries)
  local defaultTries = 3;
  if (not tries) then tries = defaultTries; end
  local tryCount = (defaultTries - tries) + 1;

  local endpoint  = GetConVar("discord_bot_endpoint"):GetString();
  local authToken = GetConVar("discord_auth_token"):GetString();
  local chatName  = GetConVar("discord_name"):GetString();
  local url = endpoint .. "/" .. route;
  local authorization = "BEARER " .. authToken;

  local function onError(err)
    print("[" .. chatName .. "][" .. err.code .. "] " .. err.message);
  end
  local function onSuccess(body, _size, _headers, code)
    local bodyTable = util.JSONToTable(body)
    if (code ~= 200) then
      onError(bodyTable.error)
      return;
    end;
    callback(bodyTable);
  end
  local function onFailure(err)
    print("[" .. chatName .. "][Try " .. tryCount .. "] Request to bot failed to respond. The Discord Bot may be offline, or the connection is blocked.");
    if (tries ~= 0) then
      timer.Simple(tryCount * connectionDelayMultiplier, function()
        makeRequest(method, route, params, callback, tries - 1);
      end)
    end
  end

  if (method == post) then
    http.Post(url, params, onSuccess, onFailure, {
      ["authorization"] = authorization
    });
  else
    http.Fetch(url, onSuccess, onFailure, {
      ["authorization"] = authorization,
      ["params"] = util.TableToJSON(params)
    });
  end
end

bot = {};
function bot:requestData(route, params, callback)
  return makeRequest(
    get, route, params, callback
  );
end
function bot:playerAction(targetPly, action, params, callback)
  if (targetPly:IsBot()) then return; end;
  local discordServerID = GetConVar("discord_server_id"):GetString();
  local discordChannelID = GetConVar("discord_channel_id"):GetString();
  local steamUserID = targetPly:SteamID64();
  local route = "servers/" .. discordServerID ..
                "/channels/" .. discordChannelID ..
                "/users/" .. steamUserID ..
                "/" .. action;
  return makeRequest(
    post, route, params, callback
  );
end
