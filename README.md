# Republic Commando - Discord Webhook

This is a pure server plugin for Star Wars Republic Commando to send data to a discord webhook URL.


# How to install

Copy the DiscordWebhook.u/.dll/.ini files into GameData/System folder.
Edit DiscordWebhook.ini configuration to fit your needs.

The WebHookURL only needs the URL after domain, eg.:
WebHookURL=/api/webhooks/123456/abcdef

When using bAnnounceChat and/or bAnnounceTeamChat, admin patch won't work anymore, unless you adjust the code for it.

TimedAnnouncement sends a message any given x seconds using the string defined in PersonalizedMessageTimer


Finally add the class as ServerActor in System.ini file.
ServerActors+=DiscordWebHook.DiscordGameStats


swrc-modding.net