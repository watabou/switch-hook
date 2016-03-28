package com.watabou.switchhook.effects;

import com.watabou.switchhook.actors.Actor;
import com.watabou.switchhook.sprites.ActorSprite;
import com.watabou.switchhook.ui.MapView;
import com.watabou.switchhook.utils.Updater;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.geom.Matrix;
import msignal.Signal.Signal0;


class HookThrow extends Sprite {

	private static inline var DELAY_PER_PIXEL	: Float = 0.005;

	private var a1	: Actor;
	private var a2	: Actor;

	private var grapple	: Bitmap;

	private var bmp	: BitmapData;
	private var m	: Matrix;

	private var length	: Float;
	private var pos		: Float;

	public var switched	: Signal0 = new Signal0();

	public function new( a1:Actor, a2:Actor ) {
		super();

		this.a1 = a1;
		this.a2 = a2;

		a1.sprite.turn( a2.sprite.x );

		grapple = new Bitmap( Assets.getBitmapData( "grapple" ) );
		grapple.smoothing = true;
		grapple.y = - 1;
		addChild( grapple );

		bmp = Assets.getBitmapData( "chain" );
		m = new Matrix();

		x = a1.sprite.x;
		y = a1.sprite.y - MapView.H / 2;
		var dx = a2.sprite.x - x;
		var dy = (a2.sprite.y - MapView.H / 2) - y;
		rotation = Math.atan2( dy, dx ) / Math.PI * 180;
		length = Math.sqrt( dx * dx + dy * dy );
		pos = 0;

		Updater.tick.add( onExtend );
	}

	private function onExtend( elapsed:Float ):Void {
		pos += elapsed / DELAY_PER_PIXEL;
		if (pos >= length) {
			Updater.tick.remove( onExtend );
			parent.removeChild( this );
			switched.dispatch();

		} else {
			grapple.x = pos;

			m.tx = pos;
			graphics.clear();
			graphics.beginBitmapFill( bmp, m, true, true );
			graphics.drawRect( 0, -1, pos, 4 );
		}
	}
}
