package funkin.play.event;

// Data from the chart
import funkin.data.song.SongData.SongEventData;
// Data from the event schema
import funkin.data.event.SongEventSchema;
import funkin.data.event.SongEventSchema.SongEventFieldType;
import flixel.FlxG;
import Std;

/**
 * This class handles song events that bops the camera once for the set intensity.
 *
 * Example: Bop the camera once with a noticable zoom.
 * ```
 * {
 *   'e': 'BopCamera',
 *   'v': {
 *    'hudintensity': 0.05,
 *    'cameraintensity': 0.05
 *   }
 * }
 * ```
 * Value has to be really small to prevent sudden bops.
 */
class BopCameraSongEvent extends SongEvent
{
  public function new()
  {
    super('BopCamera', {
      processOldEvents: true
    });
  }

  public override function handleEvent(data:SongEventData):Void
  {
    // Does nothing if there is no PlayState camera or stage.
    if (PlayState.instance == null) return;

    var camZoom:Float = Std.parseFloat(data.getFloat('gameIntensity'));
	var hudZoom:Float = Std.parseFloat(data.getFloat('hudintensity'));
	if(Math.isNaN(camZoom)) camZoom = 0.015;
	if(Math.isNaN(hudZoom)) hudZoom = 0.03;

    PlayState.instance.camHUD.zoom += hudZoom;
    PlayState.instance.cameraBopMultiplier = 1 + camZoom;
  }

  public override function getTitle():String
  {
    return 'Bop Camera';
  }

  /**
   * ```
   * {
   *   'hudintensity': FLOAT, // HUD Zoom amount
   *   'cameraintensity': Float, // Camera Zoom Amount
   * }
   * ```
   * @return SongEventSchema
   */
  public override function getEventSchema():SongEventSchema
  {
    return new SongEventSchema([{
      name: 'gameIntensity',
      title: 'Camera Zoom Intensity',
      defaultValue: 0,
      min: 0,
      step: 0.01,
      type: SongEventFieldType.FLOAT,
      units: 'x'
    }, {
      name: 'hudIntensity',
      title: 'HUD Zoom Intensity',
      defaultValue: 0,
      min: 0,
      step: 0.01,
      type: SongEventFieldType.FLOAT,
      units: 'x'
    }]);
  }
}
