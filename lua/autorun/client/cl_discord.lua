AddCSLuaFile();

CreateClientConVar("discord_show_mute_icon", 1, true, false, "Should show the mute/deafen icons.");

local imgSize = 128
local imgSpace = 32

resource.AddFile("materials/icon" .. imgSize .. "/mute.png");
resource.AddFile("materials/icon" .. imgSize .. "/deafen.png");
local muteIconAsset = Material("materials/icon" .. imgSize .. "/mute.png", "smooth mips");
local deafenIconAsset = Material("materials/icon" .. imgSize .. "/deafen.png", "smooth mips");


shouldDrawMute = false;
net.Receive("drawMute", function()
  shouldDrawMute = net.ReadBool();
end);

shouldDrawdeafen = false;
net.Receive("drawdeafen", function()
  shouldDrawdeafen = net.ReadBool();
end);

hook.Add("HUDPaint", "Discord_HUDPaint", function()
  if (shouldDrawMute) then
    surface.SetDrawColor(176, 40, 40, 255);
    surface.SetMaterial(muteIconAsset);
    surface.DrawTexturedRect(
      imgSpace,
      imgSpace,
      (imgSize + imgSpace),
      (imgSize + imgSpace)
    );
  end
  if (shouldDrawDeafen) then
    surface.SetDrawColor(176, 40, 40, 255);
    surface.SetMaterial(deafenIconAsset);
    if (shouldDrawMute) then
      surface.DrawTexturedRect(
        (imgSpace * 2) + imageSize,
        (imgSpace * 2) + imageSize,
        (imgSpace * 3) + (imageSize * 2),
        (imgSpace * 3) + (imageSize * 2)
      );
    else
      surface.DrawTexturedRect(
        imgSpace, imgSpace,
        (imgSize + imgSpace), (imgSize + imgSpace)
      );
    end
  end
end);

hook.Add("HUDPaint", "Discord_HUDPaint", function()
  if (not shouldDrawdeafen) then return; end
end);
