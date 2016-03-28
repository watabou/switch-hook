package com.watabou.switchhook.geography;

typedef Direction = {q: Int, r: Int}

class Hex {

	public static var DIR3	: Direction = {q:  1, r:  0};
	public static var DIR5	: Direction = {q:  0, r:  1};
	public static var DIR7	: Direction = {q: -1, r:  1};
	public static var DIR9	: Direction = {q: -1, r:  0};
	public static var DIR11	: Direction = {q:  0, r: -1};
	public static var DIR1	: Direction = {q:  1, r: -1};

	public static var DIRS : Array<Direction> = [DIR3, DIR5, DIR7, DIR9, DIR11, DIR1];

	public static inline var BITS_PER_COMP	: Int = 4;
	public static inline var COMP_MASK		: Int = (1 << BITS_PER_COMP) - 1;

	public var r : Int;
	public var q : Int;

	public function new( r:Int=0, q:Int=0 ) {
		this.r = q;
		this.q = r;
	}

	public inline function pack():Int {
		return q < 0 || q > COMP_MASK || r < 0 || r > COMP_MASK ? -1 : q + (r << BITS_PER_COMP);
	}

	public function offset( dir:Direction ):Hex {
		q += dir.q;
		r += dir.r;
		return this;
	}

	public static inline function unpack( value:Int ):Hex {
		return new Hex( value & COMP_MASK, value >> BITS_PER_COMP );
	}

	public static function offsetPacked( value:Int, dir:Direction ):Int {
		var q:Int = (value & COMP_MASK) + dir.q;
		var r:Int = (value >> BITS_PER_COMP) + dir.r;
		return q < 0 || q > COMP_MASK || r < 0 || r > COMP_MASK ? -1 : q + (r << BITS_PER_COMP);
	}

	public static inline function distance( h1:Hex, h2:Hex ):Int {
		return Std.int(
			(Math.abs( h1.r - h2.r ) + Math.abs( h1.q - h2.q ) + Math.abs( h1.q + h1.r - h2.q - h2.r )) / 2
		);
	}

	public static function distancePacked( p1:Int, p2:Int ):Int {
		return distance( Hex.unpack( p1 ), Hex.unpack( p2 ) );
	}
}
