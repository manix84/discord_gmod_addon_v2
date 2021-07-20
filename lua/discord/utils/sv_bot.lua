local post = "post";
local get = "fetch";

local function makeRequest(method, route, params, callback, tries)
  local defaultTries = 3;
  if (not tries) then tries = defaultTries; end

  local endpoint  = GetConVar("discord_bot_endpoint"):GetString();
  local chatName  = GetConVar("discord_chat_name"):GetString();
  local authToken = GetConVar("discord_auth_token"):GetString();
  local url = endpoint .. "/" .. route;
  local authorization = "BEARER " .. authToken;

  local function onError(err)
    print("[" .. chatName .. "] Request to bot failed to respond. The Discord Bot may be offline, or the connection is blocked.");
    print("[" .. chatName .. "][Error] " .. err);
  end
  local function onSuccess(body, _size, _headers, code)
    if (code ~= 200) then
      onError(url .. " [" .. code .. "]");
      return;
    end;
    print(url .. " [" .. code .. "]");
    print(body);

    local bodyTable = util.JSONToTable(body)
    if (bodyTable.error and bodyTable.error.msg) then
      print("[" .. chatName .. "][Error] " .. resTable.error.msg);
    end
    callback(bodyTable);
  end
  local function onFailure(err)
    onError(err)
    if (tries ~= 0) then
      timer.Simple(((tries - defaultTries) + 1) * 0.5, function()
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
  local steamUserID = targetPly:SteamID64();
  local route = "servers/" .. discordServerID ..
                "/users/" .. steamUserID ..
                "/" .. action;
  return makeRequest(
    post, route, params, callback
  );
end
