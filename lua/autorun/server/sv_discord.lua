CreateConVar("discord_bot_endpoint", "http://localhost:3000", FCVAR_PROTECTED, "Sets the node bot endpoint.");
CreateConVar("discord_auth_token", "", FCVAR_PROTECTED, "Sets the node bot api-key.");
CreateConVar("discord_debug", 0, FCVAR_PROTECTED, "Print debug messages to console.");

CreateConVar("discord_chat_name", "Discord", FCVAR_NOTIFY, "Sets the Plugin Prefix for helpermessages (eg: \"[Discord] You've been muted.\").");
CreateConVar("discord_server_link", "", FCVAR_NOTIFY, "Sets the Discord server your bot is present on (eg: https://discord.gg/aBc123).");
CreateConVar("discord_mute_round", 1, FCVAR_NOTIFY, "Mute the player until the end of the round.", 0, 1);
CreateConVar("discord_mute_duration", 5, FCVAR_NOTIFY, "Sets how long, in seconds, you are muted for after death. No effect if mute_round is on. ", 1, 720);

CreateConVar("discord_auto_connect", 0, FCVAR_UNREGISTERED, "Attempt to automatically match player name to discord name. This happens silently when the player connects. If it fails, it will prompt the user with the \"!discord NAME\" message.", 0, 1);

function drawMuteIcon(target_ply, drawMute)
  net.Start("drawMute");
  net.WriteBool(drawMute);
  net.Send(target_ply);
end
