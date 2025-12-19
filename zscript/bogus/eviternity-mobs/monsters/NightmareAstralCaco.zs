class Bogus_NightmareCacodemon : Bogus_AstralCacodemon {
	bool angery;

	bool cloaked;
	bool cloakfuzzy;

	OrbCharge chargethingy;
	
	int chargemode;
	// 0: not charging
	// 1: charging
	// 2: fucked up
	
	default {
		//$Category "Monsters/Hideous Destructor"
		//$Title "Nightmare Astral Cacodemon"
		//$Sprite "NACCA1"

		health 400;
		hdmobbase.shields 400;

		seesound "nightmareCaco/sight";
		painsound "nightmareCaco/pain";
		deathsound "nightmareCaco/death";
		activesound "nightmareCaco/active";
		meleesound "nightmareCaco/melee";

		tag "$TAG_NIGHTMARECACO";

		obituary "$OB_NIGHTMARECACO";
		hitobituary "$OB_HIT_NIGHTMARECACO";

		speed 18;
	}

	override void beginPlay() {
		super.beginPlay();

		cloakfuzzy = 0;
		chargemode = 0;
	}

	override void tick() {
		super.tick();

		if (!bNOTIMEFREEZE && isFrozen()) return;
			
		if (cloaked) {
			if (cloakfuzzy) {
				if (!random(0, 7)) {
					cloakfuzzy = false;

					A_SetRenderStyle(0, STYLE_None);
				}
			} else if (!random(0, 63)) {
				cloakfuzzy = true;

				A_SetRenderStyle(frandom(0.5, 0.8), STYLE_Fuzzy);
			}
		} else {
			A_SetRenderStyle(1, STYLE_Normal);
		}

		if (countInv('HDMagicShield') < 400 && !angery) {
			angery = true;

			setStateLabel("see");
		}
	}

	void Cloak(bool which = true) {
		cloaked = which;
	}

	void A_BlurWander(bool dontlook = false) {
		A_HDWander(dontlook ? 0 : CHF_LOOK);
		A_SpawnItemEx(
			"Bogus_NightmareCacodemonBlurShort",
			frandom(-2, 2), frandom(-2, 2), frandom(-2, 2),
			flags: SXF_TRANSFERSPRITEFRAME
		);
	}

	void A_BlurChase() {
		speed = getDefaultByType(getClass()).speed;

		A_HDChase();
		A_SpawnItemEx(
			"Bogus_NightmareCacodemonBlurShort",
			frandom(-2, 2), frandom(-2, 2), frandom(-2, 2),
			flags: SXF_TRANSFERSPRITEFRAME
		);
	}

	void A_CloakedChase() {
		bFRIGHTENED = health < 100;

		if (!(level.time&3)) {
			alpha = !random(0, 7);
			A_SetTranslucent(alpha, alpha ? 2 : 0);
			if (!(level.time&4)) GiveBody(1);
		}

		bSHOOTABLE = alpha || random(0, 15);
		speed = (bSHOOTABLE && alpha) ? 5 : getDefaultByType(getClass()).speed;

		A_Chase("melee", flags: CHF_NIGHTMAREFAST);

		if(
			!random(0, 15)
			&& health > 200
			&& !(target && checkSight(target))
		) {
			setStateLabel("uncloak");
		}
	}

	void A_Cloak() {
		Cloak();
		A_SpawnItemEx("Bogus_NightmareCacodemonBlur", zofs: 1, flags: SXF_TRANSFERSPRITEFRAME|SXF_NOCHECKPOSITION);
	}
	
	void A_Uncloak() {
		for (int i = 0; i < 3; i++) A_SpawnItemEx("HDSmoke",frandom(-1,1),frandom(-1,1),frandom(4,24),vel.x,vel.y,vel.z+frandom(1,3),0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,0);

		Cloak(false);
		bFRIGHTENED = false;
		bSOLID = true;
		bSHOOTABLE = true;
		bNOPAIN = false;
		bSHADOW = false;
		bNOTARGET = false;

		A_FaceTarget();
		A_StartSound(seesound);
	}
	
	states {
		spawn:
			TNT1 A 0 nodelay A_JumpIf(cloaked, "SpawnUnCloak");
		spawn2:
			TNT1 A 0 A_JumpIf(!bAMBUSH, "spawnwander");
			TNT1 A 0 A_SpawnItemEx(
				"HDSmoke", random(-1, 1), random(-1, 1), random(4, 24),
				vel.x, vel.y, vel.z + random(1,3),
				0, SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION, 0
			);
			TNT1 A 0 Cloak();
		spawnstillcloaked:
			TNT1 A 0 GiveBody(2);
			TNT1 A 10 A_HDLook();
			loop;
		spawnwander:
			NACC AAAA 10 A_BlurWander();
			TNT1 A 0 A_Jump(48, "spawnstill");
			TNT1 A 0 A_Jump(48, 1);
			loop;
			TNT1 A 0 A_Vocalize(activesound);
			TNT1 A 0 A_SpawnItemEx(
				"HDSmoke",
				random(-1,1), random(-1,1), random(4,24),
				vel.x, vel.y, vel.z + random(1, 3),
				0, SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION, 0
			);
			TNT1 A 0 A_Cloak();
		spawnwandercloaked:
			TNT1 A 0 GiveBody(2);
			TNT1 A 0 A_HDLook();
			TNT1 A 7 A_Wander();
			TNT1 A 0 A_Jump(12, 1);
			loop;
			TNT1 A 0 A_SpawnItemEx(
				"HDSmoke",
				random(-1, 1), random(-1, 1), random(4, 24),
				vel.x, vel.y, vel.z + random(1, 3),
				0, SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION, 0
			);
			TNT1 A 0 A_Uncloak();
			TNT1 A 0 A_Vocalize(activesound);
		spawnstill:
			NACC A 10 A_Jump(48, "spawnwander");
			TNT1 A 0 A_HDLook();
			NACC A 10 A_SetAngle(angle + random(-20, 20));
			NACC AAEE 10 A_HDLook();
			loop;

		spawnuncloak:
			NACC A 0 A_Uncloak();
			#### A 0 A_SetTranslucent(0,0);
			#### A 2 A_SetTranslucent(0.2);
			#### A 2 A_SetTranslucent(0.4);
			#### A 2 A_SetTranslucent(0.6);
			#### A 2 A_SetTranslucent(0.8);
			#### A 2 A_SetTranslucent(1);
		goto spawn2;

		see:
			#### A 4 {
				if (!target || target.health <= 0) angery = false;

				chargemode = 0;
				
				if (angery) {
					if (cloaked) A_Uncloak();
					
					speed = 28;
					A_HDChase();
				} else {
					if (!cloaked) A_Cloak();
					
					speed = 14;
					A_HDWander();
				}
			}
			loop;

		seerunnin:
			NACC AAAA 4 A_BlurChase();
			TNT1 A 0 Cloak(randomPick(0, 0, 0, 1));
			goto see;

		seecloaked:
			NDEM A 1 A_CloakedChase();
			loop;

		cloak:
			NACC AAA 0 A_SpawnItemEx(
				"HDSmoke",
				frandom(-1, 1), frandom(-1, 1), frandom(4, 24),
				vel.x, vel.y, vel.z + random(1, 3),
				0, SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION, 0
			);
			#### A 0 A_Cloak();
			#### A 1 A_SetTranslucent(0.8);
			#### A 1 A_SetTranslucent(0.4);
			#### A 1 A_SetTranslucent(0.2, 2);
			TNT1 AAAAA 0 A_Chase(null);
			goto see;

		uncloak:
			NACC A 0 A_Uncloak();
			#### A 0 A_SetTranslucent(0,0);
			#### A 1 A_SetTranslucent(0.2);
			#### A 1 A_SetTranslucent(0.4);
			#### A 1 A_SetTranslucent(0.6);
			#### A 1 A_SetTranslucent(0.8);
			#### A 0 A_SetTranslucent(1);
			goto see;
			
		melee:
			NACC G 0 A_JumpIf(cloaked, "uncloak");
			#### F 3 A_FaceTarget(60);
			#### E 3 A_CustomMeleeAttack(random(30, 50), meleesound, "", "teeth", true);
			#### AAAA 2 {
				A_FaceTarget(15, 15);
				A_ChangeVelocity(frandom(3, 5), flags: CVF_RELATIVE);
			}
			#### GF 3 A_FaceTarget();
			#### E 3 A_CustomMeleeAttack(random(30, 50), meleesound, "", "teeth", true);
			#### A 3;
			goto see;

		pain:
			NACC H 6 {
				if (!angery) angery = true;

				chargemode = 2;

				vel.z -= frandom(0.4, 1.4);
			}
			#### I 6 A_Pain();
			goto see;
			
		missile:
			#### A 0 A_JumpIfTargetInLOS("shoot", 10);
			#### A 0 A_JumpIfTargetInLOS(2, flags: JLOSF_DEADNOJUMP);
			goto see;
			#### A 3 A_FaceTarget(40, 40, flags: FAF_MIDDLE);
			loop;
			
		shoot:
			#### A 0 A_JumpIfCloser(radius + 1024, "nyoom");
			goto fireball;
			
		aimedfireball:
			#### F 0 A_FaceTarget(40, 40, flags: FAF_TOP);
		fireball:
			#### F 4 A_FaceTarget(20, 20, flags: FAF_TOP);
			#### G 4 A_SpawnItemEx(
				"NightmareAstralJuice",
				0, 0, 24,
				cos(pitch) * 36, 0, -sin(pitch) * 27,
				flags: SXF_NOCHECKPOSITION|SXF_SETTARGET|SXF_TRANSFERPITCH
			);
			#### F 4;
			goto orbtime;
			
		nyoom:
			#### A 0 A_ChangeVelocity(frandom(5, 7) * randompick(-1, 1),
				frandom(10, 15) * randompick(-1, 1), frandom(1, 3) * randompick(-1, 1), flags: CVF_RELATIVE);
			#### A 20;
			#### A 0 A_JumpIfCloser(radius + 640, "doublefireball");
			#### A 0 A_JumpIfTargetInLOS("aimedfireball");
			goto fireball;
			
		doublefireball:
			#### F 4;
			#### F 0 A_FaceTarget(80, 40, flags: FAF_TOP);
			#### G 4 bright {
				for (int i = 0; i < 3; i++) A_SpawnItemEx(
					"HDSmoke",
					frandom(16, 32), frandom(-12, 12), frandom(2, 4),
					flags: SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION
				);
				
				A_SpawnItemEx(
					"AstralJuice",
					0, 0, 24,
					cos(pitch) * 14, frandom(2, 4), -sin(pitch) * random(12, 16),
					flags: SXF_NOCHECKPOSITION|SXF_SETTARGET|SXF_TRANSFERPITCH
				);
				
				A_SpawnItemEx(
					"AstralJuice",
					0, 0, 24,
					cos(pitch) * 14, frandom(-4, -2), -sin(pitch) * random(10, 12),
					flags: SXF_NOCHECKPOSITION|SXF_SETTARGET|SXF_TRANSFERPITCH
				);
			}
			#### F 4;
			goto orbtime;
			
		regularball2:
			NACC F 4 {
				chargemode = 0;
				A_FaceTarget(40, 40, flags: FAF_MIDDLE);
			}
			#### G 4 bright A_SpawnProjectile("AstralNormalBall",flags:CMF_AIMDIRECTION,pitch);
			#### FA 4;
		regularball:
			NACC F 4 {
				chargemode = 0;
				A_FaceTarget(40, 40, flags: FAF_MIDDLE);
			}
			#### G 4 bright A_SpawnProjectile("AstralNormalBall",flags:CMF_AIMDIRECTION,pitch);
			#### F 4;
			goto see;
			
		orbtime:
			NACC F 0 A_JumpIfCloser(radius + 384, "regularball");
			#### F 0 {
				chargemode = 1;
				chargethingy = OrbCharge(Spawn("OrbCharge"));
				chargethingy.bigboy = self;
			}
			#### FFFF 4 {
				vel.x /= 1.5;
				vel.y /= 1.5;
				vel.z /= 1.5;
			}
		chargebegin:
			#### F 0 A_JumpIf(!chargethingy, "see");
			#### F 0 A_JumpIf(chargethingy.chargelevel > 1.5, "chargemiddle");
			#### F 4 A_FaceTarget(40, 40, flags: FAF_MIDDLE);
			loop;
			
		chargemiddle:
			#### GGGGGGGG 4 bright  {
				A_FaceTarget(10, 10, flags: FAF_MIDDLE);
				
				if (CheckIfCloser(target, radius + 512)) {
					SetStateLabel("regularball2");
				}
			}
			#### GGGG 4 bright A_FaceTarget(4, 4, flags: FAF_MIDDLE);
			#### G 0 A_JumpIfCloser(radius + 1536, "discharge");
			#### GGGG 4 bright A_FaceTarget(3, 3, flags: FAF_MIDDLE);
			#### G 0 A_JumpIfCloser(radius + 2048, "discharge");
			#### GGGG 4 bright A_FaceTarget(2, 2, flags: FAF_MIDDLE);
			#### G 0 A_JumpIfCloser(radius + 2560, "discharge");
			#### GGGG 4 bright A_FaceTarget(1, 1, flags: FAF_MIDDLE);
		discharge:
			#### G 0 bright A_FaceTarget(10, 10, flags: FAF_BOTTOM);
			#### G 4 bright {
				bool dumb;
				Actor alsodumb;
				
				[dumb, alsodumb] = A_SpawnItemEx(
					"AstralOrb", 0, -1, 24,
					cos(pitch) * 14 * chargethingy.chargelevel,
					0, -sin(pitch) * 12 * chargethingy.chargelevel,
					flags:SXF_NOCHECKPOSITION|SXF_SETTARGET|SXF_TRANSFERPITCH
				);
				
				AstralOrb superdumb = AstralOrb(alsodumb);
				superdumb.power = chargethingy.chargelevel / 1.5;
				
				chargethingy.SetStateLabel("lol");
				
				A_ChangeVelocity(
					frandom(1, 3) * superdumb.power * -1,
					frandom(0, 1) * randompick(-1, 1),
					flags: CVF_RELATIVE
				);
			}			
			#### FFFFFFFF 4 A_SpawnItemEx("HDSmoke",random(16, 32),random(-12,12),18,random(2,4),flags:SXF_NOCHECKPOSITION);
			#### FFFFFFFF 4 {
				A_SpawnItemEx("HDSmoke",random(16, 32),random(-12,12),18,random(2,4),flags:SXF_NOCHECKPOSITION);
				A_Chase();
			}
			goto see;
			
		death:
		gib:
			#### A 0 A_SpawnItemEx(
				"BFGNecroShard",
				0, 0, 0,
				0, 0, 5,
				0, SXF_TRANSFERPOINTERS|SXF_SETMASTER, 196
			);
			#### A 0 A_Jump(128, 2);
			#### A 0 A_JumpIf(cloaked, "DeathCloaked");
			NACC JJJ 0 A_SpawnItemEx(
				"HDSmoke",
				random(-1, 1), random(-1, 1), random(4, 24),
				vel.x, vel.y, vel.z + random(1, 3),
				0, SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION, 0
			);
			#### J 2 {
				bFLOATBOB = false;
				bNOGRAVITY = false;
				bFLOAT = false;
				A_Vocalize(seesound);
			}
			#### KLM 2;
			#### N 2 A_JumpIf (vel.z >= 0, "deadsplatting");
			wait;
			
		deadsplatting:
			#### O 0 A_SetTranslucent(1);
			#### O 4 A_Scream();
			#### P 4;
			#### Q 4;
			#### R 4 A_NoBlocking();
		dead:
		gibbed:
		death.spawndead:
			TNT1 A 0 A_FadeIn(0.01);
			NACC R 3 canraise A_JumpIf(floorz > pos.z - 6, 1);
			loop;
			NACC R 5 canraise A_JumpIf(floorz <= pos.z - 6, "dead");
			loop;
		deathcloaked:
			TNT1 A 20 A_SetTranslucent(1);
			TNT1 A 4 A_NoBlocking;
			TNT1 A 4 A_SetTranslucent(0, 0);
			NACC S 350 A_SetTics(random(10, 15) * 35);
			goto dead;
			NACC SSSSSSSSSS 20 A_FadeIn(0.1);
			NACC S -1;
			stop;
		
		raise:
		ungib:
			NACC S 4 A_SetTranslucent(1, 0);
			TNT1 A 0 A_JumpIf(cloaked, "raisecloaked");
			NACC S 8 A_UnSetFloorClip();
			#### RQPONMLKJ 8;
			goto see;

		raisecloaked:
			TNT1 AAA 0 A_SpawnItemEx(
				"HDSmoke",
				random(-1, 1), random(-1, 1), random(4, 24),
				vel.x, vel.y, vel.z + random(1, 3),
				0, SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION, 0
			);
			NACC SSSSSS 4 A_FadeOut(0.15);
			TNT1 A 0 A_SetTranslucent(0, 0);
			goto see;
	}
}

class Bogus_NightmareCacodemonBlur : actor
{
	default {
		renderstyle "normal";
		+nointeraction;
	}
	
	states {
		spawn:
			NACC # 8 A_FadeOut(frandom(0.01, 0.05));
			loop;
	}
}

class Bogus_NightmareCacodemonBlurShort : Bogus_NightmareCacodemonBlur
{
	states {
		spawn:
			NACC # 1 A_FadeOut(frandom(0.01, 0.05));
			loop;
	}
}

class OrbCharge : HDActor {
	Bogus_NightmareCacodemon bigboy;
	property bigboy : bigboy;
	
	float chargelevel;
	property chargelevel : chargelevel;
	
	bool letsdothis;
	
	
	default {
		+nointeraction
		+forcexybillboard
		
		renderstyle "add";
		OrbCharge.chargelevel 1;
		alpha 0;
	}
	
	override void postbeginplay() {
		super.postbeginplay();
		
		letsdothis = true;
	}
	
	override void tick() {
		super.tick();
		if (!bNoTimeFreeze && isFrozen())
			return;
		
		if (letsdothis) {
			if (bigboy != null) {
				warp(bigboy, bigboy.radius, -1, (bigboy.height / 2) - 3, flags: WARPF_INTERPOLATE|WARPF_NOCHECKPOSITION);
				if (bigboy.health > 0) {
					chargelevel += frandom(0.03, 0.05);
				}
				else {
					letsdothis = false;
				}
			}
		}
	}
	
	states {
		spawn:
			BAL2 AB 3  {
				scale = ((chargelevel / 5) + 1.5, (chargelevel / 5) + 1.5);
				alpha = (chargelevel / 10) + 0.5;
				
				roll += 10;
				scale.x *= randompick(-1, 1);
				
				if (bigboy != null) {
					if (!letsdothis || bigboy.chargemode != 1) {
						if (bigboy.chargemode == 2) {
							AstralOrb ohno = AstralOrb(spawn("AstralOrb"));
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
			#### A 0 A_StartSound("AstralOrb/charge", attenuation: 1);
			loop;
			
		death:
			#### CDE 3 A_StartSound("misc/fwoosh");
			stop;
			
		lol:
			ASBL A 0 {
				scale = (1, 1);
				alpha = 5 * chargelevel; //make bloom go crazy
				A_StartSound("AstralOrb/kaboom", attenuation: 0.5 - (chargelevel / 10));
				letsdothis = false;
			}
			ASBL ABCDEF 3;
			stop;
	}
}

class AstralOrbTrail : HDFireballTail {
	default {
		renderstyle "add";
		deathheight 0.9;
		gravity 0; 
		scale 0.6;
	}
	
	states {
		spawn:
			NCCF FEDCBMN 2 {
				roll += 10;
				scale.x *= randompick(-1, 1);
			}
			loop;
	}
}

class AstralOrb : HDFireball {
	float power;
	property power : power;
	
	bool doexplode;
	property doexplode : doexplode;
	
	default {
		missiletype "AstralOrbTrail";
		damagetype "electro";
		activesound "AstralOrb/charge";
		decal "scorch";
		gravity 0;
		speed 25;
		
		radius 8;
		height 8;
		
		AstralOrb.power 1;
		AstralOrb.doexplode true;
	}
	
	override void postbeginplay() {
		super.postBeginPlay();

		scale = ((power / 3) + 1.5, (power / 3) + 1.5);
	}
	
	states {
		spawn:
			NCCF AAAAAAAAAAAA 1 A_FBTail();
			
		spawn2: 
			NCCF A 3 A_FBFloat();
			loop;
			
		death:
			NCCF G 0 {
				A_SprayDecal("Scorch",16);

				int foob = 32 * power;

				actor xpl = spawn(
					"Gyrosploder",
					pos - (random(-2, 2), random(-2, 2), random(-2, 2)),
					ALLOW_REPLACE
				);

				xpl.target = target;
				xpl.master = master;
				xpl.stamina = stamina;

				for (int i = 0; i < power; i++) {
					if (doexplode) {
						A_HDBlast(
							pushradius: 256,
							pushamount: 128,
							fullpushradius: 96,
							fragradius: 128,
							fragtype: "HDB_fragRL",
							immolateradius: 128,
							immolateamount: random(3,60),
							immolatechance: 25
						);
					}
					
					actor ltt = spawn("AstralLingeringThunder",pos,ALLOW_REPLACE);
					ltt.target = target;
					ltt.stamina = foob;
				}
				
				if (!doexplode) {
					A_Explode(random(10,30),random(50,70),0);
					A_Quake(2,48,0,24,"");
				}
			}
			NCCF GHIJKL 4;
			stop;
	}
}

class AstralLingeringThunder : LingeringThunder {
	default {
		stamina 128;
	}
}

class NightmareAstralJuice : AstralJuice {
	states {
		spawn:
			NCFB A 0 {
				spawn("manjuicelight", pos + (0, 0, 16), ALLOW_REPLACE).target = self;
			}
			#### AAAAAAAA 1 A_FBTail();
		spawn2:
			#### A 4 A_FBFloat();
			loop;

		death:
			#### G 0 {
				vel.z += 1.0;
				A_HDBlast(
					128, 66, 16,
					"hot",
					immolateradius: 48,
					random(20, 90),
					42,
					false
				);
				A_SpawnChunks("HDSmokeChunk", random(2, 4), 6, 20);
				A_StartSound("misc/fwoosh",CHAN_WEAPON);
				scale = (0.9 * randomPick(-1, 1), 0.9);
			}
			#### GGHH 1 {
				vel.z += 0.5;
				scale *= 1.05;
			}
			#### IIJJKKLL 1 {
				alpha -= 0.15;
				scale *= 1.01;
			}
			TNT1 A 0 {
				A_Immolate(tracer,target,80,requireSight:true);
				addz(-20);
			}
			TNT1 AAAAAAAAAAAAAAA 4 {
				if (tracer) {
					setOrigin((tracer.pos.xy, tracer.pos.z + frandom(0.1, tracer.height * 0.4)), false);
					vel = tracer.vel;
				}

				A_SpawnItemEx(
					"HDSmoke",
					frandom(-2, 2), frandom(-2, 2), frandom(0,2),
					vel.x + frandom(2, -4), vel.y + frandom(-2, 2), vel.z + frandom(1, 4),
					0,
					SXF_NOCHECKPOSITION|SXF_ABSOLUTEMOMENTUM
				);
			}
			stop;
	}
}
