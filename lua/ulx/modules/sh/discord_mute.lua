local CATEGORY_NAME = "Discord";

function ulx.discordMute(callingPly, targetPlys, duration, shouldUnmute)
  if (shouldUnmute) then
    for i = 1, #targetPlys do
      hook.Run("UnmutePlayer",
        targetPlys[i],
        callingPly:Name() .. " requested from ULX menu"
      );
    end

    ulx.fancyLogAdmin(
      callingPly, "#A un-muted #T", targetPlys
    );
  else
    for i = 1, #targetPlys do
      hook.Run("MutePlayer",
        targetPlys[i],
        callingPly:Name() .. " requested from ULX menu",
        duration
      );
    end

    if (duration > 0) then
      ulx.fancyLogAdmin(
        callingPly, "#A muted #T for #i seconds", targetPlys, duration
      );
    else
      ulx.fancyLogAdmin(
        callingPly, "#A muted #T until the round ends", targetPlys
      );
    end
  end
end

local discordMute = ulx.command(
  CATEGORY_NAME,
  "ulx mute",
  ulx.discordMute,
  "!mute"
);

discordMute:addParam{
  type = ULib.cmds.PlayersArg
};
discordMute:addParam{
  type = ULib.cmds.NumArg,
  min = 0,
  max = 720,
  default = 5,
  hint = "duration, 0 is until round end",
  ULib.cmds.optional,
  ULib.cmds.round
};
discordMute:addParam{
  type = ULib.cmds.BoolArg,
  invisible = true
};

discordMute:setOpposite("ulx unmute", {_, _, _, true}, "!unmute");

discordMute:defaultAccess(ULib.ACCESS_OPERATOR);
discordMute:help("Mute and un-mute the player in Discord");
