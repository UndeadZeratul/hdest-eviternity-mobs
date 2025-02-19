// ================================================================
// something funny and creative
// ================================================================

class Bogus_FormerCaptain : VulcanetteZombie
{
	default
	{
		radius 20;
		height 54;

		
		health 140;
		hdmobbase.shields 300;
		hdmobbase.downedframe 11;
		
		speed 8;
		mass 100;
		maxtargetrange 6000;

		tag "$TAG_FORMERCAPTAIN";
		obituary "$OB_VULCZOMBIE";
	}

	// Carbon copy of VulcanetteZombie, except uses FCAP sprites instead of CPOS
	states
	{
		spawn:
			FCAP B 1 nodelay{
				A_HDLook();
				A_Recoil(random(-1,1)*0.1);
				A_SetTics(random(10,40));
			}
			FCAP BB 1{
				A_HDLook();
				A_SetTics(random(10,40));
			}
			FCAP A 8{
				if(bambush)setstatelabel("spawnhold");
				else if(!random(0,1))setstatelabel("spawnstill");
				else A_Recoil(random(-1,1)*0.2);
			}loop;
		spawnhold:
			FCAP G 1{
				A_HDLook();
				if(!random(0,8))A_Recoil(random(-1,1)*0.4);
				A_SetTics(random(10,30));
				if(!random(0,8))A_Vocalize(activesound);
			}wait;
		spawnstill:
			FCAP C 0 A_Jump(196,"spawnscan","spawnscan","spawnwander");
			FCAP C 0{
				A_HDLook();
				A_Recoil(random(-1,1)*0.4);
			}
			FCAP CD 5{angle+=random(-4,4);}
			FCAP AB 5{
				A_HDLook();
				if(!random(0,15))A_Vocalize(activesound);
				angle+=random(-4,4);
			}
			FCAP B 1 A_SetTics(random(10,40));
			---- A 0 setstatelabel("spawn");
		spawnwander:
			FCAP A 0 A_HDLook();
			FCAP CD 5 A_HDWander();
			FCAP A 5{
				A_HDLook();
				if(!random(0,15))A_Vocalize(activesound);
				A_HDWander();
			}
			FCAP B 5 A_HDWander();
			FCAP A 0 A_Jump(96,"spawn","spawnscan");
			loop;
		spawnscan:
			FCAP E 4{
				turnleft=randompick(0,0,0,1);
				if(turnleft)angle-=frandom(18,24);
				else angle+=frandom(18,24);
			}
		spawnturn:
			FCAP EEEEEE 4 A_HDLook(label:"missile");
			FCAP E 0 A_Jump(116,"spawnturn","spawnscan","spawnscan");
			---- A 0 setstatelabel("spawnwander");
		see:
		scan:
			FCAP E 4{
				turnleft=randompick(0,0,0,1);
				if(turnleft)angle-=frandom(18,24);
				else angle+=frandom(18,24);
			}
		scanturn:
			FCAP E 0{if(!targetinsight)A_HDLook(LOF_NOJUMP|LOF_NOSOUNDCHECK);}
			FCAP EEEEEE 4 A_Watch();
			FCAP E 0 A_Jump(32,"scanturn","scanturn","scan");
			//fallthrough to seemove
		seemove:
			FCAP A 0 A_JumpIf(!mags&&thismag<1,"reload");
			FCAP ABCD 5 A_HDChase(null,"melee");
			FCAP A 0 A_Jump(64,"scan");
			loop;
		missile:
			FCAP ABCD 5 A_TurnToAim(30,shootstate:"aim");
			loop;
		aim:
			FCAP E 2{
				if(
					target
					&&target.spawnhealth()>random(50,1000)
				)superauto=true;
			}
			FCAP E 1 A_StartAim(rate:0.92,maxtics:random(20,30));
			//fallthrough to shoot
		shoot:
			FCAP E 4 A_LeadTarget(6);
		fire:
			FCAP F 1 bright light("SHOT") A_VulcZombieShot();
			FCAP E 2 A_JumpIf(superauto,"fire");
			loop;
		postshot:
		considercover:
			FCAP E 1;
			FCAP E 0 A_JumpIf(thismag<1&&mags<1,"reload");
		cover:
			FCAP EEEE 3 A_Coverfire("fire",5);
			FCAP E 0 A_JumpIf(targetinsight,"missile");
			loop;
		shuntmag:
			FCAP E 1;
			FCAP E 3{
				A_StartSound("weapons/vulcshunt",8);
				if(thismag>=0){
					actor mmm=HDMagAmmo.SpawnMag(self,"HD4mMag",0);
					mmm.A_ChangeVelocity(3,frandom(-3,2),frandom(0,-2),CVF_RELATIVE|CVF_REPLACE);
				}
				thismag=-1;
				if(mags>0){
					mags--;
					thismag=50;
				}
			}
			---- A 0 setstatelabel("fire");
		chamber:
			FCAP E 3{
				if(chambers<5&&thismag>0){
					thismag--;
					chambers++;
					A_StartSound("weapons/rifleclick2",8,CHANF_OVERLAP);
				}
			}
			---- A 0 setstatelabel("fire");

		reload:
			FCAP A 0 A_JumpIf(!target||!checksight(target),"loadamag");
			FCAP ABCD 5 A_Chase(null,null,flags:CHF_FLEE);
		loadamag:
			FCAP E 9 A_StartSound("weapons/pocket",9);
			FCAP E 7 A_StartSound("weapons/vulcmag",8);
			FCAP E 10{
				if(thismag<0)thismag=50;
				else if(mags<4)mags++;
				else{
					setstatelabel("seemove");
					return;
				}A_StartSound("weapons/rifleclick2",8);
			}loop;

		melee:
			FCAP DAB 2 A_FaceTarget(10,10);
			FCAP C 6 A_FaceTarget();
			FCAP D 2;
			FCAP E 3 A_CustomMeleeAttack(
				random(9,99),"weapons/smack","","none",randompick(0,0,0,1)
			);
			FCAP E 2 A_JumpIfTargetInsideMeleeRange("melee");
			---- A 0 setstatelabel("considercover");
			FCAP E 0 A_JumpIf(target.health<random(-3,1),"see");
			FCAP EC 2;
			---- A 0 setstatelabel("melee");

		pain:
			FCAP G 3;
			FCAP G 3 A_Vocalize(painsound);
			---- A 0 setstatelabel("seemove");


		death:
			FCAP H 5;
			FCAP I 5{
				A_SpawnItemEx("MegaBloodSplatter",0,0,34,0,0,0,0,160);
				A_Vocalize(deathsound);
			}
			FCAP J 5 A_SpawnItemEx("MegaBloodSplatter",0,0,34,0,0,0,0,160);
			FCAP KL 5;
			FCAP M 5;
		dead:
			FCAP M 3;
			FCAP N 5 canraise{
				if(abs(vel.z)>1)setstatelabel("dead");
			}wait;
		gib:
			FCAP O 5;
			FCAP P 3{
				A_GibSplatter();
				A_XScream();
			}
			FCAP P 2 A_GibSplatter();
			FCAP Q 5;
			FCAP Q 0 A_GibSplatter();
			FCAP RS 5 A_GibSplatter();
		gibbed:
			FCAP S 3;
			FCAP T 5 canraise{
				if(abs(vel.z)>1)setstatelabel("dead");    
			}wait;
		raise:
			FCAP N 2 A_SpawnItemEx("MegaBloodSplatter",0,0,4,0,0,3,0,SXF_NOCHECKPOSITION);
			FCAP NML 6;
			FCAP KJIH 4;
			#### A 0 A_Jump(256,"see");
		ungib:
			FCAP T 6 A_SpawnItemEx("MegaBloodSplatter",0,0,4,0,0,3,0,SXF_NOCHECKPOSITION);
			FCAP TS 12 A_SpawnItemEx("MegaBloodSplatter",0,0,4,0,0,3,0,SXF_NOCHECKPOSITION);
			FCAP RQ 7;
			FCAP POH 5;
			#### A 0 A_Jump(256,"pain");
	}
}