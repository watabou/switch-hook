package com.watabou.switchhook.actors.actions;

class Motion extends Action {

	public var dest	: Int;

	private var fast : Bool;

	public function new( obj:Actor, dest:Int, fast:Bool=false ) {
		this.obj = obj;
		this.dest = dest;
		this.fast = fast;
	}

	override public function perform():Void {

		var visible = Game.visible.data;
		if (visible[obj.pos] || visible[dest] || !Game.hero.isAlive()) {
			Action.add( this );
			obj.sprite.displayed = visible[dest];
			obj.sprite.arrival.addOnce( onArrive );
			obj.sprite.move( obj.pos, dest );
			obj.pos = dest;
		} else {
			obj.place( dest );
		}

		obj.fastAction = isFast();
	}

	private function onArrive():Void {
		Action.remove( this );
	}

	override public function isFast():Bool {
		return fast;
	}
}
