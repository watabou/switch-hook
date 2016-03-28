package com.watabou.switchhook.actors;

import com.watabou.switchhook.actors.actions.Action;
import com.watabou.switchhook.actors.actions.Input;
import com.watabou.switchhook.actors.actions.Motion;
import com.watabou.switchhook.actors.actions.SwitchHook;
import com.watabou.switchhook.geography.HexMap;
import com.watabou.switchhook.geography.PathFinder;
import com.watabou.switchhook.locations.Tombstone;
import com.watabou.switchhook.scenes.GameScene;
import com.watabou.switchhook.sprites.ActorSprite;
import com.watabou.switchhook.ui.MapView;
import com.watabou.switchhook.utils.Sound;

class Hero extends Actor {

	private var dest : Int = -1;
	private var nextAction	: Action = null;

	public function new( saved:Dynamic=null ) {
		super();

		if (saved != null) {
			hp = saved.hp;
			ht = saved.ht;
			pos = saved.pos;
		} else {
			hp = ht = 2;
		}

		sprite = new ActorSprite( this, "hero" );
	}

	override public function place( pos:Int ):Void {
		super.place( pos );

		observe();
		GameScene.instance.adjustViewport();
	}

	override public function observe():Void {
		super.observe();
		GameScene.instance.updateVisibility();
	}

	override public function act():Action {

		if (nextAction != null) {
			var action = nextAction;
			nextAction = null;
			return action;
		}

		var noMobsInSight = true;
		for (mob in Game.level.mobs) {
			if (Game.visible.data[mob.pos] && !mob.isPassive()) {
				noMobsInSight = false;
				break;
			}
		}

		if (noMobsInSight && pos != dest && dest != -1) {
			var step = makeStep();
			return isAlive() ?
				(step != null ? step : new Input()) :
				null;
		} else {
			return new Input();
		}
	}

	public function handle( pos:Int ):Void {

		if (pos == this.pos) {
			return;
		}

		var enemy = Actor.get( pos );
		if (Game.visible.data[pos] && enemy != null) {
			dest = -1;
			nextAction = new SwitchHook( this, cast(enemy, Monster) );
		} else {
			dest = pos;
			nextAction = makeStep();
		}

		if (nextAction != null) {
			Action.remove( Input.instance );
		}
	}

	private function makeStep():Action {

		var passable = Game.level.empty.clone();
		for (m in Game.level.mobs) {
			if (Game.visible.data[m.pos]) {
				passable.data[m.pos] = false;
			}
		}
		for (i in 0...HexMap.LENGTH) {
			passable.data[i] = passable.data[i] && Game.visited.data[i];
		}

		var step = PathFinder.step( pos, dest, passable.data );

		if (step != -1 && passable.data[step]) {
			return new Motion( this, step );
		} else {
			dest = -1;
			return null;
		}
	}

	override public function finishStep( pos:Int ):Void {
		super.finishStep( pos );

		Sound.play( "step", sprite, 0.5 + Math.random() * 0.5 );

		for (loc in Game.level.locs) {
			if (loc.pos == pos) {
				loc.visit( this );
			}
		}

		if (pos == dest) {
			dest = -1;
		}
	}

	override public function die():Void {

		Sound.play( "death", sprite );

		super.die();
		GameScene.instance.showAll();
		GameScene.instance.addTryButton();

		var tomb = new Tombstone();
		tomb.pos = pos;
		Game.level.locs.push( tomb );
		MapView.instance.addLocation( tomb );

		dest = -1;

		Game.clear();
	}

	public function spawn():Void {
		dest = -1;
		pos = Game.level.start;
	}

	public function save():Dynamic {
		return {
			hp	: hp,
			ht	: ht,
			pos	: pos
		}
	}

	public function interrupt():Bool {
		if (dest != -1) {
			dest = -1;
			return true;
		} else {
			return false;
		}
	}
}
