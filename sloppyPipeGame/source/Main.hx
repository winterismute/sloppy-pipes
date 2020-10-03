package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(PlayState.SCREEN_WIDTH, PlayState.SCREEN_HEIGHT, MenuState, 1.0, 60, 60, true));
		//addChild(new FlxGame(0, 0, PlayState, 1.0, 60, 60, true));
	}
}
