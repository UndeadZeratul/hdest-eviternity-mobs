class Bogus_FormerCorporal : ZombieStormtrooper {

    default {
        //$Category "Monsters/Hideous Destructor"
        //$Title "Former Corporal"
        //$Sprite "FCRPA1"

        seesound "formerCorporal/sight";
        painsound "formerCorporal/pain";
        deathsound "formerCorporal/death";
        activesound "formerCorporal/active";
        tag "$TAG_FORMERCORPORAL";

        translation 0;
        speed 8;
        dropitem "";attacksound "";decal "BulletScratch";
        painchance 250;
        obituary "$OB_FORMERCORPORAL";
        hitobituary "$OB_FORMERCORPORAL_HIT";
        accuracy 0;
    }

    override void postBeginPlay() {

        // Prevent cascading changes in super calls
        accuracy = 0;
        user_weapon = 0;

        super.postBeginPlay();

        // Ensure Semi-Auto only
        firemode = 0;

        // Prevent Zombiemen Translations
        translation = "";
    }

    // TODO: Implement Death Drops
    override void deathdrop() {
        if(bHASDROPPED && bFRIENDLY) return;
        
        DropNewItem("HDHandgunRandomDrop");
    }

    states {
        spawn:
            FCRP A 0;
        idle:
        spawn2:
            #### A 0 A_HDLook();
            #### A 0 A_Recoil(frandom(-0.1, 0.1));
            #### EEE 1 {
                A_SetTics(random(5, 17));
                A_HDLook();
            }
            #### E 1 {
                A_Recoil(frandom(-0.1, 0.1));
                A_SetTics(random(10, 40));
            }
            #### B 0 A_Jump(28, "spawngrunt");
            #### B 0 A_Jump(132, "spawnswitch");
            #### B 8 A_Recoil(frandom(-0.2, 0.2));
            loop;

        spawngrunt:
            #### G 1{
                A_Recoil(frandom(-0.4, 0.4));
                A_SetTics(random(30, 80));

                if (!random(0, 7)) A_Vocalize(activesound);
            }
            #### A 0 A_Jump(256, "spawn2");
        spawnswitch:
            #### A 0 A_JumpIf(bAMBUSH, "spawnstill");
            goto spawnwander;

        spawnstill:
            #### A 0 A_HDLook();
            #### A 0 A_Recoil(random(-1, 1) * 0.4);
            #### CD 5 A_SetAngle(angle + random(-4, 4));
            #### A 0 {
                A_HDLook();

                if (!random(0, 127)) A_Vocalize(activesound);
            }
            #### AB 5 A_SetAngle(angle + random(-4, 4));
            #### B 1 A_SetTics(random(10, 40));
            goto spawn2;

        spawnwander:
            #### CDAB 5 A_HDWander();
            #### A 0 {
                if (!random(0,127)) A_Vocalize(activesound);
                A_HDLook();
            }
            #### A 0 A_Jump(64, "spawn2");
            loop;

        missile:
            #### A 0 A_JumpIf(!target, "spawn2");
            #### A 0 {
                double dt = distance3D(target);
                if(dt > 200 && dt < 1000 && !random(0,39)) setstatelabel("frag");
            }
            #### ABCD 3 A_TurnToAim(40, shootstate: "aiming");
            loop;

        aiming:
            #### E 3 A_FaceLastTargetPos(30);
            #### E 1 A_StartAim(maxspread: 20, maxtics: random(0, 35));
            #### E 0 A_JumpIf(
                HDMobAI.TryShoot(self, 32, 512, 0, 0, flags: HDMobAI.TS_GEOMETRYOK) || random(0, 2),
                "shoot"
            );
            goto see;

        shoot:
            #### E 0 A_JumpIf(jammed, "jammed");
            #### E 0 {
                pitch += frandom(-spread, spread);
                angle += frandom(-spread, spread);
            }
        fire:
            #### F 0 A_JumpIf(mag < 1, "ohforfuckssake");
            #### F 1 bright light("SHOT") {
                    A_StartSound("weapons/rifle", CHAN_WEAPON);
                    HDBulletActor.FireBullet(self, "HDB_426");

                    if (random(0, 2000) < firemode) {
                        jammed = true;
                        A_StartSound("weapons/rifleclick", 5);
                        setstatelabel("jammed");
                    }

                    pitch += frandom(-spread, spread * 0.5) * 0.3;
                    angle += frandom(-spread * 0.5, spread) * 0.3;

                mag--;
            }
        postshot:
            #### E 5 {
                if (!random(0, 127)) A_Vocalize(activesound);
                
                if (mag < 1) {
                    setstatelabel("reload");
                    return;
                }

                spread = max(0, spread - 1);

                A_SetTics(random(2, 6));
            }
            #### E 3;
            #### E 0 A_JumpIf(!HDMobAI.tryShoot(self), "see");
            #### E 0 A_JumpIfTargetInLOS(1);
            goto coverfire;  //even if not in los,occasionally keep shooting anyway
            #### E 3 A_FaceTarget(10, 10);
            #### E 0 A_Jump(30, "see");  //even if in los,occasionally stop shooting anyway
            goto coverfire;

        coverfire:
            #### E 1 {
                spread = 2;
                A_Coverfire();
                A_SetTics(random(2,6));
            }
            wait;

        frag:
            #### A 10 A_Vocalize(seesound);
            #### A 20 {
                A_StartSound("weapons/pocket", CHAN_WEAPON);
                A_FaceTarget(0, 0);
                pitch -= frandom(20, 40);
            }
            #### A 10 {
                A_SpawnItemEx(
                    "HDFragSpoon",
                    cos(pitch) * 4, -1, height - 6 - sin(pitch) * 4,
                    cos(pitch) * cos(angle) * 4 + vel.x, cos(pitch) * sin(angle) * 4 + vel.y, sin(-pitch) * 4 + vel.z,
                    0,
                    SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
                );
                A_ZomFrag();
            }
            #### A 0 A_JumpIf(mag < 1, "reload");
            goto see;

        jammed:
            #### E 8;
            #### E 0 A_Jump(128,"see");
            #### E 4 A_Vocalize(random(0, 2) ? seesound : painsound);
            goto see;

        ohforfuckssake:
            #### E 8;
        reload:
            #### A 0 A_JumpIf(mag < 0, "unloadedreload");
            #### A 4 A_StartSound("weapons/rifleclick2");
            #### AA 1 A_HDChase("melee", null, flags: CHF_FLEE);
            #### A 0 {
                A_StartSound("weapons/rifleunload");
                HDMagAmmo.SpawnMag(self, "HD4mMag", 0);
                mag=-1;
            }
        unloadedreload:
            #### BCD 2 A_HDChase("melee", null, flags: CHF_FLEE);
            #### E 12 A_StartSound("weapons/pocket", 8);
            #### E 8 A_StartSound("weapons/rifleload", 9);
            #### E 2 {
                A_StartSound("weapons/rifleclick2", 8);
                mag = 50;
            }
            #### CCBB 2 A_HDWander();

        see:
        see2:
            #### A 0 A_JumpIf(!jammed && mag < 1, "reload");
            #### ABCD 4 A_HDChase();
            #### A 0 {
                spread = 2;
            }
            #### A 0 A_JumpIfTargetInLOS("see");
            #### A 0 A_Jump(24, "roam");
            loop;

        roam:
            #### E 3 A_Jump(60, "roam2");
            #### E 0 {
                spread = 1;
            }
            #### E 4 A_Watch();
            #### E 0 {
                spread = 0;
            }
            #### EEE 4 A_Watch();
            #### A 0 A_Jump(60, "roam");
        roam2:
            #### A 0 A_Jump(8, "see");
            #### ABCD 6 A_HDChase(speedmult: 0.6);
            #### A 0 A_Jump(140, "roam");
            #### A 0 A_JumpIfTargetInLOS("see");
            loop;

        pain:
            #### G 2;
            #### G 3 A_Vocalize(painsound);
            #### G 0 A_ShoutAlert(0.1, SAF_SILENT);
            #### G 0 A_JumpIf(target && distance3D(target) < 100, "see");
            #### ABCD 2 A_HDChase(flags: CHF_FLEE);
            goto see;

        death:
            #### H 5;
            #### I 5 A_Vocalize(deathsound);
            #### JK 5;
        dead:
            #### K 3 A_JumpIf(abs(vel.z) < 2.0, 1);
            #### L 5 canraise A_JumpIf(abs(vel.z) >= 2.0, "dead");
            wait;
        raise:
            #### L 4 {
                jammed = false;
            }
            #### LK 6;
            #### JIH 4;
            goto see;

        gib:
            #### M 5;
            #### N 5 {
                A_GibSplatter();
                A_XScream();
            }
            #### OP 5 A_GibSplatter();
            #### QRST 5;
        gibbed:
            #### T 3 canraise A_JumpIf(abs(vel.z) < 2.0, 1);
            #### U 5 canraise A_JumpIf(abs(vel.z) >= 2.0, "gibbed");
            wait;

        ungib:
            #### U 12;
            #### T 8;
            #### SRQ 6;
            #### PONM 4;
            goto pain;
    }
}