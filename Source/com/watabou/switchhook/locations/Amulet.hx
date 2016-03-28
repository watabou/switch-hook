package com.watabou.switchhook.locations;

import com.watabou.switchhook.actors.Actor;
import com.watabou.switchhook.actors.Monster;
import com.watabou.switchhook.scenes.GameScene;
import com.watabou.switchhook.sprites.GameSprite;
import com.watabou.switchhook.utils.Sound;

class Amulet extends Location {
	public function new() {
		sprite = new GameSprite( "amulet" );
	}

	override public function visit( a:Actor ):Void {
		if (a == Game.hero) {
			remove();
			GameScene.instance.addVictoryBanner();

			Sound.play( "win" );

			while (Game.level.mobs.length > 0) {
				var mob:Monster = Game.level.mobs[0];
				mob.damage( mob.hp );
			}

			Game.clear();
			Game.victory = true;
		}
	}
}
