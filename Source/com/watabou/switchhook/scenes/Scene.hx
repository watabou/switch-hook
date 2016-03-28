package com.watabou.switchhook.scenes;

import com.watabou.switchhook.ui.View;

class Scene extends View {

	override private function onAdded():Void {
		stage.application.onExit.add( onExit );
		stage.application.window.onFocusIn.add( onFocusIn );
		stage.application.window.onFocusOut.add( onFocusOut );
	}

	override private function onRemoved():Void {
		stage.application.onExit.remove( onExit );
		stage.application.window.onFocusIn.remove( onFocusIn );
		stage.application.window.onFocusOut.remove( onFocusOut );
	}

	private function onExit( code:Int ):Void {}
	private function onFocusIn():Void {}
	private function onFocusOut():Void {}

}
