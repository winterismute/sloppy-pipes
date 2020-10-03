package;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxState;

class MenuState extends FlxState
{
    public static var currentChoice:Int;

    private var howto:String =
    "HOWTO\nUP/DOWN ARROWS: Move pipes.\nRIGHT ARROW: slows down pipes.\nPress X to start!";

    // UI
    private var cursor:FlxSprite;
    private var daylightLabel:FlxText;
    private var nightLabel:FlxText;
    private var howtoLabel:FlxText;

	override public function create():Void
    {
        super.create();
        bgColor = 0xffffffff;
        FlxG.mouse.visible = false;

        currentChoice = 0;

        this.daylightLabel = new FlxText(0, 0, 200, "DAYLIGHT MODE (easy)", 18);
        this.daylightLabel.color = FlxColor.BLACK;
        this.add(daylightLabel);
        this.daylightLabel.screenCenter();

        this.nightLabel = new FlxText(0, 0, 200, "NIGHT MODE (hard but great)", 18);
        this.nightLabel.color = FlxColor.BLACK;
        this.add(nightLabel);
        this.nightLabel.screenCenter();

        this.daylightLabel.y -= 40;
        this.nightLabel.y += 40;

        this.cursor = new FlxSprite(this.daylightLabel.x, this.daylightLabel.y);
        this.cursor.loadGraphic("assets/images/bird.png");
        this.add(this.cursor);
        this.cursor.x -= (this.cursor.width + 20);

        this.howtoLabel = new FlxText(0, 0, 350, howto, 16);
        this.howtoLabel.color = FlxColor.RED;
        this.add(this.howtoLabel);
        this.howtoLabel.screenCenter();
        this.howtoLabel.y = PlayState.SCREEN_HEIGHT - 100;
    }

    override public function update(elapsed:Float):Void
    {
        if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.DOWN)
        {
            currentChoice = 1 - currentChoice;
        }
        if (FlxG.keys.justPressed.X)
        {
            FlxG.switchState(new PlayState());
        }

        if (currentChoice == 0)
        {
            this.cursor.y = this.daylightLabel.y;
        }
        else
        {
            this.cursor.y = this.nightLabel.y;
        }

        super.update(elapsed);


    }

}