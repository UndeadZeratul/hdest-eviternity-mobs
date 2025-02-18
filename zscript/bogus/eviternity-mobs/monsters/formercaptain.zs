// ================================================================
// something funny and creative
// ================================================================

actor Bogus_FormerCaptain : HDMobMan replaces Cacodemon
{
	default
	{
		height 54;
		radius 20;
		mass 100;
		speed 8;
		
		seesound "chainguy/sight";
		painsound "chainguy/pain";
		deathsound "chainguy/death";
		activesound "chainguy/active";
		
		health 140;
		hdmobbase.shields 300;
	}
	
	states
	{
		spawn:
			FCAP AABB 8 A_Look();
			FCAP A 0 SetStateLabel("spawn");
			
		see:
			FCAP ABCD 4
			{
				A_HDChase();
			}
			loop;
			
		pain:
			FCAP G 3;
			FCAP G 3 A_Pain();
			FCAP G 0 SetStateLabel("see");
			
		death:
			FCAP H 5;
			FCAP I 5 A_Scream();
			FCAP J 5 A_Fall();
			FCAP KLM 5;
			FCAP N -1;
	}
}