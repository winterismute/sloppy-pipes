package;

import flixel.effects.FlxFlicker;
import flixel.addons.display.FlxStarField.FlxStarField2D;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.util.FlxTimer;
import haxe.Timer;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxState;
import Bird;
import Pipe;

class PlayState extends FlxState
{
	//public static var SCREEN_WIDTH = 1024;
	//public static var SCREEN_HEIGHT = 768;
	public static var SCREEN_WIDTH:Int = 800;
	public static var SCREEN_HEIGHT:Int = 450;
	public static var HALF_SCREEN_HEIGHT:Int = Std.int(SCREEN_HEIGHT / 2);

	public static var BIRD_INITIAL_Y:Int = HALF_SCREEN_HEIGHT;
	public static var PIPE_VEL_X:Float = -200.0;
	public static var STARS_SPEED_MIN:Int = 100;
	public static var STARS_SPEED_MAX:Int = 300;

	private var birdSprite:Bird;
	private var pipes:FlxTypedSpriteGroup<Pipe>;
	private var rewindSprite:FlxSprite;
	private var starField:FlxStarField2D;

	private var birdHit:Bool;
	private var isGameOver:Bool;
	private var currentLives:Int;
	
	// State to control bird
	private var beats:Array<Bool>;
	private var currentBarIndex:Int;
	private var msPerBar:Float;
	private var barTimeStamp:Float;
	private var tickTimer:Timer;

	// UI
	private var livesSprites:Array<FlxSprite>;

	override public function create():Void
	{
		super.create();
		//bgColor = 0xffaaaaaa;

		this.starField = new FlxStarField2D(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, 150);
		this.starField.setStarSpeed(STARS_SPEED_MIN, STARS_SPEED_MAX);
		this.add(this.starField);

		this.pipes = new FlxTypedSpriteGroup<Pipe>(0.0, 0.0, 30);
		for (i in 0...30)
		{
			var p : Pipe = new Pipe(0, 1100);
			p.kill();
			this.pipes.add(p);
		}
		this.add(pipes);
		//FlxG.random.resetInitialSeed()
		spawnNewPipes(SCREEN_WIDTH);

		this.birdSprite = new Bird(50, BIRD_INITIAL_Y);
		birdHit = false;
		this.add(this.birdSprite);

		this.rewindSprite = new FlxSprite(0, 0);
		this.rewindSprite.loadGraphic(AssetPaths.rewind_sheet__png, true, SCREEN_WIDTH, SCREEN_HEIGHT);
		this.rewindSprite.animation.add("rew",
			[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19],
			20);
		this.rewindSprite.alpha = 0.5;
		this.add(rewindSprite);
		this.rewindSprite.visible = false;
		this.rewindSprite.exists = false;

		// UI
		this.currentLives = 3;
		this.livesSprites = new Array<FlxSprite>();
		for (i in 0...this.currentLives)
		{
			var s:FlxSprite = new FlxSprite(10 + i * 24, 10);
			s.loadGraphic("assets/images/hearts.png", true, 16, 16);
			s.animation.add("static", [4], 1);
			s.animation.play("static");
			this.add(s);
			this.livesSprites.push(s);
		}

		// Setup beat
		var BPM:Int = 100;
		// 4 bars per beat, 4 beat => 16 elements
		beats = [
			false, false, false,false,
			true, false, false, false,
			false, false, false, false,
			true, false, false, false
		];
		currentBarIndex = 0;
		barTimeStamp = 0;
		msPerBar = ((1.0 / (BPM / 60)) * 1000) / 4;
		trace("msPerBar: " + msPerBar);
		this.tickTimer = null;

		isGameOver = false;
	}

	public function spawnNewPipes(fromX:Int):Void
	{
		var toSpawn:Int = 15;
		var nextX:Int = fromX;
		var marginX:Int = 20; 
		//trace("Spawning from: " + nextX);
		for (i in 0...toSpawn)
		{
			var p:Pipe = this.pipes.recycle();
			var ox:Int = FlxG.random.int(0, Pipe.WIDTH * 2);
			p.x = nextX + marginX + ox;
			nextX = Std.int(p.x + p.width);
			if (FlxG.random.float() < 0.5)
			{
				// TOP pipe
				p.y = -Pipe.HEIGHT + FlxG.random.int(50, Pipe.HEIGHT - 80);
				p.flipY = true;
			}
			else
			{
				// BOTTOM pipe
				p.y = SCREEN_HEIGHT - FlxG.random.int(50, Pipe.HEIGHT - 80);
				p.flipY = false;
			}
			p.velocity.x = PIPE_VEL_X;
			p.alive = true;
			p.exists = true;
		}
	}

	private function decreaseLives()
	{
		this.livesSprites[this.currentLives-1].exists = false;
		this.livesSprites[this.currentLives-1].visible = false;
		this.currentLives -= 1;
	}

	public function birdOverlapsPipe(o1:Bird, o2:Pipe):Void
	{
		if (!birdHit && !FlxFlicker.isFlickering(birdSprite) && FlxG.pixelPerfectOverlap(o1, o2))
		{
			if (this.currentLives == 0)
			{
				birdHit = true;
			}
			else
			{
				FlxFlicker.flicker(birdSprite, 0.5);
				decreaseLives();
			}
		}
	}

	public function onBarTick():Void
	{
		if (!birdHit)
		{
			currentBarIndex = (currentBarIndex + 1) % 16;
			if (beats[currentBarIndex])
			{
				this.birdSprite.onJumpKeyJustPressed();
			}
		}
	}

	override public function update(elapsed:Float):Void
	{
		var maxX:Int = 0;
		// Move pipes and record X of the one furthest away
		if (!isGameOver)
		{
			/*
			if (FlxG.keys.pressed.LEFT)
			{
				pipeStepX = -100.0 * elapsed;
			}
			*/
			var backPressed:Bool = false;
			if (FlxG.keys.pressed.RIGHT)
			{
				this.rewindSprite.visible = true;
				this.rewindSprite.exists = true;
				this.rewindSprite.animation.play("rew");
				//this.starField.setStarSpeed(Std.int(STARS_SPEED_MIN / 5), Std.int(STARS_SPEED_MAX / 5));
				backPressed = true;
			}
			else
			{
				this.rewindSprite.visible = false;
				this.rewindSprite.exists = false;
				this.rewindSprite.animation.stop();
				//this.starField.setStarSpeed(STARS_SPEED_MIN, STARS_SPEED_MAX);
			}

			for (p in this.pipes.members)
			{
				if (p.exists)
				{
					if (p.x > maxX)
					{
						maxX = Std.int(p.x);
					}
					if (backPressed)
					{
						p.velocity.x = PIPE_VEL_X / 5;
					}
					else
					{
						p.velocity.x = PIPE_VEL_X;
					}
				}
			}
			// Move pipes on Y
			var yFactor:Float = 150.0;
			if (FlxG.keys.pressed.DOWN)
			{
				pipes.y = Math.min(pipes.y + (yFactor * elapsed), 50.0);
			}
			else if (FlxG.keys.pressed.UP)
			{
				pipes.y = Math.max(pipes.y - (yFactor * elapsed), -50.0);
			}
		}

		// Move Bird
		/*
		if (this.tickTimer == null)
		{
			if (currentBarIndex == 0 && beats[0])
			{
				this.birdSprite.onJumpKeyJustPressed();
			}
			this.tickTimer = new Timer(msPerBar);
			this.tickTimer.run = onBarTick;
		}
		*/
		/*
		if (!birdHit)
		{
			//if (FlxG.keys.anyJustPressed(["W"]))
			//{
			//	this.birdSprite.onJumpKeyJustPressed();
			//}

			if (currentBarIndex == 0 && barTimeStamp == 0.0)
			{
				if (beats[0])
				{
					this.birdSprite.onJumpKeyJustPressed();
				}
				barTimeStamp = elapsed * 1000.0;
			}
			else
			{
				barTimeStamp += elapsed * 1000.0;
				if (barTimeStamp > msPerBar)
				{
					currentBarIndex = (currentBarIndex + 1) % 16;
					if (beats[currentBarIndex])
					{
						this.birdSprite.onJumpKeyJustPressed();
					}
					barTimeStamp -= msPerBar;
				}
			}
		}
		*/

		if (!birdHit && birdSprite.y >= HALF_SCREEN_HEIGHT)
		{
			this.birdSprite.onJumpKeyJustPressed();
		}

		birdSprite.y = Math.max(birdSprite.y, -100);
		super.update(elapsed);

		// Do collisions here
		if (birdSprite.y > SCREEN_HEIGHT)
		{
			birdSprite.active = false;
			birdSprite.exists = false;
			isGameOver = true;
			trace("isGameOver: true");
		}
		else if (!birdHit && !FlxFlicker.isFlickering(birdSprite))
		{
			FlxG.overlap(this.birdSprite, this.pipes, birdOverlapsPipe);
		}

		if (!isGameOver && maxX < SCREEN_WIDTH + 100)
		{
			spawnNewPipes(maxX + Pipe.WIDTH);
		}
	}
}
