// ================================================================================================
// any cacodemon born after 1993 can't cook... 
// all they know is thy fries consumed, charge they astral orb, 
// float, be demon, eat marine & die
// ================================================================================================

class Bogus_AstralCacodemon : HDMobBase {

	default {
		//$Category "Monsters/Hideous Destructor"
		//$Title "Astral Cacodemon"
		//$Sprite "ACACA1"

		health 200;
		HDMobBase.shields 200;
		radius 24;
		height 48;
		mass 400;

		meleerange 128;

		+float 
		+nogravity
		+pushable
		+noblooddecals
		+hdmobbase.doesntbleed
		+hdmobbase.headless
		+hdmobbase.onlyscreamondeath

		seesound "astralCaco/sight";
		painsound "astralCaco/pain";
		deathsound "astralCaco/death";
		activesound "astralCaco/active";
		meleesound "astralCaco/melee";

		tag "$TAG_ASTRALCACO";
		bloodcolor "22 22 22";

		gravity HDCONST_GRAVITY * 0.25;
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
	}

	override void beginPlay() {
		super.beginPlay();

		resize(0.9, 1.3);

		speed *= 3. - 2 * scale.x;
	}
	
	states {
		spawn:
			ACAC A 10 {
				A_HDLook();
				
				if (!bAMBUSH && !random(0, 10)) A_HDWander();
			}
			wait;
			
		see:
			#### A 4 A_HDChase();
			loop;
			
		pain:
			#### H 2 {					
				vel.z -= frandom(0.4, 1.4);
			}
			#### H 6 A_Pain();
			#### H 3;
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
				"AstralJuice",
				0, 0, 24,
				cos(pitch) * 36, 0, -sin(pitch) * 27,
				flags: SXF_NOCHECKPOSITION|SXF_SETTARGET|SXF_TRANSFERPITCH
			);
			#### F 4;
			goto see;
			
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
			goto see;
			
		regularball2:
			#### F 4 A_FaceTarget(40, 40, flags: FAF_MIDDLE);
			#### G 4 bright A_SpawnProjectile("AstralNormalBall",flags:CMF_AIMDIRECTION,pitch);
			#### FA 4;
		regularball:
			#### F 4 A_FaceTarget(40, 40, flags: FAF_MIDDLE);
			#### G 4 bright A_SpawnProjectile("AstralNormalBall",flags:CMF_AIMDIRECTION,pitch);
			#### F 4;
			goto see;
			
		melee:
			#### FG 3 A_FaceTarget();
			#### F 3 A_CustomMeleeAttack(random(30, 50),meleesound,"","teeth",true);
			#### AAAA 2  {
				A_FaceTarget(15, 15);
				A_ChangeVelocity(frandom(3, 5), flags: CVF_RELATIVE);
			}
			#### FG 3 A_FaceTarget();
			#### F 3 A_CustomMeleeAttack(random(30, 50),meleesound,"","teeth",true);
			#### A 3;
			goto see;
			
		death:
		gib:
			#### J 2  {
				bfloatbob = false;
				bnogravity = false;
				bfloat = false;
				A_Vocalize(seesound);
			}
			#### KLM 2;
			#### N 2 A_JumpIf (vel.z >= 0, "deadsplatting");
			wait;
			
		deadsplatting:
			#### O 4 A_Scream();
			#### PQR 4;
		dead:
		gibbed:
		death:spawndead:
			#### S -1;
			stop;
		
		raise:
		ungib:
			#### S 8 A_UnSetFloorClip();
			#### SRQPONMLKJ 8;
			goto see;
	}
}

class AstralJuice : ManJuice {
	states {
		spawn:
			ACFB A 0 {
				spawn("manjuicelight", pos + (0, 0, 16), ALLOW_REPLACE).target = self;
			}
			#### AABBAABB 1 A_FBTail();
		spawn2:
			#### A 2 A_FBFloat();
			#### B 2;
			loop;

		death:
			#### B 0 {
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
			#### CCCC 1 {
				vel.z += 0.5;
				scale *= 1.05;
			}
			#### DDDEEE 1 {
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

//dont zap urself lmao
class AstralNormalBall : HDFireball {
	default {
		height 12;
		radius 12;
		gravity 0;
		decal "BulletScratch";
		damagefunction(random(20, 40));
	}

	void ZapSomething() {
		roll = frandom(0, 360);

		A_StartSound("misc/arczap");

		Actor tb = target;
		Actor zit = null;

		BlockThingsIterator it = BlockThingsIterator.create(self, 72);
		while (it.next()) {
			if (it.thing.bSHOOTABLE) {
				zit = it.thing;

				A_Face(zit, 0, 0, flags: FAF_MIDDLE);

				if (
					zit.health > 0
					&& checkSight(it.thing)
					&& (!tb || zit == tb.target || !(zit is 'Bogus_AstralCacodemon'))
				) {
					zit.damagemobj(self, tb, random(0, 7), "Electro");
				}

				break;
			}
		}

		if (!zit || zit == tb) {
			pitch = frandom(-90, 90);
			angle = frandom(0,360);
		}

		A_CustomRailgun(
			0, 0,
			"", "e0 df ff",
			RGF_SILENT|RGF_NOPIERCING|RGF_FULLBRIGHT|RGF_CENTERZ|RGF_NORANDOMPUFFZ,
			0, 4000,
			"FoofPuff",
			range: 128,
			6, 0.8, 1.5
		);
		A_FaceTracer(4,4);
		if (pos.z-floorz<24)vel.z+=0.3;
	}

	states {
		spawn:
			BAL2 A 0 ZapSomething();
			#### AB 2 light("PLAZMABX1") A_Corkscrew();
			loop;
		death:
			#### C 0 A_SprayDecal("CacoScorch", radius * 2);
			#### C 0 A_StartSound("misc/fwoosh", CHAN_AUTO);
			#### CCCDDDEEE 1 light("BAKAPOST1") ZapSomething();
		death2:
			#### E 0 ZapSomething();
			#### E 3 light("PLAZMABX2") A_FadeOut(0.3);
			loop;
	}
}