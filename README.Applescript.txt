PandoraBoy responds to iTunes-style Applescript. To get full information, view the dictionary by opening Script Editor, selecting File>Open Library... and selecting PandoraBoy. Here are the highlights:

tell application "PandoraBoy"
    pauseplay
    next track
    thumbs up
    thumbs down
    raise volume
    lower volume
    full volume
    mute
    get name of current track
    get name of tracks
    get artist of track 1
    get count of tracks
end tell

PandoraBoy saves the information about every track that plays during the session, numbered from 1. All commands act on the current track, however (Pandora itself cannot act on previously played tracks).