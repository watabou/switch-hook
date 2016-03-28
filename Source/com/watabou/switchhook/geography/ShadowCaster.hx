package com.watabou.switchhook.geography;

class ShadowCaster {

	public static var fov	: Array<Bool> = null;

	private static var fResult	: Array<Float>;
	private static var tResult	: Array<Float>;
	private static var fCurrent	: Array<Float>;
	private static var tCurrent	: Array<Float>;

	public static function reset():Void {
		if (fov == null) {
			fov = [for (i in 0...HexMap.LENGTH) false];
		} else {
			for (i in 0...HexMap.LENGTH) {
				fov[i] = false;
			}
		}
	}

	public static function observe( pos:Int, r:Int, lb:Array<Bool>, reset:Bool=true ):Void {

		if (reset) {
			ShadowCaster.reset();
		}

		// The center of the FOV is always visible
		fov[pos] = true;

		fResult = [];
		tResult = [];

		for (d in 1...r+1) {

			fCurrent = [];
			tCurrent = [];

			var p = Hex.unpack( pos );
			for (i in 0...d) {
				p.offset( Hex.DIR11 );
			}

			var span = 1 / (d * 6) / 2;

			for (i in 0...Hex.DIRS.length) {
				for (j in 0...d) {
					var packed = p.pack();
					if (packed != -1) {
						var a = (i * d + j) / (d * 6);
						fov[packed] = !blocked( a );
						// we can try to check not only central point of a hex,
						// but also its "edges"; in this case add 2 more checks
						// || !blocked( a-span >= 0 ? a-span : 1+a-span ) || !blocked( a+span <= 1 ? a+span : a+span-1 )
						if (lb[packed]/* && fov[packed]*/) {
							var f = a - span;
							var t = a + span;
							if (f >= 0) {
								fCurrent.push( f );
								tCurrent.push( t );
							} else {
								fCurrent.push( f );
								tCurrent.push( t );
								fCurrent.push( 1 + f );
								tCurrent.push( 1 + t );
							}
						}
					}
					p.offset( Hex.DIRS[i] );
				}
			}

			merge();


			if (fResult.length >= 1 && tResult[0]-fResult[0] >= 1) {
				break;
			}
		}
	}

	private static inline var delta:Float = 0.00001;

	private static function blocked( a:Float ):Bool {
		for (i in 0...fResult.length) {
			if (a-delta >= fResult[i] && a+delta <= tResult[i]) {
				return true;
			}
		}
		return false;
	}

	private static function merge():Void {

		fResult = fResult.concat( fCurrent );
		tResult = tResult.concat( tCurrent );

		// FIXME
		var merged:Bool;
		do {
			merged = false;
			for (i in 1...fResult.length) {
				var f = fResult[i];
				var t = tResult[i];
				for (j in 0...i) {
					if (f >= (fResult[j] - delta) && f <= (tResult[j] + delta)) {
						tResult[j] = Math.max( t, tResult[j] );
						fResult.splice( i, 1 );
						tResult.splice( i, 1 );
						merged = true;
						break;
					} else
					if (t >= (fResult[j] - delta) && t <= (tResult[j] + delta)) {
						fResult[j] = Math.min( f, fResult[j] );
						fResult.splice( i, 1 );
						tResult.splice( i, 1 );
						merged = true;
						break;
					}
				}
				if (merged) {
					break;
				}
			}
		} while (merged);
	}
}

