class EMonSpawnHandler : EventHandler
{
	int spawnmode;
	
	int astralcacorate;
	int astralcacoalways;
	
	int annihilatorrate;
	int annihilatoralways;
	
	int ndemonrate;
	int ndemonalways;
	
	override void WorldLoaded (WorldEvent e)
	{
		spawnmode = CVar.GetCVar("emonsters_masterspawnmode").GetInt();
		
		astralcacorate = CVar.GetCVar("emonsters_acacospawnrate").GetInt();
		astralcacoalways = CVar.GetCVar("emonsters_acacoalways").GetInt();
		
		annihilatorrate = CVar.GetCVar("emonsters_annispawnrate").GetInt();
		annihilatoralways = CVar.GetCVar("emonsters_annialways").GetInt();
		
		ndemonrate = CVar.GetCVar("emonsters_ndemspawnrate").GetInt();
		ndemonalways = CVar.GetCVar("emonsters_ndemalways").GetInt();
	}
	
	bool replaceThing (actor replaced, string newactor, string typea, 
		string typeb, int rate, int spawnmode, int always)
	{
		string replacetype;
		
		switch(spawnmode)
		{
			case 0:		replacetype = typea; break;
			case 1:		replacetype = typeb; break;
			
			default:	replacetype = typea; break;
		}
		
		if (spawnmode == 2)
		{
			if (replaced.GetClassName() == typea)
			{
				if (random(1, 100) <= rate)
				{
					actor thing = replaced.spawn(newactor, replaced.pos);
					thing.angle = replaced.angle;
					replaced.A_CallSpecial(132, 0);
					
					return true;
				}
			}
			else if (replaced.GetClassName() == typeb)
			{
				if (always == 2)
				{
					return false;
				}
				else
				{
					if (always == 1)
					{
						actor thing = replaced.spawn(newactor, replaced.pos);
						thing.angle = replaced.angle;
						replaced.A_CallSpecial(132, 0);
						
						return true;
					}
					else if (random(1, 100) <= rate)
					{
						actor thing = replaced.spawn(newactor, replaced.pos);
						thing.angle = replaced.angle;
						replaced.A_CallSpecial(132, 0);
						
						return true;
					}
				}
			}
		}
		else if (replaced.GetClassName() == replacetype)
		{
			if(replacetype == typeb)
			{
				if (always == 2)
				{
					return false;
				}
				else
				{
					if (always == 1)
					{
						actor thing = replaced.spawn(newactor, replaced.pos);
						thing.angle = replaced.angle;
						replaced.A_CallSpecial(132, 0);
						
						return true;
					}
					else if(random(1, 100) <= rate)
					{
						actor thing = replaced.spawn(newactor, replaced.pos);
						thing.angle = replaced.angle;
						replaced.A_CallSpecial(132, 0);
						
						return true;
					}
				}
			}
			else if(random(1, 100) <= rate)
			{
				actor thing = replaced.spawn(newactor, replaced.pos);
				thing.angle = replaced.angle;
				replaced.A_CallSpecial(132, 0);
				
				return true;
			}
		}
		
		return false;
	}
	
	override void WorldThingSpawned (WorldEvent e)
	{
		if (e.thing)
		{
			if(replacething(e.thing, "Bogus_AstralCacodemon", "FlyZapper", "AstralCaco",
				astralcacorate, spawnmode, astralcacoalways))
			{
			
			}
			else if(replacething(e.thing, "Bogus_Annihilator", "Baron", "Annihilator",
				annihilatorrate, spawnmode, annihilatoralways))
			{
			
			}
			else if(replacething(e.thing, "Bogus_NightmareDemon", "SpecBabuin", "NightmareDemon",
				ndemonrate, spawnmode, ndemonalways))
			{
				
			}
		}
	}
}