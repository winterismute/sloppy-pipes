package;

import flixel.util.FlxColor;
import flixel.FlxSprite;

class Pipe extends FlxSprite
{
    public static var WIDTH:Int = 80;
    public static var HEIGHT:Int = 500;

    public function new(startX:Float, startY:Float)
    {
        super(startX, startY);
        this.makeGraphic(WIDTH, HEIGHT, FlxColor.GREEN);
    }

    override public function update(elapsed:Float) : Void
    {
        super.update(elapsed);

        if ((this.x + this.width) < 0)
        {
            this.exists = false;
            this.alive = false;
        }
    }
}