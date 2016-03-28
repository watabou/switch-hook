package com.watabou.switchhook.geography;

class PathFinder {

	private static inline var LENGTH : Int = HexMap.LENGTH;

	public static inline var UNREACHABLE : Int = 0xFFFF;

	private static var distance	: Array<Int>;
	private static var queue	: Array<Int>;

	private static function buildDistanceMap( from:Int, to:Int, passable:Array<Bool> ):Bool {

		if (from == to) {
			return false;
		}

		if (distance == null) {
			distance = [for (i in 0...LENGTH) UNREACHABLE];
		} else {
			for (i in 0...LENGTH) {
				distance[i] = UNREACHABLE;
			}
		}

		var pathFound = false;

		var head = 0;
		var tail = 0;

		if (queue == null) {
			queue = [for (i in 0...LENGTH) 0];
		}

		// Add to queue
		queue[tail++] = to;
		distance[to] = 0;

		while (head < tail) {

			// Remove from queue
			var step = queue[head++];
			if (step == from) {
				pathFound = true;
				break;
			}
			var nextDistance = distance[step] + 1;

			for (dir in Hex.DIRS) {

				var n = Hex.offsetPacked( step, dir );
				if ((n == from) || (n != -1 && passable[n] && (distance[n] > nextDistance))) {
					// Add to queue
					queue[tail++] = n;
					distance[n] = nextDistance;
				}

			}
		}

		return pathFound;
	}

	public static function buildDMap( from:Int, passable:Array<Bool> ):Array<Int> {

		if (distance == null) {
			distance = [for (i in 0...LENGTH) UNREACHABLE];
		} else {
			for (i in 0...LENGTH) {
				distance[i] = UNREACHABLE;
			}
		}

		var pathFound = false;

		var head = 0;
		var tail = 0;

		if (queue == null) {
			queue = [for (i in 0...LENGTH) 0];
		}
		// Add to queue
		queue[tail++] = from;
		distance[from] = 0;

		while (head < tail) {

			// Remove from queue
			var step = queue[head++];

			var nextDistance = distance[step] + 1;

			for (dir in Hex.DIRS) {

				var n = Hex.offsetPacked( step, dir );
				if (n != -1 && passable[n] && distance[n] > nextDistance) {
					// Add to queue
					queue[tail++] = n;
					distance[n] = nextDistance;
				}

			}
		}

		return distance;
	}

	public static function step( from:Int, to:Int, passable:Array<Bool> ):Int {
		if (!buildDistanceMap( from, to, passable )) {
			return -1;
		}

		var minD = distance[from];
		var best = from;

		var step:Int;
		var stepD:Int;

		for (dir in Hex.DIRS) {

			step = Hex.offsetPacked( from, dir );
			if (step != -1 && (stepD = distance[step]) < minD) {
				minD = stepD;
				best = step;
			}
		}

		return best;
	}

	public static function stepBack( from:Int, away:Int, passable:Array<Bool> ):Int {

		var dmap = buildDMap( away, passable );

		var step = away;
		for (dir in Hex.DIRS) {
			var next = Hex.offsetPacked( from, dir );
			if (dmap[next] != UNREACHABLE && dmap[next] > dmap[step]) {
				step = next;
			}
		}
		if (step != from) {
			return step;
		} else {
			return -1;
		}

		// Here should be code for dealing with situations,
		// when you need to get closer to get further eventually,
		// but for now it works well enough as it is
	}
}

