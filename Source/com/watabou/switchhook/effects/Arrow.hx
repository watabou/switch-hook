package com.watabou.switchhook.effects;

import com.watabou.switchhook.actors.Actor;
import com.watabou.switchhook.ui.MapView;
import com.watabou.switchhook.utils.Updater;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import msignal.Signal.Signal0;

class Arrow extends Sprite {

	private static inline var DELAY_PER_PIXEL	: Float = 0.003;

	public var hit	: Signal0 = new Signal0();

	private var length	: Float;
	private var pos	: Float;

	private var bmp	: Bitmap;

	public function new( a1:Actor, a2:Actor ) {
		super();

		bmp = new Bitmap( Assets.getBitmapData( "arrow" ) );
		bmp.smoothing = true;
		addChild( bmp );

		x = a1.sprite.x;
		y = a1.sprite.y - MapView.H / 2;
		var dx = a2.sprite.x - x;
		var dy = (a2.sprite.y - MapView.H / 2) - y;
		rotation = Math.atan2( dy, dx ) / Math.PI * 180;
		length = Math.sqrt( dx * dx + dy * dy ) - bmp.width;
		pos = 0;

		a1.sprite.turn( a2.sprite.x );

		MapView.instance.addChild( this );

		Updater.tick.add( onAdvance );
	}

	private function onAdvance( elapsed:Float ):Void {
		pos += elapsed / DELAY_PER_PIXEL;
		if (pos >= length) {
			Updater.tick.remove( onAdvance );
			parent.removeChild( this );
			hit.dispatch();
		} else {
			bmp.x = pos;
		}
	}
}
