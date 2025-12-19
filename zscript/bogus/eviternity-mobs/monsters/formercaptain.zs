// ================================================================
// something funny and creative
// ================================================================

class Bogus_FormerCaptain : VulcanetteZombie {
	default {
		radius 20;
		height 54;
		seesound "formercaptain/sight";
		painsound "formercaptain/pain";
		deathsound "formercaptain/death";
		activesound "formercaptain/active";
		tag "$TAG_FORMERCAPTAIN";

		health 150;
		speed 8;
		mass 200;
		maxtargetrange 6000;
		obituary "$OB_FORMERCAPTAIN";
		hdmobbase.downedframe 11;
	}

	override void postbeginplay() {
		super.postbeginplay();
		
		// Prevent Vulcanette Black/Red Color Scheme
		A_SetTranslation("");
	}


	// TODO: Implement Drops
	override void deathdrop() {
		if (!bHASDROPPED) {
			// DropNewItem("HDBattery", 16);
			DropNewItem("HDHandgunRandomDrop");

			// let vvv = DropNewWeapon("Vulcanette");
			// if(!vvv)return;
			// vvv.weaponstatus[VULCS_MAG1]=thismag;
			// for(int i=VULCS_MAG2;i<=VULCS_MAG5;i++){
			// 	if(mags>0){
			// 		vvv.weaponstatus[i]=51;
			// 		mags--;
			// 	}else vvv.weaponstatus[i]=-1;
			// }
			// vvv.weaponstatus[VULCS_CHAMBER1]=(!random(0,3))?2:1;
			// vvv.weaponstatus[VULCS_CHAMBER2]=(!random(0,3))?2:1;
			// vvv.weaponstatus[VULCS_CHAMBER3]=(!random(0,3))?2:1;
			// vvv.weaponstatus[VULCS_CHAMBER4]=(!random(0,3))?2:1;
			// vvv.weaponstatus[VULCS_CHAMBER5]=(!random(0,3))?2:1;
			// if(superauto)vvv.weaponstatus[0]|=VULCF_FAST;
			// vvv.weaponstatus[VULCS_BATTERY]=random(1,20);
			// vvv.weaponstatus[VULCS_BREAKCHANCE]=random(0,random(1,500));
			// vvv.weaponstatus[VULCS_ZOOM]=random(16,70);
		} else if(!bFRIENDLY) {
			// DropNewItem("HD4mMag",96);
			// DropNewItem("HD4mMag",96);
			// DropNewItem("HDBattery",8);
		}
	}

	// Carbon copy of VulcanetteZombie, except uses FCAP sprites instead of CPOS
	states {
		spawn:
			FCAP B 1 nodelay {
				A_HDLook();
				A_Recoil(random(-1,1)*0.1);
				A_SetTics(random(10,40));
			}
			#### BB 1 {
				A_HDLook();
				A_SetTics(random(10, 40));
			}
			#### A 0 A_JumpIf(bAMBUSH, "spawnhold");
			#### A 0 A_JumpIf(!random(0, 1), "spawnstill");
			#### A 8 A_Recoil(random(-1, 1) * 0.2);
			loop;

		spawnhold:
			#### G 1 {
				A_HDLook();

				if (!random(0,8)) A_Recoil(random(-1, 1) * 0.4);

				A_SetTics(random(10, 30));

				if (!random(0, 8)) A_Vocalize(activesound);
			}
			wait;

		spawnstill:
			#### C 0 A_Jump(196, "spawnscan", "spawnscan", "spawnwander");
			#### C 0 A_HDLook();
			#### C 0 A_Recoil(random(-1, 1) * 0.4);
			#### CD 5 A_SetAngle(angle + random(-4, 4));
			#### AB 5 {
				A_HDLook();

				if (!random(0, 15)) A_Vocalize(activesound);

				angle += random(-4, 4);
			}
			#### B 1 A_SetTics(random(10,40));
			goto spawn;

		spawnwander:
			#### A 0 A_HDLook();
			#### CD 5 A_HDWander();
			#### A 5 {
				A_HDLook();

				if (!random(0, 15)) A_Vocalize(activesound);

				A_HDWander();
			}
			#### B 5 A_HDWander();
			#### A 0 A_Jump(96, "spawn", "spawnscan");
			loop;

		spawnscan:
			#### E 4 {
				turnleft = randompick(0, 0, 0, 1);
				angle += (turnLeft ? -1 : 1) * frandom(18, 24);
			}
		spawnturn:
			#### EEEEEE 4 A_HDLook(label: "missile");
			#### E 0 A_Jump(116, "spawnturn", "spawnscan", "spawnscan");
			goto spawnwander;

		see:
		scan:
			#### E 4 {
				turnleft = randompick(0,0,0,1);
				angle += (turnLeft ? -1 : 1) * frandom(18, 24);
			}
		scanturn:
			#### E 0 {
				if (!targetinsight) A_HDLook(LOF_NOJUMP|LOF_NOSOUNDCHECK);
			}
			#### EEEEEE 4 A_Watch();
			#### E 0 A_Jump(32, "scanturn", "scanturn", "scan");
		seemove:
			#### A 0 A_JumpIf(!mags && thismag < 1, "reload");
			#### ABCD 5 A_HDChase(null, "melee");
			#### A 0 A_Jump(64, "scan");
			loop;

		missile:
			#### ABCD 5 A_TurnToAim(30, shootstate: "aim");
			loop;

		aim:
			#### E 2 {
				if (target && target.spawnhealth() > random(50, 1000)) superauto = true;
			}
			#### E 1 A_StartAim(rate: 0.92, maxtics: random(20, 30));
		shoot:
			#### E 4 A_LeadTarget(6);
		fire:
			#### F 1 bright light("SHOT") A_VulcZombieShot();
			#### E 2 A_JumpIf (superauto,"fire");
			loop;
		postshot:
		considercover:
			#### E 1;
			#### E 0 A_JumpIf (thismag<1&&mags<1,"reload");
		cover:
			#### EEEE 3 A_Coverfire("fire",5);
			#### E 0 A_JumpIf (targetinsight,"missile");
			loop;
		shuntmag:
			#### E 1;
			#### E 3 {
				A_StartSound("weapons/vulcshunt",8);

				if (thismag >= 0) {
					HDMagAmmo.SpawnMag(self, "HD4mMag", 0)
						.A_ChangeVelocity(
							3, frandom(-3, 2), frandom(0, -2),
							CVF_RELATIVE|CVF_REPLACE
						);
				}

				thismag = -1;

				if (mags > 0) {
					mags--;
					thismag = 50;
				}
			}
			goto fire;

		chamber:
			#### E 3 {
				if (chambers < 5 && thismag > 0) {
					thismag--;
					chambers++;

					A_StartSound("weapons/rifleclick2", 8, CHANF_OVERLAP);
				}
			}
			goto fire;

		reload:
			#### A 0 A_JumpIf(!target || !checkSight(target), "loadamag");
			#### ABCD 5 A_Chase(null, null, flags: CHF_FLEE);
		loadamag:
			#### E 9 A_StartSound("weapons/pocket", 9);
			#### E 7 A_StartSound("weapons/vulcmag", 8);
			#### E 10 {
				if (thismag < 0) {
					thismag = 50;
				} else if (mags < 4) {
					mags++;
				} else {
					setstatelabel("seemove");
					return;
				}

				A_StartSound("weapons/rifleclick2", 8);
			}
			loop;

		melee:
			#### DAB 2 A_FaceTarget(10,10);
			#### C 6 A_FaceTarget();
			#### D 2;
			#### E 3 A_CustomMeleeAttack(random(9, 99), "weapons/smack", "", "none", randompick(0, 0, 0, 1));
			#### E 2 A_JumpIfTargetInsideMeleeRange("melee");
			goto considercover;
			#### E 0 A_JumpIf(target.health<random(-3,1),"see");
			#### EC 2;
			goto melee;

		pain:
			#### G 3;
			#### G 3 A_Vocalize(painsound);
			goto seemove;

		death:
			#### H 5;
			#### I 5 {
				A_GibSplatter();
				A_Vocalize(deathsound);
			}
			#### J 5 A_GibSplatter();
			#### KL 5;
			#### M 5;
		dead:
			#### M 3;
			#### N 5 canraise A_JumpIf(abs(vel.z) > 1, "dead");
			wait;

		gib:
			#### O 5;
			#### P 3 {
				A_GibSplatter();
				A_XScream();
			}
			#### P 2 A_GibSplatter();
			#### Q 5;
			#### Q 0 A_GibSplatter();
			#### RS 5 A_GibSplatter();
		gibbed:
			#### S 3;
			#### T 5 canraise A_JumpIf(abs(vel.z) > 1, "dead");
			wait;

		raise:
			#### N 2 A_GibSplatter();
			#### NML 6;
			#### KJIH 4;
			goto see;

		ungib:
			#### T 6 A_GibSplatter();
			#### TS 12 A_GibSplatter();
			#### RQ 7;
			#### POH 5;
			goto pain;
	}
}
