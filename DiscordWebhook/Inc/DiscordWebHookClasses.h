/*===========================================================================
    C++ class definitions exported from UnrealScript.
    This is automatically generated by the tools.
    DO NOT modify this manually! Edit the corresponding .uc files instead!
===========================================================================*/

#ifndef DISCORDWEBHOOK_NATIVE_DEFS
#define DISCORDWEBHOOK_NATIVE_DEFS

#if SUPPORTS_PRAGMA_PACK
#pragma pack (push,4)
#endif

#ifndef DISCORDWEBHOOK_API
#define DISCORDWEBHOOK_API DLL_EXPORT
#endif

#include "../../Engine/Inc/Engine.h"    //This also includes "Core"

class DISCORDWEBHOOK_API ADiscordGameStats : public AGameStats
{
public:
    BITFIELD bEnabled:1 GCC_PACK(4);
    FStringNoInit WebHookURL GCC_PACK(4);
    INT TimedAnnouncement;
    FStringNoInit PersonalizedMessageTimer;
    FStringNoInit PersonalizedMessageMatchStart;
    BITFIELD bAnnounceMatchStart:1 GCC_PACK(4);
    BITFIELD bAnnounceMatchEnd:1;
    BITFIELD bAnnounceChat:1;
    BITFIELD bAnnounceTeamChat:1;
    BITFIELD bAnnouncePlayerJoin:1;
    BITFIELD bAnnouncePlayerLeave:1;
    BITFIELD bAnnounceNameChange:1;
    BITFIELD bAnnounceScoreKill:1;
    BITFIELD bAnnounceScoreFlag:1;
    BITFIELD bAnnounceTeamSwitch:1;
    BITFIELD bAnnounceKillingSpree:1;
    class APlayerController* PC GCC_PACK(4);
    INT scoreRepublic;
    INT scoreTrandoshan;
    void execSendHTTPRequest(FFrame& Stack, void* Result);
    DECLARE_CLASS(ADiscordGameStats,AGameStats,0|CLASS_Config,DiscordWebHook)
    NO_DEFAULT_CONSTRUCTOR(ADiscordGameStats)
    DECLARE_NATIVES(ADiscordGameStats)
};



#if SUPPORTS_PRAGMA_PACK
#pragma pack (pop)
#endif

#if __STATIC_LINK

#define AUTO_INITIALIZE_REGISTRANTS_DISCORDWEBHOOK \
	ADiscordGameStats::StaticClass(); \

#endif // __STATIC_LINK

#endif // CORE_NATIVE_DEFS