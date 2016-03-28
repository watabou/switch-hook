package com.watabou.switchhook.geography;

import com.watabou.switchhook.geography.Hex.Direction;

class HexMap {

	public static inline var SIZE	: Int = 1 << Hex.BITS_PER_COMP;
	public static inline var LENGTH	: Int = SIZE * SIZE;
	public static inline var CENTER	: Int = Std.int( (SIZE / 2) * (SIZE + 1) );

	public static var blobness	: Float = 0.3;

    public var data	: Array<Bool>;

	public function new( data=null ) {
		this.data = data != null ? data : [for (i in 0...LENGTH) false];
	}

	public function clone():HexMap {
		return new HexMap( [for (v in data) v] );
	}

	public function fill( value:Bool ):Void {
		for (i in 0...LENGTH) {
			data[i] = value;
		}
	}

	public function floodFill( pos:Int, ?result:HexMap ):HexMap {

		if (result == null) {
			result = new HexMap();
		}

		result.data[pos] = true;
		for (dir in Hex.DIRS) {
			var n:Int = Hex.offsetPacked( pos, dir );
			if (n != -1 && data[n] && !result.data[n]) {
				floodFill( n, result );
			}
		}

		return result;
	}

	public function noise( threshold:Float ):Void {
		for (i in 0...LENGTH) {
			data[i] = Math.random() < threshold;
		}
	}

	public function blur():Void {
		var result:Array<Bool> = new Array<Bool>();
		for (i in 0...LENGTH) {
			var checked = 0;
			var total = 0;
			for (dir in Hex.DIRS) {
				var n:Int = Hex.offsetPacked( i, dir );
				if (n != -1) {
					total++;
					if (data[n]) {
						checked++;
					}
				}
			}
			result[i] = (checked > total / 2);
		}
		data = result;
	}

	public function grow( pos:Int, gen:Int, dir:Direction ):Void {

		data[pos] = true;

		if (Math.random() * gen <= 1) {
			return;
		}

		gen--;

		for (d in Hex.DIRS) {
			if (Math.random() < blobness || d == dir) {
				var n:Int = Hex.offsetPacked( pos, d );
				if (n != -1 && !data[n]) {
					grow( n, gen, d );
				}
			}
		}
	}

	public function square():Int {
		var s:Int = 0;
		for (i in data) {
			if (i) {
				s++;
			}
		}
		return s;
	}

	public function random( value:Bool ):Int {
		while (true) {
			var tile = Std.int( Math.random() * LENGTH );
			if (data[tile] == value) {
				return tile;
			}
		}
	}

	public static function randomDir():Direction {
		return Hex.DIRS[Std.int( Math.random() * Hex.DIRS.length )];
	}
}
