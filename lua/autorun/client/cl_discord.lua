AddCSLuaFile();

resource.AddFile("materials/icon256/mute.png");

shouldDrawMute = false;
muteIconAsset = Material("materials/icon256/mute.png", "smooth mips");

net.Receive("drawMute", function()
  shouldDrawMute = net.ReadBool();
end);

hook.Add("HUDPaint", "discord_HUDPaint", function()
  if (not shouldDrawMute) then return; end
  surface.SetDrawColor(176, 40, 40, 255);
  surface.SetMaterial(muteIconAsset);
  surface.DrawTexturedRect(32, 32, 256, 256);
end);
