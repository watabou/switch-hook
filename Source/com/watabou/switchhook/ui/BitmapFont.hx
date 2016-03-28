package com.watabou.switchhook.ui;

import openfl.Assets;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;

class BitmapFont {
	
	public static var LATIN_FULL : String =
		" !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~\u007F";

	private static inline var COLOR	: Int = 0x00000000;

	public var bitmapData	: BitmapData;

	public var table	: Map<String, Rectangle>;

	public var tracking		: Int = 0;
	public var baseLine		: Int;
	public var lineHeight	: Int;

	public function new( src:String, chars:String ) {

		bitmapData = Assets.getBitmapData( src );
		table = new Map<String, Rectangle>();

		var length = chars.length;

		var width = bitmapData.width;
		var height = bitmapData.height;

		var pos = 0;
		for (i in 0...width) {
			var broken = false;
			for (j in 0...height) {
				if (bitmapData.getPixel( i, j ) != COLOR) {
					broken = true;
					pos = i;
					break;
				}
			}
			if (broken) {
				break;
			}
		}
		table[" "] = new Rectangle( 0, 0, --pos, height );

		for (i in 0...length) {

			var ch = chars.charAt( i );
			if (ch == " ") {
				continue;
			} else {

				var blankColumn:Bool;
				var separator = pos;

				do {
					if (++separator >= width) {
						break;
					}
					blankColumn = true;
					for (j in 0...height) {
						if (bitmapData.getPixel32( separator, j ) != COLOR) {
							blankColumn = false;
							break;
						}
					}
				} while (!blankColumn);

				table[ch] = new Rectangle( pos, 0, separator - pos, height );
				pos = separator + 1;
			}
		}

		lineHeight = baseLine = height;
	}
}
