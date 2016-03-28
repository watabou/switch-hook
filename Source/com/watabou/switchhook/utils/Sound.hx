package com.watabou.switchhook.utils;

import openfl.Assets;
import openfl.display.DisplayObject;
import openfl.geom.Point;
import openfl.media.SoundTransform;
import openfl.net.SharedObject;

class Sound {

	private static var so : SharedObject;
	private static var _on : Bool;

	public static var on(get, set): Bool;
	private static function get_on():Bool {
		if (so == null) {
			so = SharedObject.getLocal( "settings" );
			_on = (so.data.sfx != false);
		}
		return _on;
	}
	private static function set_on( value:Bool ):Bool {
		if (so == null) {
			so = SharedObject.getLocal( "settings" );
		}
		return so.data.sfx = _on = value;
	}

	public static function play( id:String, src:DisplayObject=null, vol:Float=1 ):Void {
		if (!_on) {
			return;
		}

		var sound = Assets.getSound( id );
		if (sound != null) {
			var pan = 0.0;
			if (src != null) {
				var x = src.localToGlobal( new Point() ).x;
				var w = src.stage.stageWidth;
				pan = (x - w) / w * 2 + 1;
			}
			sound.play( 0, 0, new SoundTransform( vol, pan ) );
		}
	}
}
