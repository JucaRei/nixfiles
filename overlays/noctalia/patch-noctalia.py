import os
import sys

def patch_file(path, replacements):
    if not os.path.exists(path):
        print(f"File not found: {path}", file=sys.stderr)
        sys.exit(1)
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    for old, new in replacements:
        if new in content:
            continue
        if old not in content:
            print(f"Target string not found in {path}:\n{old[:80]}...", file=sys.stderr)
            sys.exit(1)
        content = content.replace(old, new, 1)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"Successfully patched {path}")

# 1. ActiveWindow.qml: left-click to toggle minimize
patch_file("Modules/Bar/Widgets/ActiveWindow.qml", [
    (
        "if (mouse.button === Qt.RightButton) {",
        'if (mouse.button === Qt.LeftButton) {\n                   Quickshell.execDetached(["sh", "-c", "export PATH=$HOME/.nix-profile/bin:$HOME/.local/bin:/nix/var/nix/profiles/default/bin:$PATH; export MANGO_INSTANCE_SIGNATURE=$(ls /run/user/$UID/mango-*.sock 2>/dev/null | head -n1); mmsg dispatch minimized"]);\n                 } else if (mouse.button === Qt.RightButton) {'
    )
])

# 2. Clock.qml: seconds, Portuguese date/time, Portuguese tooltip
pt_clock_funcs = """
  function formatPtDate(date) {
    const days = ["Domingo", "Segunda", "Terça", "Quarta", "Quinta", "Sexta", "Sábado"];
    const months = ["janeiro", "fevereiro", "março", "abril", "maio", "junho", "julho", "agosto", "setembro", "outubro", "novembro", "dezembro"];
    return days[date.getDay()] + ", " + date.getDate() + " de " + months[date.getMonth()];
  }

  function formatPtTime(date) {
    const h = String(date.getHours()).padStart(2, '0');
    const m = String(date.getMinutes()).padStart(2, '0');
    const s = String(date.getSeconds()).padStart(2, '0');
    return h + ":" + m + ":" + s;
  }
"""
patch_file("Modules/Bar/Widgets/Clock.qml", [
    (
        "readonly property color textColor: Color.resolveColorKey(clockColor)\n",
        "readonly property color textColor: Color.resolveColorKey(clockColor)\n" + pt_clock_funcs
    ),
    (
        'model: I18n.locale.toString(now, formatHorizontal.trim()).split("\\\\n")',
        "model: [root.formatPtTime(now), root.formatPtDate(now)]"
    ),
    (
        'model: I18n.locale.toString(now, formatVertical.trim()).split(" ")',
        "model: root.formatPtTime(now).split(':')"
    ),
    (
        'return I18n.tr("common.calendar"); // Defaults to "Calendar"',
        "return formatPtDate(now) + ' - ' + formatPtTime(now);"
    )
])

# 3. BarWidgetRegistry.qml: register MangoLayout
patch_file("Services/UI/BarWidgetRegistry.qml", [
    (
        '                           "Launcher": launcherComponent,\n',
        '                           "Launcher": launcherComponent,\n                           "MangoLayout": mangoLayoutComponent,\n'
    ),
    (
        '                                  "Launcher": {',
        '                                  "MangoLayout": {},\n                                  "Launcher": {'
    ),
    (
        '  property Component launcherComponent: Component {\n    Launcher {}\n  }\n',
        '  property Component launcherComponent: Component {\n    Launcher {}\n  }\n  property Component mangoLayoutComponent: Component {\n    MangoLayout {}\n  }\n'
    )
])

# 4. Taskbar.qml: toggle minimize on click
patch_file("Modules/Bar/Widgets/Taskbar.qml", [
    (
        "// Running app - focus it",
        '// Running app - focus it or toggle minimize\n                             if (taskbarItem.isFocused) {\n                               Quickshell.execDetached(["sh", "-c", "export PATH=$HOME/.nix-profile/bin:$HOME/.local/bin:/nix/var/nix/profiles/default/bin:$PATH; export MANGO_INSTANCE_SIGNATURE=$(ls /run/user/$UID/mango-*.sock 2>/dev/null | head -n1); mmsg dispatch minimized"]);\n                             } else'
    )
])

# 5. CalendarHeaderCard.qml: Portuguese months
patch_file("Modules/Cards/CalendarHeaderCard.qml", [
    (
        "text: I18n.locale.monthName(root.currentMonth, Locale.LongFormat).toUpperCase()",
        """text: {
              const months = ["JANEIRO", "FEVEREIRO", "MARÇO", "ABRIL", "MAIO", "JUNHO", "JULHO", "AGOSTO", "SETEMBRO", "OUTUBRO", "NOVEMBRO", "DEZEMBRO"];
              return months[root.currentMonth];
            }"""
    )
])

# 6. CalendarMonthCard.qml: Portuguese months and day abbreviations
patch_file("Modules/Cards/CalendarMonthCard.qml", [
    (
        'text: I18n.locale.monthName(root.calendarMonth, Locale.LongFormat).toUpperCase() + " " + root.calendarYear',
        """text: {
          const months = ["JANEIRO", "FEVEREIRO", "MARÇO", "ABRIL", "MAIO", "JUNHO", "JULHO", "AGOSTO", "SETEMBRO", "OUTUBRO", "NOVEMBRO", "DEZEMBRO"];
          return months[root.calendarMonth] + " " + root.calendarYear;
        }"""
    ),
    (
        """let dayIndex = (root.firstDayOfWeek + index) % 7;
                const dayName = I18n.locale.dayName(dayIndex, Locale.ShortFormat);
                return dayName.substring(0, 2).toUpperCase();""",
        """const ptDays = ["DOM", "SEG", "TER", "QUA", "QUI", "SEX", "SÁB"];
                let dayIndex = (root.firstDayOfWeek + index) % 7;
                return ptDays[dayIndex];"""
    )
])

# 7. DockContent.qml: toggle minimize if clicked when active
patch_file("Modules/Dock/DockContent.qml", [
    (
        "if (!Settings.data.dock.groupApps || runningToplevels.length <= 1) {\n",
        """if (!Settings.data.dock.groupApps || runningToplevels.length <= 1) {
                               if (primaryToplevel && primaryToplevel.activated) {
                                 Quickshell.execDetached(["sh", "-c", "export PATH=$HOME/.nix-profile/bin:$HOME/.local/bin:/nix/var/nix/profiles/default/bin:$PATH; export MANGO_INSTANCE_SIGNATURE=$(ls /run/user/$UID/mango-*.sock 2>/dev/null | head -n1); mmsg dispatch minimized"]);
                                 return;
                               }
"""
    )
])

# 8. CompositorService.qml: MangoWM uses ext-workspace-v1
patch_file("Services/Compositor/CompositorService.qml", [
    (
        """      isExtWorkspace = false;
      backendLoader.sourceComponent = mangoComponent;""",
        """      isExtWorkspace = true;
      backendLoader.sourceComponent = extWorkspaceComponent;
      Logger.i("CompositorService", "MangoWM detected: using ext-workspace-v1 backend");"""
    )
])

# 9. ExtWorkspaceService.qml: workspace polling timer & sorting
patch_file("Services/Compositor/ExtWorkspaceService.qml", [
    (
        """  Timer {
    interval: 500
    running: true
    repeat: false
    onTriggered: {
      if (WindowManager.windowsets.length > 0) {
        root.connectWorkspaceSignals();
        root.syncWorkspaces();
      }
    }
  }""",
        """  Timer {
    id: windowsetDiscoveryTimer
    interval: 200
    running: true
    repeat: true
    property int attempts: 0
    onTriggered: {
      attempts++;
      if (WindowManager.windowsets.length > 0) {
        root.connectWorkspaceSignals();
        root.syncWorkspaces();
        stop();
      } else if (attempts > 50) {
        stop();
      }
    }
  }"""
    ),
    (
        """    for (const ws of nativeWs) {
      if (!ws.shouldDisplay) {
        continue;
      }""",
        """    const sortedWs = nativeWs.slice().sort((a, b) => {
      const aIdx = parseInt(a.name || a.id, 10) || 0;
      const bIdx = parseInt(b.name || b.id, 10) || 0;
      return aIdx - bIdx;
    });

    for (const ws of sortedWs) {"""
    ),
    (
        """        if (projScreens && projScreens.length > 0) {
          outputName = projScreens[0].name || "";
        }
      }""",
        """        if (projScreens && projScreens.length > 0) {
          outputName = projScreens[0].name || "";
        }
      }
      if (!outputName && Quickshell.screens.length > 0) {
        outputName = Quickshell.screens[0].name || "";
      }"""
    ),
    (
        '"isOccupied": false,',
        '"isOccupied": (ws.shouldDisplay && !ws.active),'
    )
])

print("All Noctalia modifications applied cleanly!")
