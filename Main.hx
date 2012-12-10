package;

	import com.mini.Application;
	import com.mini.Cars;
	import com.mini.display.BackGround;
	import com.mini.Msprite;
	import com.mini.states.Fsm;
	import com.mini.states.WantedState;
	import com.mini.psd.PSDscene;
	
	class Main extends Application
	{		
		public static var ui:PSDscene;
		public static var scene:PSDscene;
		public static var frame:Msprite;
		public static var bg:BackGround;
		public static var cars:Cars;
		
		public static var fsm:Fsm;
				
		public function new()
		{
			super();
			scene = new PSDscene();
			ui = new PSDscene();
			frame = new Msprite();
			cars = new Cars();
		}
		
		override function init(e):Void {
			
			super.init(e);
			bg = new BackGround();
			addChild(scene);
			addChild(frame);
			addChild(cars);
			addChild(ui);
			
			fsm = new Fsm(new WantedState());
			addChild(fsm);
		}
		
		//-----------------------------------------------------------------------------------------------------
		
		override function resize(e):Void {
			super.resize(e);
			drawFrame();
		}
		
		function drawFrame(thin:Float=10,bold:Float=66) {
			frame.graphics.clear();
			frame.graphics.beginFill(0xFFFFFF);
			frame.graphics.drawRect(thin, 0, Application.STAGE.stageWidth-thin*2, thin);
			frame.graphics.drawRect(0, 0, thin, Application.STAGE.stageHeight);
			frame.graphics.drawRect(thin, Application.STAGE.stageHeight - bold, Application.STAGE.stageWidth-thin*2, bold);
			frame.graphics.drawRect(Application.STAGE.stageWidth - thin, 0, thin, Application.STAGE.stageHeight);
			frame.graphics.endFill();
			cars.y = Application.STAGE.stageHeight - bold-( cars.height-bold);
			cars.x = Application.STAGE.stageWidth-cars.width-thin*1.5;
		}
	}