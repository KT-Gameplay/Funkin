package funkin.play.event;

import funkin.data.character.CharacterData.CharacterDataParser;
import funkin.data.character.CharacterData;
// Data from the chart
import funkin.data.song.SongData.SongEventData;
// Data from the event schema
import funkin.data.event.SongEventSchema;
import funkin.data.event.SongEventSchema.SongEventFieldType;

/*
 * This event handles the switching of characters.
 */
class SetCharacterSongEvent extends SongEvent
{
	public function new()
	{
		super('SetCharacter', {
      processOldEvents: true
    });
	}

  static final DEFAULT_TARGET_CHAR:String = 'dad';
  static final DEFAULT_NEW_CHAR:String = 'bf';
  static final DEFAULT_X_OFFSET:Float = 0;
  static final DEFAULT_Y_OFFSET:Float = 0;

  public override function handleEvent(data:SongEventData)
  {
    // Does nothing if there is no PlayState.
	if (PlayState.instance == null) return;
    
    // Does nothing if we are minimal mode.
    if (PlayState.instance.isMinimalMode) return;

    var targetChar:Null<String> = data.getString('targetChar');
    if (targetChar == null) targetChar = DEFAULT_TARGET_CHAR;

    var newChar:Null<String> = data.getString('newChar');
    if (newChar == null) newChar = DEFAULT_NEW_CHAR;

    var offsetX:Null<Float> = data.getFloat('x');
    if (offsetX == null) offsetX = DEFAULT_X_OFFSET;

    var offsetY:Null<Float> = data.getFloat('y');
    if (offsetY == null) offsetY = DEFAULT_Y_OFFSET;

    PlayState.instance.changeCharacter(targetChar, newChar, offsetX, offsetY);
  }

  public override function getTitle():String
  {
	  return 'Set Character';
  }

   /**
   * ```
   * {
   *   'targetChar': STRING, // Character to change
   *   'newChar': STRING, // New character
   *   'x': FLOAT, // X Offset
   *   'y': FLOAT // Y Offset
   * }
   * ```
   * @return SongEventSchema
   */
	public override function getEventSchema():SongEventSchema
	{
		return [
			{
				name: 'targetChar',
				title: 'Target Character',
				defaultValue: DEFAULT_TARGET_CHAR,
				type: SongEventFieldType.ENUM,
				keys: [
					'Boyfriend' => 'bf',
					'Dad' => 'dad',
					'Girlfriend' => 'gf'
				]
			},
			{
				name: 'newChar',
				title: 'New Character',
				defaultValue: DEFAULT_NEW_CHAR,
				type: SongEventFieldType.ENUM,
				keys: generateCharList()
			},
			{
				name: 'x',
				title: 'Offset X',
				defaultValue: DEFAULT_X_OFFSET,
				type: SongEventFieldType.FLOAT,
                step: 5
			},
			{
				name: 'y',
				title: 'Offset Y',
				defaultValue: DEFAULT_Y_OFFSET,
				type: SongEventFieldType.FLOAT,
                step: 5
			}			
		];
	}

   /*
    * List of all Characters.
    */
   function generateCharList()
   {
      var charIDs:Array<String> = CharacterDataParser.listCharacterIds();
      var charMap:Map<String, String> = new Map();

      for (charID in charIDs)
      {
         var charData:CharacterData = CharacterDataParser.fetchCharacterData(charID);
         if (charData == null) continue;
         charMap.set(charData.name + ' (${charID})', charID);
      }
      return charMap;
   }
}
