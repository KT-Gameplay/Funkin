package funkin.play.event;

import funkin.play.event.SongEvent;
import funkin.play.PlayState;
import flixel.FlxG;
import funkin.modding.module.Module;
import funkin.util.Constants;
import funkin.Preferences;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

/*
 * The event that handles the switching of strumlines between upscroll and downscroll.
 */
class ScrollSwitchEvent extends SongEvent
{
  public function new()
  {
    super('Scroll Switch');
  }

  public override function getTitle():String
  {
    return 'Scroll Switch';
  }

  public override function handleEvent(data:SongEventData):Void
  {
    if(PlayState.instance == null) return;

    // Disabled in mobile to prevent bugs/glitches.
    if(FlxG.onMobile) return;

    // Using FlxTween to give that smooth movement while switching scrolls.
    FlxTween.cancelTweensOf(PlayState.instance.playerStrumline);
    FlxTween.cancelTweensOf(PlayState.instance.opponentStrumline);
    PlayState.instance.playerStrumline.isDownscroll = !PlayState.instance.playerStrumline.isDownscroll;
    FlxTween.tween(PlayState.instance.playerStrumline, {y: PlayState.instance.playerStrumline.isDownscroll ? FlxG.height - PlayState.instance.playerStrumline.strumlineNotes.members[0].height - Constants.STRUMLINE_Y_OFFSET - PlayState.instance.noteStyle.getStrumlineOffsets()[1] : Constants.STRUMLINE_Y_OFFSET}, 0.4, {ease: FlxEase.cubeOut});
    for (i in PlayState.instance.playerStrumline.strumlineNotes.members) {
    FlxTween.angle(i, 0, 360, 0.4, {ease: FlxEase.cubeOut});
    }
    PlayState.instance.opponentStrumline.isDownscroll = !PlayState.instance.opponentStrumline.isDownscroll;
    FlxTween.tween(PlayState.instance.opponentStrumline, {y: PlayState.instance.opponentStrumline.isDownscroll ? FlxG.height - PlayState.instance.opponentStrumline.strumlineNotes.members[0].height - Constants.STRUMLINE_Y_OFFSET - PlayState.instance.noteStyle.getStrumlineOffsets()[1] : Constants.STRUMLINE_Y_OFFSET}, 0.4, {ease: FlxEase.cubeOut});
    for (i in PlayState.instance.opponentStrumline.strumlineNotes.members) {
    FlxTween.angle(i, 0, 360, 0.4, {ease: FlxEase.cubeOut});
    }
    var healthBarYPos:Float = PlayState.instance.playerStrumline.isDownscroll ? FlxG.height * 0.1 : FlxG.height * 0.9;

    // Switching the position of the other UI
    FlxTween.tween(PlayState.instance.healthBarBG, {y: healthBarYPos}, 0.4, {ease: FlxEase.cubeOut});
    FlxTween.tween(PlayState.instance.healthBar, {y: healthBarYPos + 4}, 0.4, {ease: FlxEase.cubeOut});
    FlxTween.tween(PlayState.instance.scoreText, {y: healthBarYPos + 30}, 0.4, {ease: FlxEase.cubeOut});

    if (Preferences.subtitles)
    {
    if(PlayState.instance.playerStrumline.isDownscroll)
    PlayState.instance.subtitles.alignment = 'top';
    else
    PlayState.instance.subtitles.alignment = 'bottom';
    }
  }

  /*
   * This event doesn't give any options.
   * This is made so that the strumlines doesnt switch to the other scroll even though we are already in that scroll.
   */
  public override function getEventSchema():SongEventSchema
  {
    return [];
  }
}

/*
 * This module handles the resetting of scrolls if we die with the switched scroll.
 * This module will run during countdown so that we dont start with the switched scroll.
 */
class ScrollSwitchModule extends Module
{
  function onCountdownStart(event:CountdownScriptEvent):Void
  {
    super.onCountdownStart(event);
    if(FlxG.onMobile) return;

    PlayState.instance.playerStrumline.isDownscroll = Preferences.downscroll;
    PlayState.instance.playerStrumline.y = PlayState.instance.playerStrumline.isDownscroll ? FlxG.height - PlayState.instance.playerStrumline.height - Constants.STRUMLINE_Y_OFFSET -             PlayState.instance.noteStyle.getStrumlineOffsets()[1] : Constants.STRUMLINE_Y_OFFSET;
    PlayState.instance.opponentStrumline.isDownscroll = Preferences.downscroll;
    PlayState.instance.opponentStrumline.y = PlayState.instance.opponentStrumline.isDownscroll ? FlxG.height - PlayState.instance.opponentStrumline.height - Constants.STRUMLINE_Y_OFFSET -             PlayState.instance.noteStyle.getStrumlineOffsets()[1] : Constants.STRUMLINE_Y_OFFSET;

    var healthBarYPos:Float = PlayState.instance.playerStrumline.isDownscroll ? FlxG.height * 0.1 : FlxG.height * 0.9;

    PlayState.instance.healthBarBG.y = healthBarYPos;
    PlayState.instance.healthBar.y = PlayState.instance.healthBarBG.y + 4;
    PlayState.instance.scoreText.y = PlayState.instance.healthBarBG.y + 30;

    if (Preferences.subtitles)
    {
    if(PlayState.instance.playerStrumline.isDownscroll)
    PlayState.instance.subtitles.alignment = 'top';
    else
    PlayState.instance.subtitles.alignment = 'bottom';
    }
  }

  /*
   * This function will update the hold notes clipping when switching scrolls.
   */
  function onUpdate(event:UpdateScriptEvent):Void
  {
    super.onUpdate(event);
    if(PlayState.instance == null) return;
    if(FlxG.onMobile) return;
    for (holdNote in PlayState.instance.playerStrumline.holdNotes.members)
    {
    if (holdNote == null || !holdNote.alive) continue;

    if(holdNote.flipY != PlayState.instance.playerStrumline.isDownscroll)
    {
    holdNote.flipY = PlayState.instance.playerStrumline.isDownscroll;
    holdNote.updateClipping();
    }
    }

    for (holdNote in PlayState.instance.opponentStrumline.holdNotes.members)
    {
    if (holdNote == null || !holdNote.alive) continue;

    if(holdNote.flipY != PlayState.instance.opponentStrumline.isDownscroll)
    {
    holdNote.flipY = PlayState.instance.opponentStrumline.isDownscroll;
    holdNote.updateClipping();
    }
    }
  }
}
