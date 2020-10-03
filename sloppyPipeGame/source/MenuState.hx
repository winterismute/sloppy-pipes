package;

import flixel.addons.display.FlxStarField.FlxStarField2D;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxState;

class MenuState extends FlxState
{
    public static var currentChoice:Int;

    private var howto:String =
    "HOWTO\nUP/DOWN ARROWS: Move pipes.\nX: slows down pipes.\nPress X to start!";

    private var bgDay:FlxSprite;
    private var bgNight:FlxStarField2D;

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

        this.bgDay = new FlxSprite(0, 0);
        this.bgDay.loadGraphic("assets/images/parallax/layer1.png");
        this.add(bgDay);
        this.bgNight = new FlxStarField2D(0, 0, PlayState.SCREEN_WIDTH, PlayState.SCREEN_HEIGHT, 100);
        this.bgNight.visible = false;
        this.bgNight.exists = false;
        this.add(bgNight);

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

        this.cursor = new FlxSprite(this.daylightLabel.x, this.daylightLabel.y + 5);
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
            this.cursor.y = this.daylightLabel.y + 5;
            this.bgDay.visible = true;
            this.bgDay.exists = true;
            this.bgNight.visible = false;
            this.bgNight.exists = false;
            this.daylightLabel.color = FlxColor.BLACK;
            this.nightLabel.color = FlxColor.BLACK;
        }
        else
        {
            this.cursor.y = this.nightLabel.y + 5;
            this.bgDay.visible = false;
            this.bgDay.exists = false;
            this.bgNight.visible = true;
            this.bgNight.exists = true;
            this.daylightLabel.color = FlxColor.WHITE;
            this.nightLabel.color = FlxColor.WHITE;
        }

        super.update(elapsed);


    }

}