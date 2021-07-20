local CATEGORY_NAME = "Discord";

function ulx.discordDeafen(callingPly, targetPlys, duration, shouldUndeafen)
  if (shouldUndeafen) then
    for i = 1, #targetPlys do
      hook.Run("UndeafenPlayer",
        targetPlys[i],
        callingPly:Name() .. " requested from ULX menu"
      );
    end

    ulx.fancyLogAdmin(
      callingPly, "#A un-deafened #T", targetPlys
    );
  else
    for i = 1, #targetPlys do
      hook.Run("DeafenPlayer",
        targetPlys[i],
        callingPly:Name() .. " requested from ULX menu",
        duration
      );
    end

    ulx.fancyLogAdmin(
      callingPly, "#A deafened #T for #i seconds", targetPlys, duration
    );
  end
end

local discordDeafen = ulx.command(
  CATEGORY_NAME,
  "ulx deafen",
  ulx.discordDeafen,
  "!deafen"
);

discordDeafen:addParam{
  type = ULib.cmds.PlayersArg
};
discordDeafen:addParam{
  type = ULib.cmds.NumArg,
  min = 0,
  max = 720,
  default = 5,
  hint = "duration, 0 is until round end",
  ULib.cmds.optional,
  ULib.cmds.round
};
discordDeafen:addParam{
  type = ULib.cmds.BoolArg,
  invisible = true
};

discordDeafen:setOpposite("ulx undeafen", {_, _, _, true}, "!undeafen");

discordDeafen:defaultAccess(ULib.ACCESS_OPERATOR);
discordDeafen:help("Deafen and un-deafen the player in Discord");
