(function () {
  const SDK = window.__HERMES_PLUGIN_SDK__;
  const { React } = SDK;

  function NorthForgeAttribution() {
    return React.createElement(
      "span",
      {
        className: "text-xs text-muted-foreground whitespace-nowrap mr-2",
      },
      "In association with Hermes Agent",
    );
  }

  window.__HERMES_PLUGINS__.registerSlot(
    "north-forge-attribution",
    "header-left",
    NorthForgeAttribution,
  );
})();
