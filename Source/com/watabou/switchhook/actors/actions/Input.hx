package com.watabou.switchhook.actors.actions;

class Input extends Action {

	public static var instance : Input = null;

	public function new() {
	}

	override public function involves():Array<Actor> {
		return [Game.hero];
	}

	override public function perform():Void {
		instance = this;
	}
}
