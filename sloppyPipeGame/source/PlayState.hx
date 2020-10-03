package;

import flixel.addons.display.FlxBackdrop;
import flixel.system.FlxSound;
import flixel.text.FlxText;
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

	public static var SONG_BPM:Int = 120;

	private var birdSprite:Bird;
	private var pipes:FlxTypedSpriteGroup<Pipe>;
	private var rewindSprite:FlxSprite;

	private var starField:FlxStarField2D;
	private var parallaxLayers1:Array<FlxSprite>;
	private var parallaxLayers2:Array<FlxSprite>;
	private var parallaxLayers3:Array<FlxSprite>;

	private var birdHit:Bool;
	private var isGameOver:Bool;
	private var currentLives:Int;
	private var score:Int;
	
	// State to control bird
	private var jumpYThreshold:Float;
	private var beats:Array<Bool>;
	private var currentBarIndex:Int;
	private var msPerBar:Float;
	private var barTimeStamp:Float;
	private var tickTimer:Timer;

	// Sounds
	private var mainTrack:FlxSound;

	// UI
	private var livesSprites:Array<FlxSprite>;
	private var scoreLabel:FlxText;

	override public function create():Void
	{
		super.create();
		//bgColor = 0xffaaaaaa;

		FlxG.mouse.visible = false;
		var songPath:String = "assets/music/giag.ogg";
		var startAt:Float = 56000.0;
		if (MenuState.currentChoice == 0)
		{
			songPath = "assets/music/happy.ogg";
			startAt = 0.0;
		}
	
		if (FlxG.sound.music == null)
		{
			FlxG.sound.playMusic(songPath, 0.3, true);
			FlxG.sound.music.play(true, startAt);
			FlxG.sound.music.fadeIn(20, 0.1, 1.0);
		}
		else
		{
			FlxG.sound.music.play(true, startAt);
			FlxG.sound.music.fadeIn(20, 0.1, 1.0);
		}

		if (MenuState.currentChoice == 0)
		{
			this.parallaxLayers1 = new Array<FlxSprite>();
			var l1a:FlxSprite = new FlxSprite(0, 0);
			l1a.loadGraphic("assets/images/parallax/layer1.png");
			var l1b:FlxSprite = new FlxSprite(l1a.width, 0);
			l1b.loadGraphic("assets/images/parallax/layer1.png");
			l1a.velocity.x = l1b.velocity.x = -40;
			this.add(l1a);
			this.add(l1b);
			this.parallaxLayers1.push(l1a);
			this.parallaxLayers1.push(l1b);

			this.parallaxLayers2 = new Array<FlxSprite>();
			var l2a:FlxSprite = new FlxSprite(0, 0);
			l2a.loadGraphic("assets/images/parallax/layer2.png");
			var l2b:FlxSprite = new FlxSprite(l1a.width, 0);
			l2b.loadGraphic("assets/images/parallax/layer2.png");
			l2a.velocity.x = l2b.velocity.x = -60;
			this.add(l2a);
			this.add(l2b);
			this.parallaxLayers2.push(l2a);
			this.parallaxLayers2.push(l2b);

			this.parallaxLayers3 = new Array<FlxSprite>();
			var l3a:FlxSprite = new FlxSprite(0, 0);
			l3a.loadGraphic("assets/images/parallax/layer3.png");
			var l3b:FlxSprite = new FlxSprite(l1a.width, 0);
			l3b.loadGraphic("assets/images/parallax/layer3.png");
			l3a.velocity.x = l3b.velocity.x = -80;
			this.add(l3a);
			this.add(l3b);
			this.parallaxLayers3.push(l3a);
			this.parallaxLayers3.push(l3b);
		}
		else 
		{
			this.starField = new FlxStarField2D(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, 150);
			this.starField.setStarSpeed(STARS_SPEED_MIN, STARS_SPEED_MAX);
			this.add(this.starField);
		}

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

		this.rewindSprite = new FlxSprite(0, 0);
		this.rewindSprite.loadGraphic(AssetPaths.rewind_sheet__png, true, SCREEN_WIDTH, SCREEN_HEIGHT);
		this.rewindSprite.animation.add("rew",
			[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19],
			20);
		this.rewindSprite.alpha = 0.5;
		this.add(rewindSprite);
		this.rewindSprite.visible = false;
		this.rewindSprite.exists = false;

		this.birdSprite = new Bird(50, BIRD_INITIAL_Y);
		birdHit = false;
		this.add(this.birdSprite);

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
		this.score = 0;
		this.scoreLabel = new FlxText(SCREEN_WIDTH - 190 + 10, 10, 190, "SCORE: " + this.score, 16);
		this.add(scoreLabel);

		// Setup beat
		// 4 bars per beat, 4 beat => 16 elements
		beats = [
			false, false, false,false,
			true, false, false, false,
			false, false, false, false,
			true, false, false, false
		];
		currentBarIndex = 0;
		barTimeStamp = 0;
		msPerBar = ((1.0 / (SONG_BPM / 60)) * 1000) / 4;
		trace("msPerBar: " + msPerBar);
		this.tickTimer = null;

		setGameProperties();

		isGameOver = false;
		//this.mainTrack.play();
	}

	private function setGameProperties():Void
	{
		if (MenuState.currentChoice == 0)
		{
        	this.birdSprite.acceleration.y = 400;
			this.birdSprite.maxVelocity.y = 600;
			this.birdSprite.jumpAmount = 300;
			this.jumpYThreshold = 270;
			PIPE_VEL_X = -150;
		}
		else
		{
        	this.birdSprite.acceleration.y = 400;
			this.birdSprite.maxVelocity.y = 700;
			this.birdSprite.jumpAmount = 400;
			this.jumpYThreshold = 350;
			PIPE_VEL_X = -300;
		}
	}

	public function restart()
	{
		this.currentLives = 3;
		for (s in this.livesSprites)
		{
			s.exists = true;
			s.visible = true;
		}
		this.birdSprite.y = BIRD_INITIAL_Y;
		this.birdSprite.angle = 0;
		this.birdSprite.exists = true;

		// SOMEHOW THE CODE BELOW DOES NOT WORK??
		for (p in this.pipes.members)
		{
			p.x = 0;
			p.y = 1100;
			p.kill();
		}
		spawnNewPipes(SCREEN_WIDTH);

		this.score = 0;
		this.scoreLabel.text = "SCORE: " + this.score;

		birdHit = false;
		isGameOver = false;
		this.mainTrack.play(true, 10000);
		this.mainTrack.fadeIn(30.0, 0.0, 1.0);
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
			p.revive();
		}
	}

	private function decreaseLives():Void
	{
		this.livesSprites[this.currentLives-1].exists = false;
		this.livesSprites[this.currentLives-1].visible = false;
		this.currentLives -= 1;
	}

	private function setGameOver():Void
	{
		isGameOver = true;
		for (p in this.pipes.members)
		{
			if (p.exists)
			{
				p.velocity.x = p.velocity.y = 0;
			}
		}
		this.rewindSprite.visible = false;
		this.rewindSprite.exists = false;
		this.rewindSprite.animation.stop();
	}

	public function birdOverlapsPipe(o1:Bird, o2:Pipe):Void
	{
		if (!birdHit && !FlxFlicker.isFlickering(birdSprite) && FlxG.pixelPerfectOverlap(o1, o2))
		{
			decreaseLives();
			if (this.currentLives == 0)
			{
				birdHit = true;
			}
			else
			{
				FlxFlicker.flicker(birdSprite, 0.5);
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
			if (MenuState.currentChoice == 0)
			{
				if (this.parallaxLayers1[0].x + this.parallaxLayers1[0].width < 0)
				{
					var ps:FlxSprite = this.parallaxLayers1.shift();
					ps.x = this.parallaxLayers1[0].x + this.parallaxLayers1[0].width;
					this.parallaxLayers1.push(ps);
				}
				if (this.parallaxLayers2[0].x + this.parallaxLayers2[0].width < 0)
				{
					var ps:FlxSprite = this.parallaxLayers2.shift();
					ps.x = this.parallaxLayers2[0].x + this.parallaxLayers2[0].width;
					this.parallaxLayers2.push(ps);
				}
				if (this.parallaxLayers3[0].x + this.parallaxLayers3[0].width < 0)
				{
					var ps:FlxSprite = this.parallaxLayers3.shift();
					ps.x = this.parallaxLayers3[0].x + this.parallaxLayers3[0].width;
					this.parallaxLayers3.push(ps);
				}
			}

			/*
			if (FlxG.keys.pressed.LEFT)
			{
				pipeStepX = -100.0 * elapsed;
			}
			*/
			var backPressed:Bool = false;
			if (FlxG.keys.pressed.X)
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
				this.score += 1;
				this.scoreLabel.text = "SCORE: " + this.score;
			}

			for (p in this.pipes.members)
			{
				if (p.alive)
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
		else
		{
			// Gameover
			if (FlxG.keys.pressed.R)
			{
				//this.restart();
				FlxG.resetState();
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

		if (!birdHit && birdSprite.y >= this.jumpYThreshold)
		{
			this.birdSprite.onJumpKeyJustPressed();
		}

		birdSprite.y = Math.max(birdSprite.y, -100);
		super.update(elapsed);

		// Do collisions here
		if (!isGameOver && birdSprite.y > SCREEN_HEIGHT)
		{
			birdSprite.exists = false;
			setGameOver();
			//trace("isGameOver: true");
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
