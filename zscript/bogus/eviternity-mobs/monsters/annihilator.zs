// ================================================================
// annihilating your mom's ass since 1993
// ================================================================

class Bogus_Annihilator : PainMonster
{
	int remainingnades;
	int remainingburst;
	int aimtime;
	vector2 leadoldaim;
	bool angery;
	int doitagain;
	
	default
	{
		height 64;
		deathheight 8;
		radius 17;
		mass 2000;
		speed 12;
		+bossdeath
		+missileevenmore
		bloodcolor "red";
		
		seesound "annihilator/sight";
		painsound "annihilator/pain";
		deathsound "annihilator/death";
		activesound "annihilator/active";
		
		obituary "%o's hearts and minds are now splattered all over the wall.";
		tag "Annihilator";
		
		maxtargetrange 65536;
		damagefactor "thermal", 0.5;
		damagefactor "smallarms0", 0.4;
		damagefactor "balefire", 0.1;
		damagefactor "bashing", 0.5;
		damagefactor "piercing", 0.5;
		health 1100;
		hdmobbase.shields 3000;
	}
	
	override void PostBeginPlay()
	{
		super.postbeginplay();
		remainingnades = random(8, 12) * 2;
		bsmallhead = true;
		angery = false;
	}
	
	// ================================================================
	// THESE NEXT TWO FUNCTIONS NABBED FROM HD'S MARINE
	// ================================================================
	
	vector2 A_LeadTarget1(){
		if(!target){
			leadoldaim=(angle,pitch);
			return leadoldaim;
		}
		vector2 aimbak=(angle,pitch);
		A_FaceTarget(0,0);
		leadoldaim=(angle,pitch);
		angle=aimbak.x;pitch=aimbak.y;
		return leadoldaim;
	}
	vector2 A_LeadTarget2(
		double dist=-1,
		double shotspeed=20,
		vector2 oldaim=(-1,-1),
		double adjusttics=1
	){
		if(!target||!shotspeed)return(0,0);

		//get current angle for final calculation
		vector2 aimbak=(angle,pitch);

		//distance defaults to distance from target
		if(dist<0)dist=distance3d(target);

		//figure out how many tics to adjust
		double ticstotarget=dist/shotspeed+adjusttics;
		if(ticstotarget<1.)return(0,0);

		//retrieve result from A_LeadTarget1
		if(oldaim==(-1,-1))oldaim=leadoldaim;

		//check the aim to change and revert immediately
		//I could use angleto but the pitch calculations would be awkward
		A_FaceTarget(0,0);
		vector2 aimadjust=(
			deltaangle(oldaim.x,angle),
			deltaangle(oldaim.y,pitch)
		);

		//something fishy is going on
		if(abs(aimadjust.x)>45)return (0,0);

		//multiply by tics
		aimadjust*=ticstotarget;

		//apply and return
		angle=aimbak.x+aimadjust.x;pitch=aimbak.y+aimadjust.y;
		return aimadjust;
	}
	
	void A_AnnihilatorMinigun()
	{
		A_PlaySound("weapons/bigrifle");
		HDBulletActor boolet = HDBulletActor.FireBullet(self,"HDB_355", spread: angery ? 10 : 5);
		boolet.warp(self, radius, -radius * 0.55, (height / 2) + 1, flags: WARPF_NOCHECKPOSITION);
		A_SpawnItemEx("HDSpent355",
			-radius * 1.5,radius - 6,(height / 2) + 4,
			vel.x,vel.y,vel.z + 5,
			180,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
		);
		
		remainingburst--;
		
		if (remainingburst <= 0)
		{
			SetStateLabel("postminigun");
		}
	}
	
	states
	{
		spawn:
			ANNI AA 8 A_Look();
			ANNI A 1 A_SetTics(random(1, 16));
			ANNI BB 8 A_Look();
			ANNI B 1 A_SetTics(random(1, 16));
			ANNI CC 8 A_Look();
			ANNI C 1 A_SetTics(random(1, 16));
			ANNI DD 8 A_Look();
			ANNI D 1 A_SetTics(random(1, 16));
			TNT1 A 0 A_Jump(216, "spawn");
			TNT1 A 0 A_PlaySound("baron/active");
			
		see:
			TNT1 A 0 A_AlertMonsters();
			TNT1 A 0
			{
				let shields = hdmagicshield(self.findinventory("hdmagicshield"));
				if ((shields.amount <= 2000 && !angery)
					|| (health <= 700 && !angery))
				{
					SetStateLabel("ree");
				}
			}
			ANNI A 8 { hdmobai.chase(self); A_SetTics(angery ? 6 : 8); }
			ANNI B 8 { hdmobai.chase(self); A_PlaySound("spider/walk"); A_SetTics(angery ? 6 : 8); }
			ANNI C 8 { hdmobai.chase(self); A_SetTics(angery ? 6 : 8); }
			ANNI D 8 { hdmobai.chase(self); A_PlaySound("spider/walk"); A_SetTics(angery ? 6 : 8); }
			TNT1 A 0 A_JumpIfTargetInLOS("see");
			TNT1 A 0 SetStateLabel("roam");
			
		roam:
			TNT1 A 0 A_AlertMonsters();
			TNT1 A 0 A_JumpIfTargetInLOS("missile");
			ANNI A 8 { hdmobai.chase(self); A_SetTics(angery ? 6 : 8); }
			ANNI B 8 { hdmobai.chase(self); A_PlaySound("spider/walk"); A_SetTics(angery ? 6 : 8); }
			ANNI C 8 { hdmobai.chase(self); A_SetTics(angery ? 6 : 8); }
			ANNI D 8 { hdmobai.chase(self); A_PlaySound("spider/walk"); A_SetTics(angery ? 6 : 8); }
			loop;
			
		melee:
		missile:
			ANNI A 8 
			{ 
				A_FaceTarget(60);
				if (A_JumpIfTargetInLOS("shoot", 10))
					SetStateLabel("shoot");
			}
			ANNI B 8 
			{ 
				A_PlaySound("spider/walk");
				A_FaceTarget(60);
				if (A_JumpIfTargetInLOS("shoot", 10))
					SetStateLabel("shoot");
			}
			ANNI C 8 
			{ 
				A_FaceTarget(60);
				if (A_JumpIfTargetInLOS("shoot", 10))
					SetStateLabel("shoot");
			}
			ANNI D 8 
			{ 
				A_PlaySound("spider/walk");
				A_FaceTarget(60);
				if (A_JumpIfTargetInLOS("shoot", 10))
					SetStateLabel("shoot");
			}
			ANNI A 0 A_JumpIfTargetInLOS("missile");
			ANNI A 0 SetStateLabel("see");
			
		shoot:
			ANNI A 0 A_AlertMonsters(0, AMF_TARGETNONPLAYER);
			ANNI A 0
			{
				if (CheckIfCloser(target, 512) && random(0, 2))
				{
					aimtime = int(Distance2D(target));
					if (aimtime < 512)
					{
						aimtime = 0;
					}
					else
					{
						aimtime /= 32;
					}
					
					clamp(aimtime, 0, 16);
					remainingburst = random(10, 30);
					
					SetStateLabel("minigun");
				}
				else if (!CheckIfCloser(target, 512) && remainingnades > 0)
				{
					aimtime = int(Distance2D(target));
					if (aimtime < 1024)
					{
						aimtime = 0;
					}
					else
					{
						aimtime /= 32;
					}
					
					clamp(aimtime, 0, 16);
					doitagain = angery ? 2 : 1;
					SetStateLabel("grenade");
				}
				else
				{
					aimtime = int(Distance2D(target));
					if (aimtime < 512)
					{
						aimtime = 0;
					}
					else
					{
						aimtime /= 32;
					}
					
					clamp(aimtime, 0, 16);
					remainingburst = random(30, 50);
					SetStateLabel("minigun");
				}
			}
			ANNI A 0 SetStateLabel("see");
			
		grenade:
			ANNI EEEEEEEE 4
			{
				A_FaceTarget(10, 10);
				A_SetTics(angery ? 2 : 4);
			}
			ANNI E 1 A_FaceTarget(10, 10);
			ANNI E 1 A_LeadTarget1();
			ANNI E 2 A_LeadTarget2(shotspeed:getdefaultbytype("PyroGrenade").speed,adjusttics:2);
			ANNI E 0
			{
				if (!A_JumpIfTargetInLOS("grenade"))
				{
					SetStateLabel("waitgrenade");
				}
				
				if (target)
				{
					if (target.health <= 0)
					{	
						SetStateLabel("see");
					}
				}
				else
				{
					SetStateLabel("see");
				}
				
				if (aimtime <= 0)
				{
					SetStateLabel("shootgrenade");
				}
				else
				{
					aimtime -= angery ? 8 : 2;
				}
			}
			goto grenade + 8;
			
		waitgrenade:
			ANNI EEEEEEEE 4
			{
				A_SetTics(random(4, 8));
				
				if (A_JumpIfTargetInLOS("grenade"))
				{
					SetStateLabel("grenade");
				}
				
				aimtime--;
			}
			ANNI E 0 SetStateLabel("see");
			
		shootgrenade:
			ANNI F 2
			{
				hdmobai.DropAdjust(self, "PyroGrenade");
				
				actor grenade;
				bool yeet;
				
				[yeet, grenade] = A_SpawnItemEx("PyroGrenade", radius, -radius + 3, (height) / 2 + 4,
					flags: SXF_NOCHECKPOSITION);
				grenade.pitch = pitch;
				grenade.angle = angle;
				grenade.target = self;
				
				remainingnades--;
			}
			ANNI E 8 A_SetTics(angery ? 4 : 8);
			ANNI E 0
			{
				if (doitagain > 0)
				{
					doitagain--;
					
					if (remainingnades > 0)
					{
						aimtime = int(Distance2D(target));
						if (aimtime < 1024)
						{
							aimtime = 0;
						}
						else
						{
							aimtime /= 32;
						}
						
						clamp(aimtime, 0, 16);
						setstatelabel("grenade");
					}
				}
			}
			ANNI A 0
			{
				if (angery)
				{
					if (!random(0, 2))
					{
						SetStateLabel("grenade");
					}
					else
					{
						remainingburst = random(30, 50);
						SetStateLabel("minigun");
					}
				}
			}
			ANNI A 0 SetStateLabel("see");
		
		pain:
			ANNI J 6 A_Pain();
			ANNI J 3
			{
				if (angery && !random(0, 7))
				{
					SetStateLabel("puttotime");
				}
			}
			ANNI J 0 A_Jump(128, "see", "minigun");
			ANNI J 0 SetStateLabel("see");
			
		ree:
			ANNI J 32
			{
				A_FaceTarget();
				angery = true;
				remainingburst = 30;
				speed = 20;
				A_Quake(5, 50, 0, 600, seesound);
			}
			
		puttotime:
			ANNI J 0
			{
				int benis = random(2, 4);
				for (int i = 0; i < benis; i++)
				{
					actor p=spawn("Putto", pos + (random(-8, 8), random(-8, 8), random(height / 2, height)),ALLOW_REPLACE);
					p.master=self;p.angle=angle;p.pitch=pitch;
					p.A_ChangeVelocity(cos(pitch)*5,0,-sin(pitch)*5,CVF_RELATIVE);
					p.bfriendly=bfriendly;p.target=target;
				}
			}
			ANNI J 0 SetStateLabel("minigun");
			
		minigun:
			ANNI GS 4 A_FaceTarget(30, 30);
			ANNI S 8;
			ANNI S 4
			{
				if (angery)
				{
					remainingburst += random(30, 50);
				}
				
				if (aimtime <= 0)
				{
					SetStateLabel("shootminigun");
				}
				else
				{
					aimtime -= angery ? 8 : 2;
				}
			}
			goto minigun + 3;
			
		shootminigun:
			ANNI S 8;
			ANNI S 0
			{
				if (target)
				{
					if (target.health <= 0)
					{	
						SetStateLabel("postminigun");
					}
				}
				else
				{
					SetStateLabel("postminigun");
				}
				
				if (!A_JumpIfTargetInLOS("shootminigun"))
				{
					SetStateLabel("waitminigun");
				}
			}
			ANNI S 1
			{
				A_FaceTarget(5, 5);
				A_SetTics(angery ? 0 : 2);
			}
			ANNI H 1 A_AnnihilatorMinigun();
			ANNI S 1
			{
				A_FaceTarget(5, 5);
				A_SetTics(angery ? 0 : 2);
			}
			ANNI I 1 A_AnnihilatorMinigun();
			goto shootminigun + 1;
		
		waitminigun:
			ANNI SSSSSSSS 4
			{
				A_SetTics(random(4, 8));
				
				if (A_JumpIfTargetInLOS("shootminigun"))
				{
					SetStateLabel("shootminigun");
				}
			}
			ANNI S 0 SetStateLabel("see");
			
		postminigun:
			ANNI GA 4;
			ANNI A 0 SetStateLabel("see");
			
		death:
			ANNI J 0 A_Scream();
			ANNI J 0 spawn("Gyrosploder",self.pos-(0,0,1),ALLOW_REPLACE);
			ANNI J 8 A_SetTics(random(64, 128));
			ANNI J 0 A_BossDeath();
			ANNI KLM 4 
			{
				A_SpawnItemEx("CyberGibs",
					random(-10,10),random(-10,10),random(0,16),
					random(-6,6),random(-6,6),random(3,12)
				);
				
				spawn("Gyrosploder",self.pos-(random(-16, 16),random(-16, 16),random(0, 16)),ALLOW_REPLACE);
				
				A_HDBlast(
				pushradius:256,pushamount:128,fullpushradius:96,
				fragradius:HDCONST_SPEEDOFSOUND-10*stamina,fragtype:"HDB_fragRL",
				immolateradius:128,immolateamount:random(3,60),
				immolatechance:25
				);
			}
			ANNI M 0
			{
				for(int i = 0; i < remainingnades / 2; i++)
				{
					if (!random(0, 2))
					{
						A_SpawnItemEx("HDRocketAmmo",
							random(-10,10),random(-10,10),random(0,16),
							random(-3,3),random(-3,3),random(3,6), flags: SXF_NOCHECKPOSITION
						);
					}
					else
					{
						A_SpawnItemEx("DudRocket",
							random(-10,10),random(-10,10),random(0,16),
							random(-3,3),random(-3,3),random(3,6), flags: SXF_NOCHECKPOSITION
						);
					}
				}
				
				mass = 100;
			}
			ANNI MMMMMMMMMMMMMMMM 0 
			{
				for (int i = 0; i < 5; i++)
				{
					if (!random(0, 4))
					{
						A_SpawnItemEx("HDRevolverAmmo",
							random(-10,10),random(-10,10),random(0,16),
							random(-3,3),random(-3,3),0, random(0, 360), SXF_NOCHECKPOSITION
						);
					}
					else
					{
						A_SpawnItemEx("HDSpent355",
							random(-10,10),random(-10,10),random(0,16),
							random(-3,3),random(-3,3),0, random(0, 360), SXF_NOCHECKPOSITION
						);
					}
				}
			}
			ANNI NOPQ 4 
			{
				A_SpawnItemEx("CyberGibs",
					random(-10,10),random(-10,10),random(0,16),
					random(-6,6),random(-6,6),random(3,12)
				);
			}
			ANNI RRRRRRRR 0 
			{
				if(!random(0, 3))
				{
					actor butto = A_DropItem("Putto");
					butto.bfriendly = bfriendly;
				}
				else if (!random(0, 2))
				{
					A_SpawnItemEx("BFGNecroShard",
						frandom(-4,4),frandom(-4,4),frandom(6,24),
						frandom(1,6),0,frandom(1,3),
						frandom(0,360),SXF_NOCHECKPOSITION|SXF_TRANSFERPOINTERS|SXF_SETMASTER
					);
				}
				
				if(!random(0, 7))
				{
					let mmm = HDMagAmmo.SpawnMag(self,"HDBattery",random(12, 18));
					mmm.vel = vel+(frandom(-3,3),frandom(-3,3),3);
				}
			}
			ANNI R 0 SetStateLabel("dead");
			
		dead:
			ANNI R -1;
			stop;
	}
}

class PyroGrenade : RocketGrenade
{
	default
	{
		speed 70;
	}
	
	//same as gyrogrenade but don't destroy
	override void ExplodeSlowMissile(line blockingline,actor blockingobject){
		if(max(abs(skypos.x),abs(skypos.y))>=32768){return;}
		bmissile=false;

		//bounce
		if(!primed&&random(0,20)){
			if(speed>50)painsound="misc/punch";else painsound="misc/fragknock";
			actor a=spawn("IdleDummy",pos,ALLOW_REPLACE);
			a.stamina=10;a.A_StartSound(painsound,CHAN_AUTO);
			[bmissileevenmore,a]=A_SpawnItemEx("DudRocket",0,0,0,
				random(30,60),random(-10,10),random(-10,10),
				random(0,360),SXF_NOCHECKPOSITION|SXF_TRANSFERPOINTERS,0
			);
			dudrocket(a).isrocket=isrocket;
			return;
		}

		//damage
		//NOTE: basic impact damage calculation is ALREADY in base SlowProjectile!
		if(blockingobject){
			int dmgg=random(32,128);
			if(primed&&isrocket){
				double dangle=absangle(angle,angleto(blockingobject));
				if(dangle<20){
					dmgg+=random(200,600);
					if(hd_debug)A_Log("CRIT!");
				}else if(dangle<40)dmgg+=random(100,400);
			}
			blockingobject.damagemobj(self,target,dmgg,"Piercing");
		}

		//explosion
		if(!inthesky){
			A_SprayDecal("Scorch",16);
			A_HDBlast(
				pushradius:256,pushamount:128,fullpushradius:96,
				fragradius:HDCONST_SPEEDOFSOUND-10*stamina,fragtype:"HDB_fragRL",
				immolateradius:128,immolateamount:random(3,60),
				immolatechance:isrocket?random(1,stamina):25
			);
			actor xpl=spawn("Gyrosploder",pos-(0,0,1),ALLOW_REPLACE);
			xpl.target=target;xpl.master=master;xpl.stamina=stamina;
		}else{
			distantnoise.make(self,"world/rocketfar");
		}
		A_SpawnChunks("HDB_frag",180,100,700+50*stamina);
		
		self.setstatelabel("death");
		return;
	}
	
	states
	{
		//copied from mancubus
		death:
			MISL B 0{
				vel.z+=1.;
				A_HDBlast(
					128,66,16,"thermal",
					immolateradius:frandom(96,196),random(20,90),42,
					false
				);
				A_SpawnChunks("HDSmokeChunk",random(2,4),6,20);
				A_StartSound("misc/fwoosh",CHAN_WEAPON);
				scale=(0.9*randompick(-1,1),0.9);
			}
			MISL BBBB 1{
				vel.z+=0.5;
				scale*=1.05;
			}
			MISL CCCDDD 1{
				alpha-=0.15;
				scale*=1.01;
			}
			TNT1 A 0 A_Immolate(null,target,80);
			TNT1 AAAAAAAAAAAAAAA 4{
				A_SpawnItemEx("HDSmoke",
					random(-2,2),random(-2,2),random(-2,2),
					frandom(2,-4),frandom(-2,2),frandom(1,4),0,SXF_NOCHECKPOSITION
				);
			}stop;
	}
}