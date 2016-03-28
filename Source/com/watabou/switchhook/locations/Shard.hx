package com.watabou.switchhook.locations;

import com.watabou.switchhook.actors.Actor;
import com.watabou.switchhook.scenes.GameScene;
import com.watabou.switchhook.sprites.GameSprite;
import com.watabou.switchhook.sprites.LocationSprite;
import com.watabou.switchhook.utils.Sound;

class Shard extends Location {
	public function new() {
		sprite = new LocationSprite( "shard" );
	}

	override public function visit( a:Actor ):Void {
		if (a == Game.hero) {
			remove();
			if (Game.hero.hp == Game.hero.ht) {
				Game.hero.ht++;
			}
			Game.hero.hp++;
			Game.hero.health.dispatch();

			Sound.play( "heal" );
			GameScene.instance.showMessage( "Your health increased" );
		}
	}
}