package com.watabou.switchhook.sprites;

import com.watabou.switchhook.utils.Updater;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.events.Event;

class LocationSprite extends GameSprite {
	private var particles : Array<Bitmap> = [];

	private var bmpW : Float;
	private var bmpH : Float;

	public function new( src:String ) {
		super( src );

		bmpW = bmp.width;
		bmpH = bmp.height;

		addEventListener( Event.ADDED_TO_STAGE, onAdded );
		addEventListener( Event.REMOVED_FROM_STAGE, onRemoved );
	}

	private function onAdded( e:Event ):Void {
		Updater.tick.add( onUpdate );
	}

	private function onRemoved( e:Event ):Void {
		Updater.tick.remove( onUpdate );
	}

	private function onUpdate( elapsed:Float ):Void {

		for (p in particles) {
			p.y -= elapsed * 20;
			if ((p.alpha -= elapsed) <= 0) {
				p.parent.removeChild( p );
				particles.remove( p );
			}
		}

		if (visible && Math.random() < elapsed * 10) {
			var x, y, c : Int;
			do {
				x = Std.int( Math.random() * bmpW );
				y = Std.int( Math.random() * bmpH );
				c = bmp.bitmapData.getPixel32( x, y );
			} while ((c & 0xFF000000) == 0);

			var p = new Bitmap( new BitmapData( 1, 1, true, c ) );
			p.x = x - bmpW / 2;
			p.y = y - bmpH;
			p.scaleX = p.scaleY = 4;
			p.rotation = 45;
			p.blendMode = BlendMode.ADD;
			particles.push( p );
			addChild( p );
		}
	}
}
