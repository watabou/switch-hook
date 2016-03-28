package com.watabou.switchhook.actors.actions;

class Action {

	public var obj	: Actor;

	public function perform():Void {
	}

	public function involves():Array<Actor> {
		return [obj];
	}

	public function isBlocked():Bool {
		for (a1 in involves()) {
			for (action in inProgress) {
				for (a2 in action.involves()) {
					if (a1 == a2) {
						return true;
					}
				}
			}
		}

		return false;
	}

	public function isFast():Bool {
		return false;
	}

	// *******
	// STATIC
	// *******

	private static var inProgress	: Array<Action> = [];

	public static function add( action:Action ):Void {
		if (inProgress.indexOf( action ) == -1) {
			inProgress.push( action );
		}
	}

	public static function remove( action:Action ):Void {
		inProgress.splice( inProgress.indexOf( action ), 1 );
		if (action == Input.instance) {
			Input.instance = null;
		}
		Actor.process();
	}
}

