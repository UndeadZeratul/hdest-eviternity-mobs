// ================================================================================================
// any cacodemon born after 1993 can't cook... 
// all they know is thy fries consumed, charge they astral orb, 
// float, be demon, eat marine & die
// ================================================================================================

class Bogus_AstralCacodemon : HDMobBase
{
	OrbCharge chargethingy;
	
	int chargemode;
	// 0: not charging
	// 1: charging
	// 2: fucked up
	
	default
	{
		health 400;
		hdmobbase.shields 500;
		radius 24;
		height 48;
		mass 400;
		
		+float 
		+nogravity
		
		seesound "astral/sight";
		painsound "astral/pain";
		deathsound "astral/death";
		activesound "astral/active";
		meleesound "astral/melee";
		
		tag "$TAG_ASTRALCACO";
		bloodcolor "22 22 22";

		+pushable
		pushfactor 0.05;
		painchance 90;
		deathheight 29;
		damagefactor "SmallArms0", 0.8;
		damagefactor "SmallArms1", 0.9;
		damagefactor "Thermal", 0;
		damagefactor "Electro", 0;
		obituary "$OB_ASTRALCACO";
		hitobituary "$OB_HIT_ASTRALCACO";
		speed 12;
		maxtargetrange 8192;
		meleethreshold 128;
	}
	
	override void beginplay()
	{
		super.beginplay();
		
		Resize(0.9, 1.3);

		speed *= 3. - 2 * scale.x;
		meleethreshold = 0;
		chargemode = 0;
	}
	
	states
	{
		spawn:
			ACAC A 10
			{
				A_HDLook();
				
				if (!bambush && !random(0, 10)) A_HDWander();
			}
			wait;
			
		see:
			ACAC A 4
			{
				A_HDChase();
				chargemode = 0;
			}
			loop;
			
		pain:
			ACAC H 0
			{
				chargemode = 2;
			}
			ACAC H 2
			{					
				vel.z -= frandom(0.4, 1.4);
			}
			ACAC H 6 A_Pain();
			ACAC H 3;
			---- H 0 SetStateLabel("see");
			
		missile:
			ACAC A 0 A_JumpIfTargetInLOS("shoot", 10);
			ACAC A 0 A_JumpIfTargetInLOS(2, flags: JLOSF_DEADNOJUMP);
			---- A 0 SetStateLabel("see");
			ACAC A 3 A_FaceTarget(40, 40, flags: FAF_MIDDLE);
			loop;
			
		shoot:
			ACAC A 0 A_JumpIfCloser(radius + 1024, "nyoom");
			ACAC A 0 SetStateLabel("fireball");
			
		aimedfireball:
			ACAC F 0 A_FaceTarget(40, 40, flags: FAF_TOP);
			
		fireball:
			ACAC F 4 A_FaceTarget(20, 20, flags: FAF_TOP);
			ACAC G 4
			{
				A_SpawnItemEx(
					"astraljuice", 0, 0, 24,
					cos(pitch) * 36, 0, -sin(pitch) * 27,
					flags:SXF_NOCHECKPOSITION|SXF_SETTARGET|SXF_TRANSFERPITCH
				);
			}
			ACAC F 4;
			---- F 0 SetStateLabel("orbtime");
			
		nyoom:
			ACAC A 0 A_ChangeVelocity(frandom(5, 7) * randompick(-1, 1),
				frandom(10, 15) * randompick(-1, 1), frandom(1, 3) * randompick(-1, 1), flags: CVF_RELATIVE);
			ACAC A 20;
			ACAC A 0 A_JumpIfCloser(radius + 640, "doublefireball");
			ACAC A 0 A_JumpIfTargetInLOS("aimedfireball");
			ACAC A 0 SetStateLabel("fireball");
			
		doublefireball:
			ACAC F 4;
			ACAC F 0 A_FaceTarget(80, 40, flags: FAF_TOP);
			ACAC G 4 bright
			{
				A_SpawnItemEx("HDSmoke",random(16, 32),random(-12,12),18,random(2,4),flags:SXF_NOCHECKPOSITION);
				A_SpawnItemEx("HDSmoke",random(16, 32),random(-12,12),18,random(2,4),flags:SXF_NOCHECKPOSITION);
				A_SpawnItemEx("HDSmoke",random(16, 32),random(-12,12),18,random(2,4),flags:SXF_NOCHECKPOSITION);
				
				A_SpawnItemEx(
					"astraljuice", 0, 0, 24,
					cos(pitch) * 14, frandom(2, 4), -sin(pitch) * random(12, 16),
					flags:SXF_NOCHECKPOSITION|SXF_SETTARGET|SXF_TRANSFERPITCH
				);
				
				A_SpawnItemEx(
					"astraljuice", 0, 0, 24,
					cos(pitch) * 14, frandom(-4, -2), -sin(pitch) * random(10, 12),
					flags:SXF_NOCHECKPOSITION|SXF_SETTARGET|SXF_TRANSFERPITCH
				);
			}
			ACAC F 4;
			---- F 0 SetStateLabel("orbtime");
			
		regularball2:
			ACAC F 4
			{
				A_FaceTarget(40, 40, flags: FAF_MIDDLE);
				chargemode = 0;
			}
			ACAC G 4 bright A_SpawnProjectile("AstralNormalBall",flags:CMF_AIMDIRECTION,pitch);
			ACAC FA 4;
			
		regularball:
			ACAC F 4
			{
				A_FaceTarget(40, 40, flags: FAF_MIDDLE);
				chargemode = 0;
			}
			ACAC G 4 bright A_SpawnProjectile("AstralNormalBall",flags:CMF_AIMDIRECTION,pitch);
			ACAC F 4;
			---- F 0 SetStateLabel("see");
			
		orbtime:
			ACAC F 0 A_JumpIfCloser(radius + 384, "regularball");
			ACAC F 0
			{
				chargemode = 1;
				chargethingy = OrbCharge(Spawn("OrbCharge"));
				chargethingy.bigboy = self;
			}
			ACAC FFFF 4
			{
				vel.x /= 1.5;
				vel.y /= 1.5;
				vel.z /= 1.5;
			}
			
			
		chargebegin:
			ACAC F 4
			{
				if (chargethingy != null)
				{
					if (chargethingy.chargelevel > 1.5)
					{
						SetStateLabel("chargemiddle");
					}
				}
				else
				{
					SetStateLabel("see");
				}
				
				A_FaceTarget(40, 40, flags: FAF_MIDDLE);
			}
			loop;
			
		chargemiddle:
			ACAC GGGGGGGG 4 bright 
			{
				A_FaceTarget(10, 10, flags: FAF_MIDDLE);
				
				if (CheckIfCloser(target, radius + 512))
				{
					SetStateLabel("regularball2");
				}
			}
			ACAC GGGG 4 bright A_FaceTarget(4, 4, flags: FAF_MIDDLE);
			ACAC G 0 A_JumpIfCloser(radius + 1536, "discharge");
			ACAC GGGG 4 bright A_FaceTarget(3, 3, flags: FAF_MIDDLE);
			ACAC G 0 A_JumpIfCloser(radius + 2048, "discharge");
			ACAC GGGG 4 bright A_FaceTarget(2, 2, flags: FAF_MIDDLE);
			ACAC G 0 A_JumpIfCloser(radius + 2560, "discharge");
			ACAC GGGG 4 bright A_FaceTarget(1, 1, flags: FAF_MIDDLE);
			
		discharge:
			ACAC G 0 bright A_FaceTarget(10, 10, flags: FAF_BOTTOM);
			ACAC G 4 bright
			{
				bool dumb;
				actor alsodumb;
				
				[dumb, alsodumb] = A_SpawnItemEx(
					"astralorb", 0, -1, 24,
					cos(pitch) * 14 * chargethingy.chargelevel,
					0, -sin(pitch) * 12 * chargethingy.chargelevel,
					flags:SXF_NOCHECKPOSITION|SXF_SETTARGET|SXF_TRANSFERPITCH
				);
				
				AstralOrb superdumb = AstralOrb(alsodumb);
				superdumb.power = chargethingy.chargelevel / 1.5;
				
				chargethingy.SetStateLabel("lol");
				
				A_ChangeVelocity(frandom(1, 3) * superdumb.power * -1,
					frandom(0, 1) * randompick(-1, 1),
					flags: CVF_RELATIVE);
			}			
			ACAC FFFFFFFF 4 A_SpawnItemEx("HDSmoke",random(16, 32),random(-12,12),18,random(2,4),flags:SXF_NOCHECKPOSITION);
			ACAC FFFFFFFF 4
			{
				A_SpawnItemEx("HDSmoke",random(16, 32),random(-12,12),18,random(2,4),flags:SXF_NOCHECKPOSITION);
				A_Chase();
			}
			---- F 0 SetStateLabel("see");
			
		melee:
			ACAC FG 3 A_FaceTarget();
			ACAC F 3 A_CustomMeleeAttack(random(30, 50),meleesound,"","teeth",true);
			ACAC AAAA 2 
			{
				A_FaceTarget(15, 15);
				A_ChangeVelocity(frandom(3, 5), flags: CVF_RELATIVE);
			}
			ACAC FG 3 A_FaceTarget();
			ACAC F 3 A_CustomMeleeAttack(random(30, 50),meleesound,"","teeth",true);
			ACAC A 3;
			---- A 0 SetStateLabel("see");
			
		death:
			ACAC J 2 
			{
				bfloatbob = false;
				bnogravity = false;
				bfloat = false;
				A_PlaySound(seesound, CHAN_VOICE);
			}
			ACAC KLM 2;
			ACAC N 2 A_JumpIf(vel.z >= 0, "deadsplatting");
			wait;
			
		deadsplatting:
			ACAC O 4 A_Scream();
			ACAC PQR 4;
			---- R 0 SetStateLabel("dead");
			
		dead:
			ACAC S -1;
			stop;
		
		raise:
			ACAC S 8 A_UnSetFloorClip;
			ACAC SRQPONMLKJ 8;
			goto checkraise;
	}
}

enum ASTRALCACONUMS
{
	ASTRALCACO_MAXHEALTH = 400,
}

class OrbCharge : HDActor
{
	bogus_astralcacodemon bigboy;
	property bigboy : bigboy;
	
	float chargelevel;
	property chargelevel : chargelevel;
	
	bool letsdothis;
	
	
	default
	{
		+nointeraction
		+forcexybillboard
		
		renderstyle "add";
		OrbCharge.chargelevel 1;
		alpha 0;
	}
	
	override void postbeginplay()
	{
		super.postbeginplay();
		
		letsdothis = true;
	}
	
	override void tick()
	{
		super.tick();
		if (!bNoTimeFreeze && isFrozen())
			return;
		
		if (letsdothis)
		{
			if (bigboy != null)
			{
				warp(bigboy, bigboy.radius, -1, (bigboy.height / 2) - 3, flags: WARPF_INTERPOLATE|WARPF_NOCHECKPOSITION);
				if (bigboy.health > 0)
				{
					chargelevel += frandom(0.03, 0.05);
				}
				else
				{
					letsdothis = false;
				}
			}
		}
	}
	
	states
	{
		spawn:
			BAL2 AB 3 
			{
				scale = ((chargelevel / 5) + 1.5, (chargelevel / 5) + 1.5);
				alpha = (chargelevel / 10) + 0.5;
				
				roll += 10;
				scale.x *= randompick(-1, 1);
				
				if (bigboy != null)
				{
					if (!letsdothis || bigboy.chargemode != 1)
					{
						if (bigboy.chargemode == 2)
						{
							AstralOrb ohno = AstralOrb(spawn("astralorb"));
							ohno.power = chargelevel;
							ohno.doexplode = false;
							ohno.warp(bigboy, bigboy.radius, flags: WARPF_NOCHECKPOSITION);
							ohno.setstatelabel("death");
							
							bigboy.chargemode = 0;
							letsdothis = false;
						}
						
						scale = (1, 1);
						SetStateLabel("death");
					}
				}
			}
			---- A 0 A_PlaySound("astralorb/charge", CHAN_BODY, attenuation: 1);
			loop;
			
		death:
			BAL2 CDE 3 A_PlaySound("misc/fwoosh", CHAN_BODY);
			stop;
			
		lol:
			ASBL A 0
			{
				scale = (1, 1);
				alpha = 5 * chargelevel; //make bloom go crazy
				A_PlaySound("astralorb/kaboom", volume: 2.0, attenuation: 0.5 - (chargelevel / 10));
				letsdothis = false;
			}
			ASBL ABCDEF 3;
			stop;
	}
}

class AstralOrbTrail : HDFireballTail
{
	default
	{
		renderstyle "add";
		deathheight 0.9;
		gravity 0; 
		scale 0.6;
	}
	
	states
	{
		spawn:
			BAL2 CDE 2
			{
				roll += 10;
				scale.x *= randompick(-1, 1);
			}
			loop;
	}
}

class AstralOrb : HDFireball
{
	float power;
	property power : power;
	
	bool doexplode;
	property doexplode : doexplode;
	
	default
	{
		missiletype "AstralOrbTrail";
		damagetype "electro";
		activesound "astralorb/charge";
		decal "scorch";
		gravity 0;
		speed 25;
		
		radius 8;
		height 8;
		
		AstralOrb.power 1;
		AstralOrb.doexplode true;
	}
	
	override void postbeginplay()
	{
		scale = ((power / 3) + 1.5, (power / 3) + 1.5);
	}
	
	states
	{
		spawn:
			BAL2 A 0;
			BAL2 AAABBBAAABBB 1 A_FBTail();
			
		spawn2: 
			BAL2 AB 3 A_FBFloat();
			loop;
			
		death:
			BAL2 C 0
			{
				A_SprayDecal("Scorch",16);
				
				
				int foob = 32 * power;
				
				actor xpl=spawn("Gyrosploder",pos-(random(-2, 2),random(-2, 2),random(-2, 2)),ALLOW_REPLACE);
					xpl.target=target;xpl.master=master;xpl.stamina=stamina;
					
				for (int i = 0; i < power; i++)
				{
					if (doexplode)
					{
						A_HDBlast(
							pushradius:256,pushamount:128,fullpushradius:96,
							fragradius:128,fragtype:"HDB_fragRL",
							immolateradius:128,immolateamount:random(3,60),
							immolatechance:25
						);
					}
					
					actor ltt = spawn("AstralLingeringThunder",pos,ALLOW_REPLACE);
					ltt.target = target;
					ltt.stamina = foob;
				}
				
				if (!doexplode)
				{
					A_Explode(random(10,30),random(50,70),0);
					A_Quake(2,48,0,24,"");
				}
			}
			BAL2 CDE 4;
			stop;
	}
}

class AstralJuice : manjuice
{
	states
	{
		spawn:
			MANF A 0 
			{
				actor mjl = spawn("manjuicelight", pos + (0, 0, 16), ALLOW_REPLACE);
				mjl.target = self;
			}
			MANF AABBAABB 1 A_FBTail();	
			MANF A 0 SetStateLabel("spawn2");
	}
}

class AstralLingeringThunder : LingeringThunder
{
	default
	{
		stamina 128;
	}
}

//dont zap urself lmao
class AstralNormalBall:HDFireball{
	default{
		height 12;radius 12;
		gravity 0;
		decal "BulletScratch";
		damagefunction(random(20,40));
	}
	void ZapSomething(){
		roll=frandom(0,360);
		A_PlaySound("misc/arczap",CHAN_BODY);
		blockthingsiterator it=blockthingsiterator.create(self,72);
		actor tb=target;
		actor zit=null;
		while(it.next()){
			if(
				it.thing.bshootable
			){
				zit=it.thing;
				A_Face(zit,0,0,flags:FAF_MIDDLE);
				if(
					zit.health>0
					&&checksight(it.thing)
					&&(
						!tb
						||zit==tb.target
						||!(zit is "bogus_astralcacodemon")
					)
				){
					zit.damagemobj(self,tb,random(0,7),"Electro");
				}
				break;
			}
		}
		if(!zit||zit==tb){pitch=frandom(-90,90);angle=frandom(0,360);}
		A_CustomRailgun(
			(0),0,"","e0 df ff",
			RGF_SILENT|RGF_NOPIERCING|RGF_FULLBRIGHT|RGF_CENTERZ|RGF_NORANDOMPUFFZ,
			0,4000,"FoofPuff",range:128,6,0.8,1.5
		);
		A_FaceTracer(4,4);
		if(pos.z-floorz<24)vel.z+=0.3;
	}
	states{
	spawn:
		BAL2 A 0 ZapSomething();
		BAL2 AB 2 light("PLAZMABX1") A_Corkscrew();
		loop;
	death:
		BAL2 C 0 A_SprayDecal("CacoScorch",radius*2);
		BAL2 C 0 A_PlaySound("misc/fwoosh",5);
		BAL2 CCCDDDEEE 1 light("BAKAPOST1") ZapSomething();
	death2:
		BAL2 E 0 ZapSomething();
		BAL2 E 3 light("PLAZMABX2") A_FadeOut(0.3);
		loop;
	}
}