CreateConVar("discord_bot_endpoint", "http://localhost:3000", FCVAR_PROTECTED, "Sets the node bot endpoint. Unless you're self-hosting, don't change this.");
CreateConVar("discord_auth_token", "", FCVAR_PROTECTED, "The Auth Token, used for communication with the bot. (https://github.com/manix84/discord_gmod_addon_v2/wiki/Getting-an-Auth-Token)");
CreateConVar("discord_server_id", "", FCVAR_PROTECTED, "The Discord ID for your Guild. (https://github.com/manix84/discord_gmod_addon_v2/wiki/Finding-your-Guild-ID-(Server-ID))");
CreateConVar("discord_debug", 0, FCVAR_PROTECTED, "Print debug messages to console. Helps diagnose annoying issues.");

CreateConVar("discord_chat_name", "Discord", FCVAR_NOTIFY, "Sets the Plugin Prefix for helpermessages (eg: `[Discord] You've been muted.`).");
CreateConVar("discord_server_link", "", FCVAR_NOTIFY, "Sets the Discord server your bot is present on (eg: https://discord.gg/aBc123).");
CreateConVar("discord_mute_round", 1, FCVAR_NOTIFY, "Mute the player until the end of the round.", 0, 1);
CreateConVar("discord_mute_duration", 5, FCVAR_NOTIFY, "Sets how long, in seconds, you are muted for after death. No effect if mute_round is on. ", 1, 720);

util.AddNetworkString("drawMuteIcon");
util.AddNetworkString("drawDeafenIcon");

include("discord/utils/sv_bot.lua");

-- Generic Functions --
-----------------------
local function drawMuteIcon(targetPly, shouldDrawMute)
  net.Start("drawMuteIcon");
  net.WriteBool(shouldDrawMute);
  net.Send(targetPly);
end
local function drawDeafenIcon(targetPly, shouldDrawDeafen)
  net.Start("drawDeafenIcon");
  net.WriteBool(shouldDrawDeafen);
  net.Send(targetPly);
end

local function commonRoundState()
  if (gmod.GetGamemode().Name == "Trouble in Terrorist Town" or gmod.GetGamemode().Name == "TTT2 (Advanced Update)") then return (GetRoundState() == 3) and 1 or 0; end -- Round state 3 => Game is running
  if (gmod.GetGamemode().Name == "Murder") then return (gmod.GetGamemode():GetRound() == 1) and 1 or 0; end -- Round state 1 => Game is running
  -- Round state could not be determined

  return -1;
end

-- Action Functions --
----------------------
local function mutePlayer(targetPly, reason)
  bot:playerAction(targetPly, "mute", { reason = reason }, function(res)
    drawMuteIcon(targetPly, true);
  end);
end

local function unmutePlayer(targetPly, reason)
  bot:playerAction(targetPly, "unmute", { reason = reason }, function(res)
    drawMuteIcon(targetPly, false);
  end);
end

local function deafenPlayer(targetPly, reason)
  bot:playerAction(targetPly, "deafen", { reason = reason }, function(res)
    drawDeafenIcon(targetPly, true);
  end);
end

local function undeafenPlayer(targetPly, reason)
  bot:playerAction(targetPly, "undeafen", { reason = reason }, function(res)
    drawDeafenIcon(targetPly, false);
  end);
end

local function unmuteAllPlayers(reason)
  for i, targetPly in ipairs(player.GetAll()) do
    drawMuteIcon(targetPly, true);
    bot:playerAction(targetPly, "unmute", { reason = reason }, function(res) end);
  end
end

local function undeafenAllPlayers(reason)
  for i, targetPly in ipairs(player.GetAll()) do
    bot:playerAction(targetPly, "undeafen", { reason = reason }, function(res)
      drawDeafenIcon(targetPly, false);
    end);
  end
end

-- Discord Muter Hooks --
-------------------------
hook.Add("MutePlayer", "Discord_MutePlayer", function(targetPly, reason, duration)
  mutePlayer(targetPly, reason);
  if (duration > 0) then
    timer.Simple(duration, function()
      unmutePlayer(targetPly, "Unmuted after " .. duration .. " seconds");
    end);
  end
end);

hook.Add("UnmutePlayer", "Discord_UnmutePlayer", function(targetPly, reason)
  unmutePlayer(targetPly, reason);
end);

hook.Add("DeafenPlayer", "Discord_MutePlayer", function(targetPly, reason, duration)
  deafenPlayer(targetPly, reason);
  if (duration > 0) then
    timer.Simple(duration, function()
      undeafenPlayer(targetPly, "Undeafened after " .. duration .. " seconds");
    end);
  end
end);

hook.Add("UndeafenPlayer", "Discord_UnmutePlayer", function(targetPly, reason)
  undeafenPlayer(targetPly, reason);
end);

-- Game Hooks --
----------------
hook.Add("PlayerSay", "Discord_PlayerSay", function(targetPly, msg)
  if (targetPly:IsBot()) then return; end;
  if (string.sub(msg, 1, 9) ~= "!discord ") then return; end
  local linkToken = string.sub(msg, 10);
  bot:request("link", {
    link_token = linkToken
  }, function(res)
  end);

  return "";
end);

hook.Add("PlayerInitialSpawn", "Discord_PlayerInitialSpawn", function(targetPly)
  if (targetPly:IsBot()) then return; end;
end);

hook.Add("PlayerSpawn", "Discord_PlayerSpawn", function(targetPly)
  if (targetPly:IsBot()) then return; end;
  unmutePlayer(targetPly, "Player Spawn");
  undeafenPlayer(targetPly, "Player Spawn");
end);

hook.Add("PlayerDisconnected", "Discord_PlayerDisconnected", function(targetPly)
  if (targetPly:IsBot()) then return; end;
  unmutePlayer(targetPly, "Played Disconnected");
  undeafenPlayer(targetPly, "Played Disconnected");
end);

hook.Add("ShutDown", "Discord_ShutDown", function()
  unmuteAllPlayers("Server Shutdown");
  undeafenAllPlayers("Server Shutdown");
end);

hook.Add("OnEndRound", "Discord_OnEndRound", function()
  timer.Simple(0.1, function()
    unmuteAllPlayers("Round Ended");
    undeafenAllPlayers("Round Ended");
  end);
end);

hook.Add("TTTEndRound", "Discord_TTTEndRound", function()
  timer.Simple(0.1, function()
    unmuteAllPlayers("Round Ended");
    undeafenAllPlayers("Round Ended");
  end);
end);

hook.Add("OnStartRound", "Discord_OnStartRound", function()
  unmuteAllPlayers("Round Started");
  undeafenAllPlayers("Round Started");
end);

hook.Add("TTTBeginRound", "Discord_TTTBeginRound", function()
  unmuteAllPlayers("Round Started");
  undeafenAllPlayers("Round Started");
end);

hook.Add("PostPlayerDeath", "Discord_PostPlayerDeath", function(targetPly)
  if (targetPly:IsBot()) then return; end;
  local muteWholeRound = GetConVar("discord_mute_round"):GetBool();
  local duration = GetConVar("discord_mute_duration"):GetInt();
  if (commonRoundState() == 1) then
    mutePlayer(targetPly, "Player was killed");
    if (not muteWholeRound) then
      timer.Simple(duration, function()
        unmutePlayer(targetPly, "Unmuted after " .. duration .. " seconds");
      end);
    end
  end
end);
