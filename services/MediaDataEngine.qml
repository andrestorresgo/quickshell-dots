pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    property MprisPlayer targetPlayer: {
        if (Mpris.players && Mpris.players.values) {
            for (var i = 0; i < Mpris.players.values.length; i++) {
                var p = Mpris.players.values[i];
                if (p && (p.desktopEntry === "spotify" || p.identity === "Spotify" || (p.dbusName && p.dbusName.indexOf("spotify") !== -1))) {
                    return p;
                }
            }
        }
        if (Mpris.players && typeof Mpris.players.count === "number") {
            for (var j = 0; j < Mpris.players.count; j++) {
                var p2 = Mpris.players.get(j);
                if (p2 && (p2.desktopEntry === "spotify" || p2.identity === "Spotify" || (p2.dbusName && p2.dbusName.indexOf("spotify") !== -1))) {
                    return p2;
                }
            }
        }
        return null;
    }

    readonly property bool active: targetPlayer !== null && targetPlayer.trackTitle !== ""

    readonly property string playingStateText: {
        if (!targetPlayer) return "";
        return targetPlayer.playbackState === MprisPlaybackState.Playing ? "" : " "
    }

    // TODO: add support for cover image
    readonly property string formattedTrack: {
        if (!targetPlayer) return "";
        
        var trackid = targetPlayer.metadata && targetPlayer.metadata["mpris:trackid"];
        if (trackid && trackid.toString().indexOf(":ad:") !== -1) {
            return "AD PLAYING";
        }
        
        var artist = targetPlayer.trackArtist || "";
        var title = targetPlayer.trackTitle || "";
        
        if (artist !== "" && title !== "") {
            return artist + " - " + title;
        }
        return title || "No Track Info";
    }
}
