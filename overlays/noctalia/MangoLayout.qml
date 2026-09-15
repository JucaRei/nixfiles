import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Modules.Bar.Extras
import qs.Services.Compositor
import qs.Services.UI
import qs.Widgets

Item {
  id: root

  property ShellScreen screen

  property string widgetId: ""
  property string section: ""
  property int sectionWidgetIndex: -1
  property int sectionWidgetsCount: 0

  readonly property string screenName: screen ? screen.name : ""
  readonly property string barPosition: Settings.getBarPositionForScreen(screenName)
  readonly property bool isBarVertical: barPosition === "left" || barPosition === "right"

  property string layoutName: "Tile"
  property string layoutIcon: "view-quilt"

  Process {
    id: layoutWatcher
    command: ["sh", "-c", "export PATH=$HOME/.nix-profile/bin:$HOME/.local/bin:/nix/var/nix/profiles/default/bin:$PATH; export MANGO_INSTANCE_SIGNATURE=$(ls /run/user/$UID/mango-*.sock 2>/dev/null | head -n1); mmsg get layout 2>/dev/null || echo 'tile'"]
    running: false
    stdout: SplitParser {
      onRead: data => {
        const raw = (data || "").trim().toLowerCase();
        if (raw.indexOf("scroller") !== -1) {
          root.layoutName = "Scroll";
          root.layoutIcon = "view-column";
        } else if (raw.indexOf("grid") !== -1) {
          root.layoutName = "Grid";
          root.layoutIcon = "view-grid";
        } else if (raw.indexOf("monocle") !== -1) {
          root.layoutName = "Mono";
          root.layoutIcon = "fullscreen";
        } else {
          root.layoutName = "Tile";
          root.layoutIcon = "view-quilt";
        }
      }
    }
  }

  Timer {
    id: pollTimer
    interval: 800
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      if (!layoutWatcher.running) {
        layoutWatcher.running = true;
      }
    }
  }

  implicitWidth: pill.width
  implicitHeight: pill.height

  BarPill {
    id: pill
    anchors.verticalCenter: parent.verticalCenter
    screen: root.screen
    oppositeDirection: BarService.getPillDirection(root)
    customIconColor: Color.mSecondary
    customTextColor: Color.mSecondary
    icon: root.layoutIcon
    autoHide: false
    text: root.layoutName
    tooltipText: "MangoWM: " + root.layoutName + "\nClique esquerdo: Seletor\nClique direito: Alternar"
    forceOpen: true
    onClicked: {
      Quickshell.execDetached(["sh", "-c", "export PATH=$HOME/.nix-profile/bin:$HOME/.local/bin:/nix/var/nix/profiles/default/bin:$PATH; export MANGO_INSTANCE_SIGNATURE=$(ls /run/user/$UID/mango-*.sock 2>/dev/null | head -n1); mango-layout-picker || true"]);
    }
    onRightClicked: {
      Quickshell.execDetached(["sh", "-c", "export PATH=$HOME/.nix-profile/bin:$HOME/.local/bin:/nix/var/nix/profiles/default/bin:$PATH; export MANGO_INSTANCE_SIGNATURE=$(ls /run/user/$UID/mango-*.sock 2>/dev/null | head -n1); mmsg dispatch switch_layout"]);
      pollTimer.restart();
      layoutWatcher.running = true;
    }
  }
}
