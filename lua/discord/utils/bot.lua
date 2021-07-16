bot = {};

function bot:request(request, params, callback, tries)
  local defaultTries = 3;
  local endpoint  = GetConVar("discord_bot_endpoint"):GetString();
  local chatName  = GetConVar("discord_chat_name"):GetString();
  local authToken = GetConVar("discord_auth_token"):GetString();

  if (not tries) then tries = defaultTries; end

  http.Fetch(endpoint .. "/" .. request, function(response)
    local responseTable = util.JSONToTable(response)
    if (responseTable.error and responseTable.error.msg) then
      print("[" .. chatName .. "][Error] " .. resTable.error.msg);
    end
    callback(responseTable);
  end, function(err)
    print("[" .. chatName .. "] Request to bot failed to respond. The Discord Bot may be offline, or the connection is blocked.");
    print("[" .. chatName .. "][Error] " .. err);

    if (tries ~= 0) then
      timer.Simple(((tries - default) + 1) * 0.5, function()
        httpFetch(request, params, callback, tries - 1);
      end)
    end
  end, {
    ["authorization"] = "BEARER " .. authToken,
    ["params"] = util.TableToJSON(params)
  });
end

function bot:playerAction(targetPly, action, params, callback)
  local discordServerID = GetConVar("discord_server_id"):GetString();
  local steamUserID = targetPly:SteamID64();
  return botRequest(
    "servers/" .. discordServerID .. "/users/" .. steamUserID .. "/" .. action,
    params,
    callback
  );
end
