function httpFetch(req, params, callback, tries)
  local defaultTries = 3;
  local endpoint  = GetConVar("discord_bot_endpoint"):GetString();
  local chatName  = GetConVar("discord_chat_name"):GetString();
  local authToken = GetConVar("discord_auth_token"):GetString();

  if (not tries) then tries = defaultTries; end

  http.Fetch(endpoint .. "/" .. req, function(res)
    local resTable = util.JSONToTable(res)
    if (resTable.error and resTable.error.msg) then
      print("[" .. chatName .. "][Error] " .. resTable.error.msg);
    end
    callback(resTable);
  end, function(err)
    print("[" .. chatName .. "] Request to bot failed to respond. Is the bot running? Or is the URL correct?");
    print("[" .. chatName .. "][Error] " .. err);

    if (tries ~= 0) then
      timer.Simple((((tries - default) + 1) * 0.5), function()
        httpFetch(req, params, callback, tries - 1);
      end)
    end
  end, {
    ["authorization"] = "BEARER " .. authToken,
    ["params"] = util.TableToJSON(params)
  });
end
