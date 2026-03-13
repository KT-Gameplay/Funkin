package funkin.play.event;

import funkin.data.stage.StageRegistry;
import funkin.play.event.SongEvent;
import funkin.play.stage.Stage;
import funkin.modding.module.ModuleHandler;
import haxe.ds.StringMap;
import flixel.FlxG;
import funkin.graphics.FunkinSprite;
import funkin.play.PlayState;
import funkin.play.character.CharacterDataParser;
import funkin.play.character.CharacterType;
import funkin.modding.events.ScriptEvent;
import funkin.modding.events.ScriptEventDispatcher;
import funkin.modding.module.Module;
import StringTools;
import flixel.FlxSprite;
import funkin.save.Save;

/**
 * This is the event for the stage changer.
 * Values are passed through the module.
 */
class SC_ChangeStageEvent extends SongEvent
{
  function new()
  {
    super('ChangeStage', {processOldEvents: true});
  }

  /**
   * Call the stage changer module to change the stage.
   */
  override function handleEvent(data:SongEventData)
  {
    ModuleHandler.getModule('SC_StageChanger').scriptCall('swapStage', [data.value.stageid, null]);
  }

  function getEventSchema()
  {
    return [
      {
        name: "stageid",
        title: "Stage",
        defaultValue: "mainStage",
        type: "enum",
        keys: generateStageList()
      }
    ];
  }

  function getTitle()
  {
    return "Change Stage";
  }

  /**
   * Returns the entry IDs of all stages.
   */
  static function generateStageList():StringMap<String, String>
  {
    var stageIDs:Array<String> = StageRegistry.instance.listEntryIds();
    var stageMap:StringMap<String, String> = new StringMap();

    for (stage in stageIDs)
    {
      var stageData:StageData = StageRegistry.instance.parseEntryDataWithMigration(stage, StageRegistry.instance.fetchEntryVersion(stage));
      stageMap.set(stageData.name, stage);
    }
    return stageMap;
  }
}

/**
 * The main module that handles stage changing!
 * This comes with the added benefit of preloading all of the stage props.
 */
class SC_StageChanger extends Module
{
  function new()
  {
    super('SC_StageChanger');
  }

  /**
   * Preload all of the stage props to reduce lag when a stage is loaded.
   */
  function onSongLoaded(event:SongLoadScriptEvent):Void
  {
    var stageIDMap:StringMap<String> = new StringMap();

    for (event in event.events)
    {
      if (event.eventKind == 'ChangeStage')
      {
        var stageID = event.value.stageid;
        if (stageID != null && stageID != '')
        {
          stageIDMap.set(stageID, stageID);
        }
      }
    }

    for (stageID in stageIDMap.keys())
    {
      trace('Preloading stage props for: ' + stageID);
      var stageData:Stage = StageRegistry.instance.parseEntryDataWithMigration(stageID, StageRegistry.instance.fetchEntryVersion(stageID));
      for (prop in stageData.props)
      {
        if (StringTools.startsWith(prop.assetPath, '#'))
        {
          continue;
        }
        trace('Preloading texture for prop: ' + prop.assetPath);
        Paths.image(prop.assetPath, stageData.directory ?? 'shared');
      }
    }
  }

  /**
   * Changes the stage.
   * @param stageID The ID of the stage to load.
   * @param characters Optional. If provided, the characters to load.
   */
  function swapStage(stageID:String = 'mainStage', ?characters:Array<String> = null):Void
  {
    if (PlayState.instance == null || PlayState.instance.currentStage == null) return;
    if (PlayState.instance.isMinimalMode) return;

    characters = [
      characters != null ? characters[0] : PlayState.instance.currentStage.getBoyfriend()?.characterId,
      characters != null ? characters[1] : PlayState.instance.currentStage.getGirlfriend()?.characterId,
      characters != null ? characters[2] : PlayState.instance.currentStage.getDad()?.characterId
    ];

    // Clear filters like the Weekend 1 rain shader.
    FlxG.camera.filters = [];

    loadStage(stageID);

    var bf:BaseCharacter = CharacterDataParser.fetchCharacter(characters[0]);
    var gf:BaseCharacter = CharacterDataParser.fetchCharacter(characters[1]);
    var dad:BaseCharacter = CharacterDataParser.fetchCharacter(characters[2]);

    if (bf != null)
    {
      bf.initHealthIcon(true);
      if (PlayState.instance.currentStage.getBoyfriend() != null)
      {
        PlayState.instance.currentStage.getBoyfriend().destroy();
      }
      PlayState.instance.currentStage.addCharacter(bf, CharacterType.BF);
    }

    if (gf != null)
    {
      if (PlayState.instance.currentStage.getGirlfriend() != null)
      {
        PlayState.instance.currentStage.getGirlfriend().destroy();
      }
      PlayState.instance.currentStage.addCharacter(gf, CharacterType.GF);
    }

    if (dad != null)
    {
      dad.initHealthIcon(true);
      if (PlayState.instance.currentStage.getDad() != null)
      {
        PlayState.instance.currentStage.getDad().destroy();
      }
      PlayState.instance.currentStage.addCharacter(dad, CharacterType.DAD);
    }
    }
    PlayState.instance.currentStage.resetStage();
    PlayState.instance.currentStage.refresh();
  }

  /**
   * Loads a stage by ID and removes the current stage.
   * @param id The ID of the stage to load.
   */
  function loadStage(id:String):Void
  {
    PlayState.instance.remove(PlayState.instance.currentStage);
    PlayState.instance.currentStage.kill();
    for (sprite in PlayState.instance.currentStage.group)
    {
      if (sprite != null)
      {
        sprite.kill();
        PlayState.instance.currentStage.group.remove(sprite);
      }
    }
    PlayState.instance.currentStage = null;

    PlayState.instance.currentStage = StageRegistry.instance.fetchEntry(id);

    if (PlayState.instance.currentStage != null)
    {
      stageDirectory = PlayState.instance.currentStage?._data?.directory ?? "shared";
      Paths.setCurrentLevel(stageDirectory);

      PlayState.instance.currentStage.revive();

      PlayState.instance.resetCameraZoom();

      PlayState.instance.currentStage.buildStage();
      PlayState.instance.currentStage.resetStage();
      PlayState.instance.add(PlayState.instance.currentStage);
    }
  }

  /**
   * Reset the stage back to default when the song is restarted.
   */
  override function onCountdownStart(event:CountdownScriptEvent):Void
  {
    if (PlayState.instance.currentStage.id != PlayState.instance.currentChart.stage)
    {
      resetStage();
    }
  }

  /**
   * Resets the stage to the original state.
   * This is called when the song is restarted.
   */
  function resetStage():Void
  {
    swapStage(PlayState.instance.currentChart.stage, [
      PlayState.instance.currentChart.characters.player,
      PlayState.instance.currentChart.characters.girlfriend,
      PlayState.instance.currentChart.characters.opponent
    ]);
  }
}
