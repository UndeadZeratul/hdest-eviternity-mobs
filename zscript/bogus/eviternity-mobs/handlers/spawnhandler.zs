// Struct for Enemyspawn information.
class EviternitySpawnEnemy play {

    // ID by string for spawner
    string spawnName;

    // ID by string for spawnees
    Array<EviternitySpawnEnemyEntry> spawnReplaces;

    // Whether or not to persistently spawn.
    bool isPersistent;

    // Whether or not to replace the original enemy
    bool replaceEnemy;

    string toString() {

        let replacements = "[";

        foreach (spawnReplace : spawnReplaces) replacements = replacements..", "..spawnReplace.toString();

        replacements = replacements.."]";

        return String.format("{ spawnName=%s, spawnReplaces=%s, isPersistent=%b, replaceEnemy=%b }", spawnName, replacements, isPersistent, replaceEnemy);
    }
}

class EviternitySpawnEnemyEntry play {

    string name;
    int    chance;

    string toString() {
        return String.format("{ name=%s, chance=%s }", name, chance >= 0 ? "1/"..(chance + 1) : "never");
    }
}

// One handler to rule them all.
class EviternitySpawnHandler : EventHandler {
    // List of persistent classes to completely ignore.
    // This -should- mean this mod has no performance impact.
    static const string blacklist[] = {
        'HDSmoke',
        'BloodTrail',
        'CheckPuff',
        'WallChunk',
        'HDBulletPuff',
        'HDFireballTail',
        'ReverseImpBallTail',
        'HDSmokeChunk',
        'ShieldSpark',
        'HDFlameRed',
        'HDMasterBlood',
        'PlantBit',
        'HDBulletActor',
        'HDLadderSection'
    };

    // List of Enemy-spawn associations.
    // used for Enemy-replacement on mapload.
    array<EviternitySpawnEnemy> EnemySpawnList;

    bool cvarsAvailable;

    // appends an entry to Enemyspawnlist;
    void addEnemy(string name, Array<EviternitySpawnEnemyEntry> replacees, bool persists, bool rep=true) {

        if (hd_debug) {

            let msg = "Adding "..(persists ? "Persistent" : "Non-Persistent").." Replacement Entry for "..name..": [";

            foreach (replacee : replacees) msg = msg..", "..replacee.toString();

            console.printf(msg.."]");
        }

        // Creates a new struct;
        EviternitySpawnEnemy spawnee = EviternitySpawnEnemy(new('EviternitySpawnEnemy'));

        // Populates the struct with relevant information,
        spawnee.spawnName = name;
        spawnee.isPersistent = persists;
        spawnee.replaceEnemy = rep;
        spawnee.spawnReplaces.copy(replacees);

        // Pushes the finished struct to the array.
        enemySpawnList.push(spawnee);
    }

    EviternitySpawnEnemyEntry addEnemyEntry(string name, int chance) {

        // Creates a new struct;
        EviternitySpawnEnemyEntry spawnee = EviternitySpawnEnemyEntry(new('EviternitySpawnEnemyEntry'));
        spawnee.name = name;
        spawnee.chance = chance;
        return spawnee;
    }

    // Populates the replacement and association arrays.
    void init() {

        cvarsAvailable = true;

        // --------------------
        // Enemy spawn lists.
        // --------------------

        // Annihilator
        Array<EviternitySpawnEnemyEntry> spawns_annihilator;
        spawns_annihilator.push(addEnemyEntry('Knave', annihilator_hellknight_spawn_bias));
        spawns_annihilator.push(addEnemyEntry('Baron', annihilator_baron_spawn_bias));
        addEnemy('Bogus_Annihilator', spawns_annihilator, annihilator_persistent_spawning);

        // Astral Cacodemon
        Array<EviternitySpawnEnemyEntry> spawns_astralcaco;
        spawns_astralcaco.push(addEnemyEntry('FlyZapper', astralcaco_cacodemon_spawn_bias));
        addEnemy('Bogus_AstralCacodemon', spawns_astralcaco, astralcaco_persistent_spawning);

        // Former Captain
        Array<EviternitySpawnEnemyEntry> spawns_formercaptain;
        spawns_formercaptain.push(addEnemyEntry('VulcanetteZombie', formercaptain_chaingunguy_spawn_bias));
        addEnemy('Bogus_FormerCaptain', spawns_formercaptain, formercaptain_persistent_spawning);

        // Nightmare Demon
        Array<EviternitySpawnEnemyEntry> spawns_nightmaredemon;
        spawns_nightmaredemon.push(addEnemyEntry('Babuin', nightmaredemon_babuin_spawn_bias));
        spawns_nightmaredemon.push(addEnemyEntry('SpecBabuin', nightmaredemon_specbabuin_spawn_bias));
        spawns_nightmaredemon.push(addEnemyEntry('NinjaPirate', nightmaredemon_ninjapirate_spawn_bias));
        addEnemy('Bogus_NightmareDemon', spawns_nightmaredemon, nightmaredemon_persistent_spawning);

		// -------------------------------
		// Eviternity Monster Replacements
		// -------------------------------

        // Annihilator
        Array<EviternitySpawnEnemyEntry> spawns_eviternity_annihilator;
        spawns_eviternity_annihilator.push(addEnemyEntry('Annihilator', annihilator_annihilator_spawn_bias));
        addEnemy('Bogus_Annihilator', spawns_eviternity_annihilator, annihilator_persistent_spawning);

        // Astral Cacodemon
        Array<EviternitySpawnEnemyEntry> spawns_eviternity_astralcaco;
        spawns_eviternity_astralcaco.push(addEnemyEntry('AstralCaco', astralcaco_astralcaco_spawn_bias));
        addEnemy('Bogus_AstralCacodemon', spawns_eviternity_astralcaco, astralcaco_persistent_spawning);

        // Former Captain
        Array<EviternitySpawnEnemyEntry> spawns_eviternity_formercaptain;
        spawns_eviternity_formercaptain.push(addEnemyEntry('FormerCaptain', formercaptain_formercaptain_spawn_bias));
        addEnemy('Bogus_FormerCaptain', spawns_eviternity_formercaptain, formercaptain_persistent_spawning);

        // Nightmare Demon
        Array<EviternitySpawnEnemyEntry> spawns_eviternity_nightmaredemon;
        spawns_eviternity_nightmaredemon.push(addEnemyEntry('NightmareDemon', nightmaredemon_nightmaredemon_spawn_bias));
        addEnemy('Bogus_NightmareDemon', spawns_eviternity_nightmaredemon, nightmaredemon_persistent_spawning);
    }

    // Random stuff, stores it and forces negative values just to be 0.
    bool giveRandom(int chance) {
        if (chance > -1) {
            let result = random(0, chance);

            if (hd_debug) console.printf("Rolled a "..(result + 1).." out of "..(chance + 1));

            return result == 0;
        }

        return false;
    }

    // Tries to replace the item during spawning.
    bool tryReplaceEnemy(ReplaceEvent e, string spawnName, int chance) {
        if (giveRandom(chance)) {
            if (hd_debug) console.printf(e.replacee.getClassName().." -> "..spawnName);

            e.replacement = spawnName;

            return true;
        }

        return false;
    }

    // Tries to create the Enemy via random spawning.
    bool tryCreateEnemy(Actor thing, string spawnName, int chance) {
        if (giveRandom(chance)) {
            if (hd_debug) console.printf(thing.getClassName().." + "..spawnName);

            Actor.Spawn(spawnName, thing.pos);

            return true;
        }

        return false;
    }

    override void worldLoaded(WorldEvent e) {

        // Populates the main arrays if they haven't been already.
        if (!cvarsAvailable) init();
    }

    override void checkReplacement(ReplaceEvent e) {

        // Populates the main arrays if they haven't been already.
        if (!cvarsAvailable) init();

        // If there's nothing to replace or if the replacement is final, quit.
        if (!e.replacee || e.isFinal) return;

        // If thing being replaced is blacklisted, quit.
        foreach (bl : blacklist) if (e.replacee is bl) return;

        string candidateName = e.replacee.getClassName();

        // If current map is Range, quit.
        if (level.MapName == 'RANGE') return;

        handleEnemyReplacements(e, candidateName);
    }

    override void worldThingSpawned(WorldEvent e) {

        // Populates the main arrays if they haven't been already.
        if (!cvarsAvailable) init();

        // If thing spawned doesn't exist, quit.
        if (!e.thing) return;

        // If thing spawned is blacklisted, quit.
        foreach (bl : blacklist) if (e.thing is bl) return;

        string candidateName = e.thing.getClassName();

        // If current map is Range, quit.
        if (level.MapName == 'RANGE') return;

        handleEnemySpawns(e.thing, candidateName);
    }

    private void handleEnemyReplacements(ReplaceEvent e, string candidateName) {

        // Checks if the level has been loaded more than 1 tic.
        bool prespawn = !(level.maptime > 1);

        // Iterates through the list of Enemy candidates for e.thing.
        foreach (enemySpawn : enemySpawnList) {

            if ((prespawn || enemySpawn.isPersistent) && enemySpawn.replaceEnemy) {
                foreach (spawnReplace : enemySpawn.spawnReplaces) {
                    if (spawnReplace.name ~== candidateName) {
                        if (hd_debug) console.printf("Attempting to replace "..candidateName.." with "..enemySpawn.spawnName.."...");

                        if (tryReplaceEnemy(e, enemySpawn.spawnName, spawnReplace.chance)) return;
                    }
                }
            }
        }
    }

    private void handleEnemySpawns(Actor thing, string candidateName) {

        // Checks if the level has been loaded more than 1 tic.
        bool prespawn = !(level.maptime > 1);

        // Iterates through the list of Enemy candidates for e.thing.
        foreach (enemySpawn : enemySpawnList) {

            // if currently in pre-spawn or configured to be persistent,
            // and original thing being spawned is not an owned item,
            // and not configured to replace original spawn,
            // attempt to spawn new thing.
            let item = Inventory(thing);
            if (
                (prespawn || enemySpawn.isPersistent)
             && !(item && item.owner)
             && !enemySpawn.replaceEnemy
            ) {
                foreach (spawnReplace : enemySpawn.spawnReplaces) {
                    if (spawnReplace.name ~== candidateName) {
                        if (hd_debug) console.printf("Attempting to spawn "..enemySpawn.spawnName.." with "..candidateName.."...");

                        if (tryCreateEnemy(thing, enemySpawn.spawnName, spawnReplace.chance)) return;
                    }
                }
            }
        }
    }
}
