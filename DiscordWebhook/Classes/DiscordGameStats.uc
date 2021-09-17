//======================================
class DiscordGameStats extends GameStats
	native
	config(DiscordWebHook);
//======================================

// Discord Webhook for Republic Commando Gameserver
// Sends game specific data to Discord webhook URL
// For help, check out swrc-modding.net

var globalconfig bool bEnabled;							// Enable this
var globalconfig string WebHookURL;						// Discord Webhook URL
var globalconfig int TimedAnnouncement;					// Send server/map information on timer based (0 = disabled)
var globalconfig string PersonalizedMessageTimer;		// Announce a custom message on timer
var globalconfig string PersonalizedMessageMatchStart;	// Announce a custom message on match start
var globalconfig bool bAnnounceMatchStart;				// Announce server/map settings on match start
var globalconfig bool bAnnounceMatchEnd;				// Announce player/team scores on match end
var globalconfig bool bAnnounceChat;					// Announce regular chat messages
var globalconfig bool bAnnounceTeamChat;				// Announce teamchat messages
var globalconfig bool bAnnouncePlayerJoin;				// Announce when player joins server
var globalconfig bool bAnnouncePlayerLeave;				// Announce when player leaves server
var globalconfig bool bAnnounceNameChange;				// Announce when player changes name
var globalconfig bool bAnnounceScoreKill;				// Announce when one player killed another
var globalconfig bool bAnnounceScoreFlag;				// Announce when team scores points
var globalconfig bool bAnnounceTeamSwitch;				// Announce when player switches team
var globalconfig bool bAnnounceKillingSpree;			// Announce when player is on killingspree

var PlayerController PC;
var int scoreRepublic;
var int scoreTrandoshan;

native final function SendHTTPRequest(string URL, string Data);

// =================================================================================================================================================

function Init()
{
	Super.Init();
}

function PostBeginPlay()
{
	SaveConfig();
	
	Log("********** Discord Web Hook loading... **********");
	
	if(!bEnabled)
	{
		Log("********** Discord Web Hook not enabled, destroying it... **********");
		Destroy();
		return;
	}
	
	if(TimedAnnouncement != 0)
	{
		setTimer(TimedAnnouncement, True);
	}
	
	Level.Game.GameStats = self;
	
	if((bAnnounceChat) || (bAnnounceTeamChat))
	{
		Log("********** Loading Class DiscordBroadcastHandler... **********");
		Level.Game.BroadcastHandler.Destroy();
		Level.Game.BroadcastHandler = Spawn(class'DiscordBroadcastHandler');
	}

	Log("********** Discord Web Hook loaded! **********");
}

function SendDataToWebHook(string Message)
{
	SendHTTPRequest(WebHookURL, "["$GetDateTime()$"] "$Message);
}

// =================================================================================================================================================

function string GetPlayerTeamName(PlayerReplicationInfo PRI)
{
	if(PRI.Team.TeamIndex == 0)
	{
		return "republic";
	}
	else if(PRI.Team.TeamIndex == 1)
	{
		return "trandoshan";
	}
	else
	{
		return "unknown";
	}
}

function string GetTeamByID(string ID)
{
	if(ID == "0")
	{
		return "republic";
	}
	else if(ID == "1")
	{
		return "trandoshan";
	}
	else
	{
		return "unknown";
	}
}

function string GetTopFragger()
{
	local int LastTopScore;
	local string LastTopFragger;
	
	LastTopScore 	= 0;
	LastTopFragger 	= "";

	ForEach DynamicActors(Class'PlayerController', PC)
	{
		if(PC.PlayerReplicationInfo.Score > LastTopScore)
		{
			LastTopScore 	= PC.PlayerReplicationInfo.Score;
			LastTopFragger 	= PC.PlayerReplicationInfo.PlayerName;
		}
	}
	
	if(LastTopScore == 0)
	{
		return "none";
	}
	else
	{
		return LastTopFragger$" - "$LastTopScore;
	}
}

function Timer()
{
	if(Len(PersonalizedMessageTimer) > 0)
	{
		SendDataToWebHook(PersonalizedMessageTimer);
	}
}

// =================================================================================================================================================

function StartGame()
{
	scoreRepublic = 0;
	scoreTrandoshan = 0;

	if(bAnnounceMatchStart)
	{
		if(Len(PersonalizedMessageMatchStart) > 0)
		{
			SendDataToWebHook(PersonalizedMessageMatchStart);
		}
		
		SendDataToWebHook("match started - "$MapName()$" - "$Level.Game.GameName);
	}
}

function EndGame(string Reason)
{
	local string playerScores;
	playerScores = "";

	if(bAnnounceMatchEnd)
	{
		if(Level.Game.bTeamGame)
		{
			SendDataToWebHook("match ended - score: republic "$scoreRepublic$" | "$scoreTrandoshan$" trandoshan");
		}
		else
		{
			SendDataToWebHook("match ended - top fragger: "$GetTopFragger());
		}
		
		ForEach DynamicActors(Class'PlayerController', PC)
		{
			playerScores = playerScores$PC.PlayerReplicationInfo.PlayerName$" - "$PC.PlayerReplicationInfo.Score$"\n";
		}
		
		SendDataToWebHook("results:\n"$playerScores);
	}
}

// =================================================================================================================================================

function BroadcastEvent(Actor Sender, coerce string Msg, optional name Type)
{
	if(bAnnounceChat)
	{
		SendDataToWebHook("chat: "$PlayerController(Sender).PlayerReplicationInfo.PlayerName$": "$Msg);
	}
}

function BroadcastTeamEvent(Controller Sender, coerce string Msg, optional name Type)
{
	if(bAnnounceTeamChat)
	{
		SendDataToWebHook("teamchat ["$GetPlayerTeamName(Sender.PlayerReplicationInfo)$"]: "$PlayerController(Sender).PlayerReplicationInfo.PlayerName$": "$Msg);
	}
}

// =================================================================================================================================================

function ConnectEvent(PlayerReplicationInfo Who)
{
	Super.ConnectEvent(Who);

	if(bAnnouncePlayerJoin)
	{
		SendDataToWebHook(Who.PlayerName$" has joined the game");
	}
}

function DisconnectEvent(PlayerReplicationInfo Who)
{
	Super.DisconnectEvent(Who);

	if(bAnnouncePlayerLeave)
	{
		SendDataToWebHook(Who.PlayerName$" has left the game");
	}
}

// =================================================================================================================================================

function KillEvent(string Killtype, PlayerReplicationInfo Killer, PlayerReplicationInfo Victim, class<DamageType> Damage)
{
	if(bAnnounceScoreKill)
	{
		if((Killer != None) && (Victim != None))
		{
			if(Killer == Victim)
			{
				SendDataToWebHook(Killer.PlayerName$" killed himself");
			}
			else
			{
				SendDataToWebHook(Killer.PlayerName$" fragged "$Victim.PlayerName$" - health: "$Controller(Killer.Owner).Pawn.Health$" | weapon: "$GetItemName(string(Controller(Victim.Owner).GetLastWeapon())));
			}
		}
	}
}

function ScoreEvent(PlayerReplicationInfo Who, float Points, string Desc)
{
	if(Desc == "flag_cap_final")
	{
		if(bAnnounceScoreFlag)
		{
			SendDataToWebHook(Who.PlayerName$" capped flag ["$GetPlayerTeamName(Who)$"]");
		}
	}
	else if(Desc == "flag_ret_friendly")
	{
		if(bAnnounceScoreFlag)
		{
			SendDataToWebHook(Who.PlayerName$" returned flag ["$GetPlayerTeamName(Who)$"]");
		}
	}
	else if(Desc == "base_taken")
	{
		if(bAnnounceScoreFlag)
		{
			SendDataToWebHook(Who.PlayerName$" has taken the base ["$GetPlayerTeamName(Who)$"]");
		}
	}
}

function TeamScoreEvent(int Team, float Points, string Desc)
{
	if(Team == 0)
	{
		scoreRepublic += Points;
	}
	else if(Team == 1)
	{
		scoreTrandoshan += Points;
	}
}

function GameEvent(string GEvent, string Desc, PlayerReplicationInfo Who)
{
	if(GEvent == "NameChange")
	{
		if(Who.PlayerName != Desc)
		{
			if(bAnnounceNameChange)
			{
				SendDataToWebHook(Who.PlayerName$" changed name to "$Desc);
			}
		}
	}
	else if(GEvent == "TeamChange")
	{
		if(bAnnounceTeamSwitch)
		{
			SendDataToWebHook(Who.PlayerName$" switched to "$GetTeamByID(Desc));
		}
	}
	else if(GEvent == "base_saved")
	{
		if(bAnnounceScoreFlag)
		{
			SendDataToWebHook(GetTeamByID(Desc)$" saved the base");
		}
	}
}

function SpecialEvent(PlayerReplicationInfo Who, string Desc)
{
	if(Desc == "first_blood")
	{
		if(bAnnounceScoreKill)
		{
			SendDataToWebHook("first blood @ "$Who.PlayerName);
		}
	}
	else if(Split(Desc,"_",false)[0] == "spree")
	{
		if(bAnnounceKillingSpree)
		{
			if(Split(Desc,"_",false)[1] == "1")
			{
				SendDataToWebHook(Who.PlayerName$" is on a killing spree - 5");
			}
			else if(Split(Desc,"_",false)[1] == "2")
			{
				SendDataToWebHook(Who.PlayerName$" is on a killing spree - 10");
			}
			else if(Split(Desc,"_",false)[1] == "3")
			{
				SendDataToWebHook(Who.PlayerName$" is on a killing spree - 15");
			}
			else if(Split(Desc,"_",false)[1] == "4")
			{
				SendDataToWebHook(Who.PlayerName$" is on a killing spree - 20");
			}
			else if(Split(Desc,"_",false)[1] == "5")
			{
				SendDataToWebHook(Who.PlayerName$" is on a killing spree - 25");
			}
			else if(Split(Desc,"_",false)[1] == "6")
			{
				SendDataToWebHook(Who.PlayerName$" is on a killing spree - 30");
			}
		}
	}
}

// =================================================================================================================================================

function array<string> Split(string str, string div, bool bDiv)
{
   local array<string> temp;
   local bool bEOL;
   local string tempChar;
   local int precount, curcount, wordcount, strLength;
   strLength = len(str);
   bEOL = false;
   precount = 0;
   curcount = 0;
   wordcount = 0;
 
   while(!bEOL)
   {
      tempChar = Mid(str, curcount, 1); //go up by 1 count
      if(tempChar != div)
         curcount++;
      else if(tempChar == div)
      {
         temp[wordcount] = Mid(str, precount, curcount-precount);
         wordcount++;
         if(bDiv)
            precount = curcount; //leaves the divider
         else
            precount = curcount + 1; //removes the divider.
         curcount++;
      }
      if(curcount == strLength)//end of string, flush out the final word.
      {
         temp[wordcount] = Mid(str, precount, curcount);
         bEOL = true;
      }
   }
   return temp;
}

function string GetDateTime()
{
	local string formattedYear;
	local string formattedMonth;
	local string formattedDay;
	local string formattedHour;
	local string formattedMinute;
	local string formattedSecond;
	
	formattedYear 	= string(Level.Year);
	formattedMonth 	= string(Level.Month);
	formattedDay 	= string(Level.Day);
	formattedHour 	= string(Level.Hour);
	formattedMinute = string(Level.Minute);
	formattedSecond = string(Level.Second);
	
	if(Level.Month < 10)
	{
		formattedMonth = "0"$formattedMonth;
	}
	
	if(Level.Day < 10)
	{
		formattedDay = "0"$formattedDay;
	}
	
	if(Level.Hour < 10)
	{
		formattedHour = "0"$formattedHour;
	}
	
	if(Level.Minute < 10)
	{
		formattedMinute = "0"$formattedMinute;
	}
	
	if(Level.Second < 10)
	{
		formattedSecond = "0"$formattedSecond;
	}

	return formattedYear$"-"$formattedMonth$"-"$formattedDay$" "$formattedHour$":"$formattedMinute$":"$formattedSecond;
} 