AddCSLuaFile();

CreateClientConVar("discord_show_mute_icon", 1, true, false, "Should show the mute/deafen icons.");

resource.AddFile("materials/icon256/mute.png");
muteIconAsset = Material("materials/icon256/mute.png", "smooth mips");

shouldDrawMute = false;
net.Receive("drawMute", function()
  shouldDrawMute = net.ReadBool();
end);

hook.Add("HUDPaint", "discord_HUDPaint", function()
  if (not shouldDrawMute) then return; end
  surface.SetDrawColor(176, 40, 40, 255);
  surface.SetMaterial(muteIconAsset);
  surface.DrawTexturedRect(32, 32, 256, 256);
end);
