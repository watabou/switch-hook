package com.watabou.switchhook.ui;

import com.watabou.switchhook.actors.Actor;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;

class HPIndicator extends Sprite {

	private var actor	: Actor;

	private static var light	: BitmapData;
	private static var dark		: BitmapData;

	public function new( actor:Actor ) {
		super();

		if (light == null) {
			light = new BitmapData( 1, 1, true, 0xffff3333 );
		}

		if (dark == null) {
			dark = new BitmapData( 1, 1, true, 0xff3d3940 );
		}

		this.actor = actor;
		actor.health.add( onChanged );
		onChanged();
	}

	private function onChanged():Void {
		update();
		visible =  actor.hp < actor.ht;
	}

	private function update():Void {

		removeChildren();

		for (i in 0...actor.hp) {
			var bmp = new Bitmap( light );
			bmp.scaleX = bmp.scaleY = 4;
			bmp.x = i * 6;
			addChild( bmp );
		}
		for (i in actor.hp...actor.ht) {
			var bmp:Bitmap = new Bitmap( dark );
			bmp.scaleX = bmp.scaleY = 4;
			bmp.x = i * 6;
			addChild( bmp );
		}
	}
}
