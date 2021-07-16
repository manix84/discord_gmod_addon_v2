AddCSLuaFile();

CreateClientConVar("discord_show_icons", 1, true, false, "Should show the mute/deafen icons.");

local imgSize = 64
local imgSpace = imgSize / 8;

local img1 = {
  xO = imgSpace,
  yO = imgSpace,
  xD = imgSize + imgSpace,
  yD = imgSize + imgSpace
};
local img2 = {
  xO = (imgSpace * 2) + imgSize,
  yO = imgSpace,
  xD = imgSize + imgSpace,
  yD = imgSize + imgSpace
};

resource.AddFile("materials/icon" .. imgSize .. "/mute.png");
resource.AddFile("materials/icon" .. imgSize .. "/deafen.png");
local muteIconAsset = Material("materials/icon" .. imgSize .. "/mute.png", "smooth mips");
local deafenIconAsset = Material("materials/icon" .. imgSize .. "/deafen.png", "smooth mips");


local shouldDrawMuteIcon = true;
net.Receive("drawMute", function()
  shouldDrawMuteIcon = net.ReadBool();
end);

local shouldDrawDeafenIcon = true;
net.Receive("drawdeafen", function()
  shouldDrawDeafenIcon = net.ReadBool();
end);

hook.Add("HUDPaint", "Discord_HUDPaint", function()
  if (not GetConVar("discord_show_icons"):GetBool()) then return; end;

  surface.SetDrawColor(176, 40, 40, 255 * 0.8);

  local muteIcon = surface;
  if (shouldDrawMuteIcon) then
    muteIcon.SetMaterial(muteIconAsset);
    muteIcon.DrawTexturedRect(img1.xO, img1.yO, img1.xD, img1.yD);
  end

  local deafenIcon = surface;
  if (shouldDrawDeafenIcon) then
    deafenIcon.SetMaterial(deafenIconAsset);
    if (not shouldDrawMuteIcon) then
      deafenIcon.DrawTexturedRect(img1.xO, img1.yO, img1.xD, img1.yD);
    else
      deafenIcon.DrawTexturedRect(img2.xO, img2.yO, img2.xD, img2.yD);
    end
  end
end);
