package;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxState;
import Bird;
import Pipe;

class PlayState extends FlxState
{
	public static var BIRD_INITIAL_Y:Int = 400;
	public static var PIPE_VEL_X:Float = -200.0;

	private var birdSprite:Bird;
	private var pipes:FlxTypedGroup<Pipe>;
	private var birdHit:Bool;
	private var isGameOver:Bool;
	
	// State to control bird
	private var beats:Array<Bool>;
	private var currentBarIndex:Int;
	private var msPerBar:Float;
	private var barTimeStamp:Float;

	override public function create():Void
	{
		super.create();
		//bgColor = 0xffaaaaaa;

		this.pipes = new FlxTypedGroup<Pipe>(30);
		for (i in 0...30)
		{
			var p : Pipe = new Pipe(0, 1100);
			p.kill();
			this.pipes.add(p);
		}
		this.add(pipes);
		//FlxG.random.resetInitialSeed()
		spawnNewPipes(1024);

		this.birdSprite = new Bird(50, BIRD_INITIAL_Y);
		birdHit = false;
		this.add(this.birdSprite);

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

		isGameOver = false;
	}

	public function spawnNewPipes(fromX:Int):Void
	{
		var toSpawn:Int = 15;
		var nextX:Int = fromX;
		//trace("Spawning from: " + nextX);
		for (i in 0...toSpawn)
		{
			var p:Pipe = this.pipes.recycle();
			var ox:Int = FlxG.random.int(0, Pipe.WIDTH * 2);
			p.x = nextX + 20 + ox;
			nextX = Std.int(p.x + p.width);
			if (FlxG.random.float() < 0.5)
			{
				// TOP pipe
				p.y = -Pipe.HEIGHT + FlxG.random.int(50, 300);
				p.flipY = true;
			}
			else
			{
				// BOTTOM pipe
				p.y = 768 - FlxG.random.int(50, 300);
			}
			p.velocity.x = PIPE_VEL_X;
			p.alive = true;
			p.exists = true;
		}
	}

	public function birdOverlapsPipe(o1:Bird, o2:Pipe):Void
	{
		if (FlxG.pixelPerfectOverlap(o1, o2))
		{
			//birdHit = true;
		}
	}

	override public function update(elapsed:Float):Void
	{
		var maxX:Int = 0;
		// Move pipes and record X of the one furthest away
		if (!isGameOver)
		{
			var pipeStepX:Float = 0.0;
			var pipeStepY:Float = 0.0;
			if (FlxG.keys.pressed.LEFT)
			{
				pipeStepX = -100.0 * elapsed;
			}
			else if (FlxG.keys.pressed.RIGHT)
			{
				pipeStepX = 100.0 * elapsed;
			}
			for (p in this.pipes.members)
			{
				if (p.exists)
				{
					if (p.x > maxX)
					{
						maxX = Std.int(p.x);
					}
					p.velocity.x = PIPE_VEL_X + pipeStepX;
				}
			}
		}

		// Move Bird
		if (!birdHit)
		{
			/*
			if (FlxG.keys.anyJustPressed(["W"]))
			{
				this.birdSprite.onJumpKeyJustPressed();
			}
			*/

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
		birdSprite.y = Math.max(birdSprite.y, -100);
		super.update(elapsed);

		// Do collisions here
		if (birdSprite.y > 768)
		{
			birdSprite.active = false;
			birdSprite.exists = false;
			isGameOver = true;
			trace("isGameOver: true");
		}
		else if (!birdHit)
		{
			FlxG.overlap(this.birdSprite, this.pipes, birdOverlapsPipe);
		}

		if (!isGameOver && maxX < 1200)
		{
			spawnNewPipes(maxX + Pipe.WIDTH);
		}
	}
}
