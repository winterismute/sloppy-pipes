package;

import flixel.util.FlxColor;
import flixel.FlxSprite;

class Bird extends FlxSprite
{
    // State controller vars
    private var jumpKeyPressed:Bool;
    private var jumpKeyJustPressed:Bool;

    public function new(startX:Float, startY:Float)
    {
        super(startX, startY);
        this.makeGraphic(40, 40, FlxColor.RED);
        this.acceleration.y = 400;
        this.maxVelocity.y = 500;

        this.jumpKeyPressed = false;
        this.jumpKeyJustPressed = false;
    }

    public function onJumpKeyJustPressed() : Void
    {
        jumpKeyJustPressed = true;
    }

    public function onJumpKeyPressed() : Void
    {
        jumpKeyPressed = true;
    }

    override public function update(elapsed:Float) : Void
    {
        if (jumpKeyJustPressed)
        {
            this.velocity.y = -(this.maxVelocity.y / 2);
        }

        super.update(elapsed);
        
        jumpKeyPressed = false;
        jumpKeyJustPressed = false;
    }
}