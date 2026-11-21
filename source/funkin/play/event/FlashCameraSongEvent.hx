package funkin.play.event;

import flixel.util.FlxColor;
// Data from the chart
import funkin.data.song.SongData.SongEventData;
// Data from the event schema
import funkin.data.event.SongEventSchema;
import funkin.data.event.SongEventSchema.SongEventFieldType;

/**
 * This class handles song events which flash the camera.
 * This lets you flash the game camera with a specified color and duration,
 * as well as determine whether the flash appears above the HUD.
 *
 * Example: Flash the camera white:
 * ```
 * {
 *   "e": "FlashCamera",
 *   "v": {
 *     "duration": 4.0,
 *     "color": "#FFFFFF",
 *     "alpha": 1.0,
 *     "aboveHUD": false
 *   }
 * }
 * ```
 */
class FlashCameraSongEvent extends SongEvent
{
  public function new()
  {
    super('FlashCamera');
  }

  public static final DEFAULT_DURATION:Float = 4.0;
  public static final DEFAULT_COLOR:String = '#FFFFFF';
  public static final DEFAULT_ALPHA:Float = 1.0;
  public static final DEFAULT_ABOVE_HUD:Bool = false;

  override public function handleEvent(data:SongEventData):Void
  {
    // Does nothing if there is no PlayState camera or stage.
    if (PlayState.instance == null || PlayState.instance.currentStage == null) return;

    // Does nothing if we are minimal mode.
    if (PlayState.instance.isMinimalMode) return;

    var duration:Null<Float> = data.getFloat('duration');
    if (duration == null) duration = DEFAULT_DURATION;

    var color:Null<String> = data.getString('color');
    if (color == null) color = DEFAULT_COLOR;

    var alpha:Null<Float> = data.getFloat('alpha');
    if (alpha == null) alpha = DEFAULT_ALPHA;

    var aboveHUD:Null<Bool> = data.getBool('aboveHUD');
    if (aboveHUD == null) aboveHUD = DEFAULT_ABOVE_HUD;

    var flashColor:FlxColor = FlxColor.fromString(color);

    var durSeconds = Conductor.instance.stepLengthMs * duration / Constants.MS_PER_SEC;

    // Apply flash to the appropriate camera.
    var camera = aboveHUD ? PlayState.instance.camHUD : PlayState.instance.camGame;
    camera._fxAlpha = alpha;

    if (camera == null) return;

    camera.flash(flashColor, durSeconds);
  }

  override public function getTitle():String
  {
    return 'Flash Camera';
  }

  /**
   * ```
   * {
   *   "duration": FLOAT, // Duration of the flash in steps
   *   "color": STRING, // Color of the flash
   *   "alpha": FLOAT, // Flash opacity
   *   "aboveHUD": BOOL, // Whether the flash appears above the HUD
   * }
   * @return SongEventSchema
   */
  override public function getEventSchema():SongEventSchema
  {
    return new SongEventSchema([
      {
        name: 'duration',
        title: 'Duration',
        defaultValue: DEFAULT_DURATION,
        min: 0,
        step: 0.5,
        type: SongEventFieldType.FLOAT,
        units: 'steps'
      },
      {
        name: 'color',
        title: 'Flash Color',
        defaultValue: DEFAULT_COLOR,
        type: SongEventFieldType.STRING
      },
      {
        name: 'alpha',
        title: 'Alpha',
        defaultValue: DEFAULT_ALPHA,
        min: 0,
        max: 1,
        step: 0.1,
        type: SongEventFieldType.FLOAT
      },
      {
        name: 'aboveHUD',
        title: 'Above HUD',
        defaultValue: DEFAULT_ABOVE_HUD,
        type: SongEventFieldType.BOOL
      }
    ]);
  }
}
