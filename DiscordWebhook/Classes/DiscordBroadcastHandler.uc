//=====================================================
class DiscordBroadcastHandler extends BroadcastHandler;
//=====================================================

var GameStats GS;

function PostBeginPlay()
{
	Super.PostBeginPlay();
}

function Broadcast(Actor Sender, coerce string Msg, optional name Type)
{
	GS = Level.Game.GameStats;

	DiscordGameStats(GS).BroadcastEvent(Sender, Msg, Type);

	Super.Broadcast(Sender, Msg, Type);
}

function BroadcastTeam(Controller Sender, coerce string Msg, optional name Type)
{
	GS = Level.Game.GameStats;

	DiscordGameStats(GS).BroadcastTeamEvent(Sender, Msg, Type);

	Super.BroadcastTeam(Sender, Msg, Type);
}