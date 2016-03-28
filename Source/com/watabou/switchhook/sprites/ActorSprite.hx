package com.watabou.switchhook.sprites;

import com.watabou.switchhook.actors.Actor;
import com.watabou.switchhook.actors.Hero;
import com.watabou.switchhook.effects.Blood;
import com.watabou.switchhook.sprites.GameSprite;
import com.watabou.switchhook.ui.HPIndicator;
import com.watabou.switchhook.ui.MapView;
import com.watabou.switchhook.utils.Updater;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.geom.Point;
import msignal.Signal.Signal0;

class ActorSprite extends GameSprite {

	private static inline var TIME_TO_MOVE		: Float = 0.2;
	private static inline var TIME_TO_ATTACK	: Float = 0.3;

	private var motion	: Float;
	private var step	: Int;
	private var cx		: Float;
	private var cy		: Float;
	private var dx		: Float;
	private var dy		: Float;

	private var bmpIdl	: Bitmap;
	private var bmpAtk	: Bitmap;

	public var dir	: Float = 1;

	public var health	: HPIndicator;

	public var actor	: Actor;

	public var arrival	: Signal0 = new Signal0();

	public function new( actor:Actor, src:String ) {
		super( src );

		bmpIdl = bmp;
		var srcAttack = src + "_attack";
		if (Assets.exists( srcAttack, AssetType.IMAGE )) {
			bmpAtk = new Bitmap( Assets.getBitmapData( srcAttack ) );
			bmpAtk.x = Std.int( -bmpAtk.width / 2 );
			bmpAtk.y = -bmpAtk.height;
			addChild( bmpAtk );
		} else {
			bmpAtk = bmpIdl;
		}
		showState( false );

		this.actor = actor;

		if (!Std.is( actor, Hero )) {
			health = new HPIndicator( actor );
			health.x = -health.width / 2;
			health.y = -6;
			addChild( health );
		}
	}

	public function turn( x:Float ):Void {
		if (x > this.x) {
			dir = 1;
		} else if (x < this.x) {
			dir = -1;
		}
		for (bmp in [bmpIdl, bmpAtk]) {
			bmp.scaleX = dir;
			bmp.x = Std.int( -dir * Math.abs( bmp.width ) / 2 );
		}
	}

	public function hit():Void {
		var blood = new Blood( actor != Game.hero );
		blood.x = x;
		blood.y = y - MapView.H / 2;
		parent.addChild( blood );
	}

	public function move( from:Int, to:Int ):Void {
		step = to;

		cx = x;
		cy = y;
		var p = MapView.tileBottom( step );
		dx = p.x - cx;
		dy = p.y - cy;

		turn( p.x );

		motion = 0;
		Updater.tick.add( onMove );
	}

	private function onMove( elapsed:Float ):Void {
		if ((motion += elapsed / TIME_TO_MOVE) >= 1) {

			Updater.tick.remove( onMove );
			actor.finishStep( step );
			arrival.dispatch();

		} else {

			x = cx + dx * motion;
			y = cy + dy * motion;

		}
	}

	public function attack( from:Int, to:Int ):Void {

		cx = x;
		cy = y;
		var p = MapView.tileBottom( to );
		dx = p.x - cx;
		dy = p.y - cy;

		turn( p.x );

		motion = 0;
		Updater.tick.add( onAttack );
	}

	private function onAttack( elapsed:Float ):Void {
		if ((motion += elapsed / TIME_TO_ATTACK) >= 1) {

			Updater.tick.remove( onAttack );
			actor.place( actor.pos );
			arrival.dispatch();

		} else {

			x = cx + dx * (0.5 - Math.abs( motion - 0.5 ));
			y = cy + dy * (0.5 - Math.abs( motion - 0.5 ));

		}
	}

	public function showState( attack:Bool ):Void {
		if (attack) {
			bmpIdl.visible = false;
			bmpAtk.visible = true;
		} else {
			bmpAtk.visible = false;
			bmpIdl.visible = true;
		}
	}

	public function die():Void {
		Updater.tick.remove( onMove );
		Updater.tick.remove( onAttack );
		Updater.tick.remove( onSpawn );

		bmp.smoothing = true;
		bmp.y += bmp.height / 2;
		y -= bmp.height / 2;

		Updater.tick.add( onDie );
	}

	private function onDie( elapsed:Float ):Void {
		if ((alpha -= elapsed * 5) > 0) {
			scaleY = 0.8 + alpha * 0.2;
			scaleX = scaleX > 0 ? scaleY : -scaleY;
		} else {
			parent.removeChild( this );
			Updater.tick.remove( onDie );
		}
	}


	public var displayed(get, set) : Bool;
	private var _displayed : Bool = true;
	private function get_displayed():Bool {
		return _displayed;
	}
	private function set_displayed( value:Bool ):Bool {
		if (parent != null) {
			if (value != _displayed) {
				if (value) {
					spawn();
				} else {
					despawn();
				}
			}
		} else {
			alpha = 0;
		}

		return (_displayed = value);
	}

	public function spawn() {
		alpha = 0;
		Updater.tick.remove( onDespawn );
		Updater.tick.add( onSpawn );
	}

	private function onSpawn( elapsed:Float ):Void {
		if ((alpha += elapsed  / TIME_TO_MOVE) >= 1) {
			Updater.tick.remove( onSpawn );
		}
	}

	public function despawn() {
		alpha = 1;
		Updater.tick.remove( onSpawn );
		Updater.tick.add( onDespawn );
	}

	private function onDespawn( elapsed:Float ):Void {
		if ((alpha -= elapsed  / TIME_TO_MOVE) <= 0) {
			Updater.tick.remove( onDespawn );
		}
	}
}
