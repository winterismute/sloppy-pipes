package;

import flixel.util.FlxColor;
import flixel.FlxSprite;

class Pipe extends FlxSprite
{
    public static var WIDTH:Int = 70;
    public static var HEIGHT:Int = 288;

    public function new(startX:Float, startY:Float)
    {
        super(startX, startY);
        //this.makeGraphic(WIDTH, HEIGHT, FlxColor.GREEN);
        this.loadGraphic("assets/images/pipe.png");
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