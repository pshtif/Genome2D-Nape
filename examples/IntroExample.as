package
{
	import com.genome2d.components.physics.nape.GNapeBody;
	import com.genome2d.components.renderables.GSprite;
	import com.genome2d.core.GConfig;
	import com.genome2d.core.GNode;
	import com.genome2d.core.GNodeFactory;
	import com.genome2d.core.Genome2D;
	import com.genome2d.physics.GNapeHelper;
	import com.genome2d.physics.GNapePhysics;
	import com.genome2d.textures.factories.GTextureFactory;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import nape.geom.Vec2;
	import nape.phys.BodyType;
	
	[SWF(width="800", height="600", backgroundColor="#000000", frameRate="60")]
	public class IntroExample extends Sprite
	{
		[Embed(source = "../assets/crate.jpg")]
		static private const CrateGFX:Class;
		
		protected var _cGenome2D:Genome2D;
		
		public function IntroExample() {
			// Initialization stuff for more info look into InitializeGenome2D example
			_cGenome2D = Genome2D.getInstance();
			_cGenome2D.onInitialized.addOnce(onGenome2DInitialized);

			var config:GConfig = new GConfig(new Rectangle(0,0,stage.stageWidth, stage.stageHeight));
			config.enableStats = true;

			_cGenome2D.init(stage, config);
		}
		
		protected function onGenome2DInitialized():void {
			// Create our crate texture
			GTextureFactory.createFromAsset("crate", CrateGFX);
			
			// Initialize nape physics
			_cGenome2D.physics = new GNapePhysics(Vec2.get(0,600));
			
			// Create a static physics boundary around the stage
			var body:GNapeBody = GNodeFactory.createNodeWithComponent(GNapeBody) as GNapeBody;
			body.napeBody = GNapeHelper.createStaticBoundary(new Rectangle(0,0,stage.stageWidth, stage.stageHeight), 100);
			_cGenome2D.root.addChild(body.node);
			
			// Create 100 boxes
			for (var i:int = 0; i<200; ++i) {
				createBox(Math.random()*800, Math.random()*600);
			}
			
			// Hook up a mouse click event to create box upon interaction
			stage.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		protected function onClick(event:MouseEvent):void {
			createBox(stage.mouseX, stage.mouseY);
		}
		
		// Create a dynamic nape box
		protected function createBox(p_x:Number, p_y:Number):void {
			// Create a node
			var node:GNode = GNodeFactory.createNode();
			// Create a sprite to render the box
			var sprite:GSprite = node.addComponent(GSprite) as GSprite;
			sprite.textureId = "crate";
			// Create a nape body component for physical representation
			var body:GNapeBody = sprite.node.addComponent(GNapeBody) as GNapeBody;
			// Use nape helper to create a nape body box representation
			body.napeBody = GNapeHelper.createBox(32,32,BodyType.DYNAMIC);
			
			// Move the node to a specified position
			node.transform.setPosition(p_x, p_y);
			// Add it to the root
			_cGenome2D.root.addChild(sprite.node);

		}
	}
}