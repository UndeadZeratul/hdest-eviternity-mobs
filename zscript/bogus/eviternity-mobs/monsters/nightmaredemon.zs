// ================================================================
// I'm gonna say the N word. Ni-
//
// -ghtmare.
// ================================================================

class Bogus_NightmareDemon : NinjaPirate {
	bool angery;
	bool cloakfuzzy;
	
	default {
		//$Category "Monsters/Hideous Destructor"
		//$Title "Nightmare Demon"
		//$Sprite "NDEMA1"

		translation 0;
		hdmobbase.shields 240;
		health 300;
		painchance 100;

		seesound "nightmareDemon/sight";
		painsound "nightmareDemon/pain";
		deathsound "nightmareDemon/death";
		activesound "nightmareDemon/active";
		meleesound "nightmareDemon/melee";

		tag "$TAG_NIGHTMAREDEMON";
		bloodcolor "08 eb cc";

		maxdropoffheight 48;
		maxstepheight 48;
		damagefactor "Balefire", 0.1;
		obituary "$OB_NIGHTMAREDEMON";
		speed 8;
	}
	
	override void PostBeginPlay() {
		super.PostBeginPlay();

		cloakfuzzy = false;
		bBIPED = true;
		bONLYSCREAMONDEATH = true;

		translation = 0;
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

		if (countInv('HDMagicShield') < 240 && !angery) {
			angery = true;

			setStateLabel("see");
		}
	}

	void A_BlurWander(bool dontlook = false) {
		A_HDWander(dontlook ? 0 : CHF_LOOK);
		A_SpawnItemEx(
			"Bogus_NightmareDemonBlurShort",
			frandom(-2, 2), frandom(-2, 2), frandom(-2, 2),
			flags: SXF_TRANSFERSPRITEFRAME
		);
	}

	void A_BlurChase() {
		speed = getDefaultByType(getClass()).speed;

		A_HDChase();
		A_SpawnItemEx(
			"Bogus_NightmareDemonBlurShort",
			frandom(-2, 2), frandom(-2, 2), frandom(-2, 2),
			flags: SXF_TRANSFERSPRITEFRAME
		);
	}

	void A_CloakedChase() {
		bFRIGHTENED = health < 90;
		frame = (level.time&(1|2|4|8)) >> 2;

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
			&& health > 160
			&& !(target && checkSight(target))
		) {
			setStateLabel("uncloak");
		}
	}

	void A_Cloak() {
		Cloak();
		A_SpawnItemEx("Bogus_NightmareDemonBlur", zofs: 1, flags: SXF_TRANSFERSPRITEFRAME|SXF_NOCHECKPOSITION);
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
			NDEM ABCD 8 A_BlurWander();
			TNT1 A 0 A_Jump(48, "spawnstill");
			TNT1 A 0 A_Jump(48, 1);
			loop;
			TNT1 A 0 A_StartSound(activesound, CHAN_VOICE);
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
			TNT1 A 0 A_StartSound("nightmaredemon/active", CHAN_VOICE);
		spawnstill:
			NDEM E 10 A_Jump(48, "spawnwander");
			TNT1 A 0 A_HDLook();
			NDEM E 10 A_SetAngle(angle + random(-20, 20));
			NDEM EEFF 10 A_HDLook();
			loop;

		spawnuncloak:
			NDEM G 0 A_Uncloak();
			#### B 0 A_SetTranslucent(0,0);
			#### B 2 A_SetTranslucent(0.2);
			#### B 2 A_SetTranslucent(0.4);
			#### B 2 A_SetTranslucent(0.6);
			#### B 2 A_SetTranslucent(0.8);
			#### B 2 A_SetTranslucent(1);
			goto spawn2;

		see:
			#### A 0 {
				if (!target || target.health <= 0) angery = false;

				if (angery) {
					if (cloaked) A_Uncloak();
					
					speed = 28;
					setStateLabel("chase");
				} else {
					if (!cloaked) A_Cloak();
					
					speed = 14;
					setStateLabel("notice");
				}
			}
		seerunnin:
			NDEM ABCD 4 A_BlurChase();
			TNT1 A 0 Cloak(randomPick(0, 0, 0, 1));
			goto see;

		seecloaked:
			NDEM A 1 A_CloakedChase();
			loop;

		cloak:
			NDEM GGG 0 A_SpawnItemEx(
				"HDSmoke",
				frandom(-1, 1), frandom(-1, 1), frandom(4, 24),
				vel.x, vel.y, vel.z + random(1, 3),
				0, SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION, 0
			);
			#### G 0 A_Cloak();
			#### G 1 A_SetTranslucent(0.8);
			#### G 1 A_SetTranslucent(0.4);
			#### G 1 A_SetTranslucent(0.2, 2);
			TNT1 AAAAA 0 A_Chase(null);
			goto see;

		uncloak:
			NDEM G 0 A_Uncloak();
			#### G 0 A_SetTranslucent(0,0);
			#### G 1 A_SetTranslucent(0.2);
			#### G 1 A_SetTranslucent(0.4);
			#### G 1 A_SetTranslucent(0.6);
			#### G 1 A_SetTranslucent(0.8);
			#### G 0 A_SetTranslucent(1);
			goto see;
			
		melee:
			NDEM G 0 A_JumpIf(cloaked,"uncloak");
			#### E 0 A_FaceTarget(60);
			#### E 0 A_StartSound("demon/melee");
			#### EF 3;
			// nabbed from HD's ninjapirate
			#### F 0 {
				A_CustomMeleeAttack(random(1, 3) * 2, "misc/bulletflesh", "", "piercing", true);

				if (
					target
					&& distance3D(target) < 50
					&& checkMove(0.5 * (pos.xy + target.pos.xy), PCM_NOACTORS)
					&& random(0, 3)
				) {
					setStateLabel("latch");
				}
			}
			#### GGGG 0 A_CustomMeleeAttack(random(1, 18), "misc/bulletflesh", "", "teeth", true);
		meleeend:
			NDEM G 10;
			goto see;
			
		// nabbed from HD's ninjapirate
		latch:
			NDEM EEF 1 {
				A_FaceTarget();
				A_ChangeVelocity(1, 0, 0, CVF_RELATIVE);

				if (!random(0, 19)) {
					A_Pain();
				} else if (!random(0, 9)) {
					A_StartSound("babuin/bite");
				}

				if (!random(0, 200)) {
					A_ChangeVelocity(-1, 0, 0, CVF_RELATIVE);
					A_ChangeVelocity(-2, 0, 2, CVF_RELATIVE, AAPTR_TARGET);

					setStateLabel("see");
					return;
				}

				if (
					!target
					|| target.health < 1
					|| distance3D(target) > 50
				) {
					setStateLabel("meleeend");
					return;
				}

				A_ScaleVelocity(0.2, AAPTR_TARGET);
				A_ChangeVelocity(random(-3, 3), random(-3, 3), random(-3, 3), 0, AAPTR_TARGET);
				A_DamageTarget(
					random(0, 5),
					random(0, 3) ? "teeth" : "falling",
					0, "none", "none",
					AAPTR_DEFAULT,
					AAPTR_DEFAULT
				);

				if (health < 1) setStateLabel("death");
			}
			loop;
			
		pain:
			NDEM H 2 {
				if (!angery) angery = true;
			}
			#### H 2 A_Pain();
			goto see;

		notice:
			NDEM ABCD 8 {
				A_HDChase();

				if (
					!random(0, 3)
					&& CheckIfCloser(target, radius + 512)
					&& A_JumpIfTargetInLOS("lunge")
				) {
					A_FaceTarget();
					setStateLabel("lunge");
				}
			}
			loop;
			
		chase:
			NDEM ABCD 4
			{
				A_HDChase();

				if (
					!random(0, 3)
					&& CheckIfCloser(target, radius + 256)
					&& A_JumpIfTargetInLOS("lunge")
				) {
					setStateLabel("lunge");
				} else if (
					!random(0, 31)
					&& A_JumpIfTargetInLOS("lunge")
				) {
					setStateLabel("lunge");
				}
			}
			loop;

		lunge:
			NDEM ABCD 4 {
				A_HDChase();

				if (!A_JumpIfTargetInLOS("lunge")) setStateLabel("see");
			}
			#### E 0 {
				if (!angery) angery = true;

				cloaked = false;
			}
			#### EE 2 A_FaceTarget(30);
			#### E 6;
			#### E 0 {
				if (random(0, 2)) {
					A_SpawnItemEx("Bogus_NightmareDemonBlur", flags: SXF_TRANSFERSPRITEFRAME|SXF_NOCHECKPOSITION);

					for (int i = 0; i < 3; i++) A_SpawnItemEx("HDSmoke",frandom(-1,1),frandom(-1,1),frandom(4,24),vel.x,vel.y,vel.z+frandom(1,3),0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,0);
				}
			}
			#### E 0 A_StartSound(meleesound);
			#### A 0 A_ChangeVelocity(random(20, 30), 0, random(5, 7), CVF_RELATIVE);
		meleewait:
			NDEM EEEEEEEEEEEEEEEE 1 {
				A_SpawnItemEx("Bogus_NightmareDemonBlurShort", zofs: 1, flags: SXF_TRANSFERSPRITEFRAME|SXF_NOCHECKPOSITION);
				
				if (CheckIfCloser(target, meleerange)) {
					setStateLabel("melee");

					return;
				}

				if (vel.z < 1 && !random(0, 2)) {
					setStateLabel("lunge");

					return;
				}
			}
			goto see;
		
		death:
			TNT1 A 0 A_SpawnItemEx(
				"BFGNecroShard",
				0, 0, 0,
				0, 0, 5,
				0, SXF_TRANSFERPOINTERS|SXF_SETMASTER, 196
			);
			TNT1 A 0 A_Jump(128, 2);
			TNT1 A 0 A_JumpIf(cloaked, "DeathCloaked");
			NDEM GGG 0 A_SpawnItemEx(
				"HDSmoke",
				random(-1, 1), random(-1, 1), random(4, 24),
				vel.x, vel.y, vel.z + random(1, 3),
				0, SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION, 0
			);
		deathend:
			TNT1 A 0 A_SetTranslucent(1);
			NDEM I 8;
			#### J 8 A_Scream();
			#### K 4;
			#### L 4 A_NoBlocking();
			#### M 4;
		dead:
		death.spawndead:
			TNT1 A 0 A_FadeIn(0.01);
			NDEM M 3 canraise A_JumpIf(floorz > pos.z - 6, 1);
			loop;
			NDEM N 5 canraise A_JumpIf(floorz <= pos.z - 6, "dead");
			loop;
		deathcloaked:
			TNT1 A 20 A_SetTranslucent(1);
			TNT1 A 4 A_NoBlocking;
			TNT1 A 4 A_SetTranslucent(0, 0);
			NDEM N 350 A_SetTics(random(10, 15) * 35);
			goto dead;
			NDEM NNNNNNNNNN 20 A_FadeIn(0.1);
			NDEM N -1;
			stop;

		raise:
			NDEM N 4 A_SetTranslucent(1, 0);
			TNT1 A 0 A_JumpIf(cloaked, "raisecloaked");
			NDEM NMLKJI 6;
			goto see;

		raisecloaked:
			TNT1 AAA 0 A_SpawnItemEx(
				"HDSmoke",
				random(-1, 1), random(-1, 1), random(4, 24),
				vel.x, vel.y, vel.z + random(1, 3),
				0, SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION, 0
			);
			NDEM NNNNNN 4 A_FadeOut(0.15);
			TNT1 A 0 A_SetTranslucent(0, 0);
			goto see;

		ungib:
			TROO U 6 {
				A_Uncloak();

				if (alpha < 1.0) {
					A_SetTranslucent(1);
					A_SpawnItemEx(
						"HDSmoke",
						random(-1, 1), random(-1, 1), random(4, 24),
						vel.x, vel.y, vel.z + random(1, 3),
						0, SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION, 0
					);
				}

				A_GibSplatter();
			}
			TROO UT 8;
			TROO SRQ 6;
			TROO PO 4;
			goto see;
	}
}

class Bogus_NightmareDemonBlur : actor
{
	default {
		renderstyle "normal";
		+nointeraction;
	}
	
	states {
		spawn:
			NDEM # 8 A_FadeOut(frandom(0.01, 0.05));
			loop;
	}
}

class Bogus_NightmareDemonBlurShort : Bogus_NightmareDemonBlur
{
	states {
		spawn:
			NDEM # 1 A_FadeOut(frandom(0.01, 0.05));
			loop;
	}
}