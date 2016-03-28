package com.watabou.switchhook.locations;

import com.watabou.switchhook.actors.Actor;
import com.watabou.switchhook.scenes.GameScene;
import com.watabou.switchhook.sprites.GameSprite;
import com.watabou.switchhook.sprites.LocationSprite;
import com.watabou.switchhook.ui.MapView;
import com.watabou.switchhook.utils.Sound;

class Key extends Location {
	public function new() {
		sprite = new LocationSprite( "key" );
	}

	override public function visit( a:Actor ):Void {
		if (a == Game.hero) {
			remove();

			for (loc in Game.level.locs) {
				if (Std.is( loc, LockedExit )) {
					loc.remove();

					var exit = new Exit();
					exit.pos = loc.pos;
					Game.level.locs.push( exit );

					exit.sprite.visible = Game.visited.data[exit.pos];
					MapView.instance.addLocation( exit );

					break;
				}
			}

			Sound.play( "unlock" );
			GameScene.instance.showMessage( "The exit has been unlocked" );
		}
	}
}