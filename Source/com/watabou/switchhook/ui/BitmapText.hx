package com.watabou.switchhook.ui;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.PixelSnapping;
import openfl.geom.ColorTransform;
import openfl.geom.Point;

class BitmapText extends Bitmap {

	private var font	: BitmapFont;

	private var _text	: String = "";

	public function new( font:BitmapFont, text:String="", color:ColorTransform=null ) {

		super( null, PixelSnapping.ALWAYS, false );

		this.font = font;
		this.text( text );

		if (color != null) {
			transform.colorTransform = color;
		}
	}

	public function text( value:String ):Void {
		if (_text != value) {
			_text = value;
			update();
		}
	}

	private function update():Void {
		if (bitmapData != null) {
			bitmapData.dispose();
		}

		var length = _text.length;
		var width = 0;
		var height = 0;
		for (i in 0...length) {
			var rect = font.table[_text.charAt( i )];
			width += Std.int( rect.width );
			height = Std.int( Math.max( height, rect.height ) );
		}

		if (length > 0) {
			width += font.tracking * (length-1);
		}

		bitmapData = new BitmapData( width, height, true, 0x00000000 );
		var pos = new Point();
		for (i in 0...length) {
			var rect = font.table[_text.charAt( i )];
			bitmapData.copyPixels( font.bitmapData, rect, pos, null, null, true );
			pos.x += rect.width + font.tracking;
		}
	}

	public function baseLine():Int {
		return font.baseLine;
	}

	public static function split(font:BitmapFont, text:String, width:Int ):Array<BitmapText> {
		var result:Array<BitmapText> = [];

		var words = text.split( " " );
		while (words.length > 0) {

			var word = words.shift();
			var line = word;
			var bmpLine:BitmapText = new BitmapText( font, line );

			while (words.length > 0) {
				word = words.shift();
				bmpLine = new BitmapText( font, line + " " + word );
				if (bmpLine.width <= width) {
					line += " " + word;
				} else {
					break;
				}
			}

			if (bmpLine.width > width) {
				words.unshift( word );
				bmpLine = new BitmapText( font, line );
			}
			result.push( bmpLine );
		}

		return result;
	}
}
