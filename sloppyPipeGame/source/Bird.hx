package;

import flixel.util.FlxColor;
import flixel.FlxSprite;

class Bird extends FlxSprite
{
    // State controller vars
    private var jumpKeyPressed:Bool;
    private var jumpKeyJustPressed:Bool;
    public var jumpAmount:Float;

    public function new(startX:Float, startY:Float)
    {
        super(startX, startY);
        //this.makeGraphic(40, 40, FlxColor.RED);
        this.loadRotatedGraphic("assets/images/bird_bigger.png", 360);
        this.acceleration.y = 400;
        this.maxVelocity.y = 500;
        this.jumpAmount = this.maxVelocity.y / 2;

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
            this.velocity.y = -this.jumpAmount;
        }
        if (this.velocity.y < 0)
        {
            this.angle = Math.max(this.angle - 150.0 * elapsed, -35);
        }
        else
        {
            this.angle = this.angle + 100.0 * elapsed;
        }

        super.update(elapsed);
        
        jumpKeyPressed = false;
        jumpKeyJustPressed = false;
    }
}