// ================================================================
// I'm gonna say the N word. Ni-
//
// -ghtmare.
// ================================================================

class Bogus_NightmareDemon : HDMobBase
{
	bool cloaked;
	bool angery;
	bool cloakfuzzy;
	
	default
	{
		height 50;
		radius 18;
		meleerange 48;
		meleethreshold 512;
		maxdropoffheight 48;
		maxstepheight 48;
		speed 8;
		
		seesound "nightmaredemon/see";
		attacksound "nightmaredemon/melee";
		painsound "nightmaredemon/pain";
		deathsound "nightmaredemon/death";
		activesound "nightmaredemon/active";
		
		obituary "$OB_NIGHTMAREDEMON";
		tag "$TAG_NIGHTMAREDEMON";
		
		health 300;
		hdmobbase.shields 240;
		painchance 100;
	}
	
	override void PostBeginPlay()
	{
		super.PostBeginPlay();

		Resize(0.9, 1.1);

		cloaked = false;
		cloakfuzzy = false;
		bbiped = true;
	}
	
	override void tick()
	{
		super.tick();
		if (!bNoTimeFreeze && isFrozen())
			return;
			
		if (cloaked)
		{
			if(cloakfuzzy)
			{
				if (!random(0, 7))
				{
					A_SetRenderStyle(0, STYLE_None);
					cloakfuzzy = false;
				}
			}
			else if (!random(0, 63))
			{
				cloakfuzzy = true;
				A_SetRenderStyle(frandom(0.5, 0.8), STYLE_Fuzzy);
			}
		}
		else
		{
			A_SetRenderStyle(1, STYLE_Normal);
		}
		let shields = hdmagicshield(self.findinventory("hdmagicshield"));
		if (shields.amount < 240 && !angery)
		{
			angery = true;
			SetStateLabel("see");
		}
	}
	
	void A_Cloak()
	{
		cloaked = true;
		A_SpawnItemEx("Bogus_NightmareDemonBlur", zofs: 1, flags: SXF_TRANSFERSPRITEFRAME|SXF_NOCHECKPOSITION);
	}
	
	void A_Uncloak()
	{
		A_FaceTarget();
		cloaked = false;
		A_SpawnItemEx("HDSmoke",random(-1,1),random(-1,1),random(4,24),vel.x,vel.y,vel.z+random(1,3),0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,0);
		A_SpawnItemEx("HDSmoke",random(-1,1),random(-1,1),random(4,24),vel.x,vel.y,vel.z+random(1,3),0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,0);
		A_SpawnItemEx("HDSmoke",random(-1,1),random(-1,1),random(4,24),vel.x,vel.y,vel.z+random(1,3),0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,0);
		A_PlaySound(seesound);
	}
	
	states
	{
		spawn:
			NDEM A 0 nodelay
			{
				let shields = hdmagicshield(self.findinventory("hdmagicshield"));
				shields.amount = 240;
				cloaked = true;
			}
			
		spawn2:
			NDEM AABB 4 A_LookEx(fov: 270);
			loop;
			
		see:
			NDEM A 0
			{
				if (!target || target.health <= 0)
				{
					angery = false;
				}
				
				if(angery)
				{
					if (cloaked)
					{
						A_Uncloak();
					}
					
					speed = 28;
					SetStateLabel("chase");
				}
				else
				{
					if (!cloaked)
					{
						A_Cloak();
					}
					
					speed = 14;
					SetStateLabel("notice");
				}
			}
			
		notice:
			NDEM ABCD 8
			{
				A_HDChase();
				if (!random(0, 3) && CheckIfCloser(target, radius + 512)
					&& A_JumpIfTargetInLOS("lunge"))
				{
					A_FaceTarget();
					SetStateLabel("lunge");
				}
			}
			loop;
			
		chase:
			NDEM ABCD 4
			{
				A_HDChase();
				if (!random(0, 3) && CheckIfCloser(target, radius + 256)
					&& A_JumpIfTargetInLOS("lunge"))
				{
					SetStateLabel("lunge");
				}
				else if (!random(0, 31) && A_JumpIfTargetInLOS("lunge"))
				{
					SetStateLabel("lunge");
				}
			}
			loop;
			
		pain:
			NDEM H 0
			{
				if (!angery)
				{
					angery = true;
				}
			}
			NDEM H 2;
			NDEM H 2 A_Pain();
			NDEM H 0 SetStateLabel("see");

		lunge:
			NDEM ABCD 4
			{
				A_HDChase();
				if (!A_JumpIfTargetInLOS("lunge"))
				{
					SetStateLabel("see");
				}
			}
			NDEM E 0
			{
				if (!angery)
				{
					angery = true;
				}
				cloaked = false;
			}
			NDEM EE 2 A_FaceTarget(30);
			NDEM E 6;
			NDEM E 0
			{
				if (random(0, 2))
				{
					A_SpawnItemEx("Bogus_NightmareDemonBlur", flags: SXF_TRANSFERSPRITEFRAME|SXF_NOCHECKPOSITION);
					A_SpawnItemEx("HDSmoke",random(-1,1),random(-1,1),random(4,24),vel.x,vel.y,vel.z+random(1,3),0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,0);
					A_SpawnItemEx("HDSmoke",random(-1,1),random(-1,1),random(4,24),vel.x,vel.y,vel.z+random(1,3),0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,0);
					A_SpawnItemEx("HDSmoke",random(-1,1),random(-1,1),random(4,24),vel.x,vel.y,vel.z+random(1,3),0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,0);
				}
			}
			NDEM E 0 A_PlaySound(attacksound);
			NDEM A 0 A_ChangeVelocity(random(20, 30), 0, random(5, 7), CVF_RELATIVE);
			NDEM A 0 SetStateLabel("meleewait");
			
		meleewait:
			NDEM EEEEEEEEEEEEEEEE 1
			{
				A_SpawnItemEx("Bogus_NightmareDemonBlurShort", zofs: 1, flags: SXF_TRANSFERSPRITEFRAME|SXF_NOCHECKPOSITION);
				
				if (CheckIfCloser(target, meleerange))
				{
					SetStateLabel("chomp");
				}
				
				if (vel.z < 1)
				{
					if (!random(0, 2))
					{
						SetStateLabel("lunge");
					}
				}
			}
			NDEM A 0 SetStateLabel("see");
			
		melee:
		chomp:
			NDEM E 0 A_FaceTarget(60);
			NDEM E 0 A_PlaySound("demon/melee");
			NDEM EF 3;
			// nabbed from HD's ninjapirate
			NDEM F 0
			{
				A_CustomMeleeAttack(random(1,3)*2,"misc/bulletflesh","","piercing",true);
				if(
					(target&&distance3d(target)<50)
					&&(random(0,3))
				){
					setstatelabel("latch");
				}
			}
			NDEM GGGG 0 A_CustomMeleeAttack(random(1,18),"misc/bulletflesh","","teeth",true);
			NDEM A 0 SetStateLabel("see");
			
		// nabbed from HD's ninjapirate
		latch:
			NDEM EEF 1{
				A_FaceTarget();
				A_ChangeVelocity(1,0,0,CVF_RELATIVE);
				if(!random(0,19))A_Pain();else if(!random(0,9))A_PlaySound("babuin/bite");
				if(!random(0,200)){
					A_ChangeVelocity(-1,0,0,CVF_RELATIVE);
					A_ChangeVelocity(-2,0,2,CVF_RELATIVE,AAPTR_TARGET);
					setstatelabel("see");
					return;
				}
				if(
					!target
					||target.health<1
					||distance3d(target)>50
				){
						setstatelabel("see");
						return;
				}
				A_ScaleVelocity(0.2,AAPTR_TARGET);
				A_ChangeVelocity(random(-3,3),random(-3,3),random(-3,3),0,AAPTR_TARGET);
				A_DamageTarget(random(0,5),random(0,3)?"teeth":"falling",0,"none","none",AAPTR_DEFAULT,AAPTR_DEFAULT);
			}
			NDEM F 0
			{
				if (health < 1)
				{
					SetStateLabel("death");
				}
			}
			loop;
		
		death:
			NDEM I 0
			{
				cloaked = false;
				A_Die();
				A_Scream();
			}
			NDEM IJKLM 4;
			NDEM N -1;
			stop;
			
		raise:
			NDEM NMLKJI 6;
			goto checkraise;
		// the following are taken from HD
		ungib:
			TROO U 6{
				cloaked=false;
				if(alpha<1.){
					A_SetTranslucent(1);
					A_SpawnItemEx("HDSmoke",random(-1,1),random(-1,1),random(4,24),vel.x,vel.y,vel.z+random(1,3),0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,0);
				}
				A_SpawnItemEx("MegaBloodSplatter",0,0,4,
					vel.x,vel.y,vel.z+3,0,
					SXF_NOCHECKPOSITION|SXF_ABSOLUTEMOMENTUM
				);
			}
			TROO UT 8;
			TROO SRQ 6;
			TROO PO 4;
			goto checkraise;
		gib:
			NDEM I 0
			{
				cloaked = false;
				A_Die();
			}
			TROO O 0 A_XScream();
			TROO O 0 A_NoBlocking();
			TROO OPQ 4 spawn("MegaBloodSplatter",pos+(0,0,34),ALLOW_REPLACE);
			TROO RST 4;
			TROO U -1;
			stop;
	}
}

class Bogus_NightmareDemonBlur : actor
{
	default
	{
		renderstyle "normal";
		+nointeraction;
	}
	
	states
	{
		spawn:
			NDEM # 8 A_FadeOut(frandom(0.01, 0.05));
			loop;
	}
}

class Bogus_NightmareDemonBlurShort : Bogus_NightmareDemonBlur
{
	states
	{
		spawn:
			NDEM # 1 A_FadeOut(frandom(0.01, 0.05));
			loop;
	}
}