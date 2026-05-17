package funkin.play.event;

import funkin.data.event.SongEventSchema;
import funkin.data.song.SongData.SongEventData;
import funkin.data.character.CharacterDataParser;
import haxe.ds.StringMap;

/**
 * This class handles song events that switches the character
 */
class SetCharacterSongEvent extends SongEvent
{
  public function new()
  {
    super('SetCharacter', {
			processOldEvents: true
		});
  }

   static final DEFAULT_CHAR:String = 'bf';
   static final DEFAULT_NEWCHAR:String = 'dad';

  override public function handleEvent(data:SongEventData):Void
  {
    // Does nothing if there is no PlayState.
    if (PlayState.instance == null) return;

    //Does nothing in minimal mode.
    if (PlayState.instance.isMinimalMode) return;

    PlayState.instance.changeCharacter(data.value.char ?? DEFAULT_CHAR, data.value.newchar ?? DEFAULT_NEWCHAR);
   }

  override public function getTitle():String
  {
    return 'Set Character';
  }

  override public function getEventSchema():SongEventSchema
  {
    return new SongEventSchema([
      {
        name: 'char',
        title: 'Character',
        defaultValue: DEFAULT_CHAR,
        type: SongEventFieldType.ENUM,
        keys: ['Boyfriend' => 'bf', 'Dad' => 'dad', 'Girlfriend' => 'gf'],
      },
      {
        name: 'newchar',
        title: 'New Character',
        defaultValue: DEFAULT_NEWCHAR,
        type: SongEventFieldType.ENUM,
        keys: generateCharList(),
      }
    ]);
  }

/**
 * List of all Characters.
 */
  function generateCharList()
  {
      var charIDs:Array<String> = CharacterDataParser.listCharacterIds();
      var charMap:StringMap<String, String> = new StringMap();

      for (charID in charIDs)
      {
         var charData:CharacterData = CharacterDataParser.fetchCharacterData(charID);
         charMap.set(charData.name, charID);
      }
      return charMap;
  }
}
