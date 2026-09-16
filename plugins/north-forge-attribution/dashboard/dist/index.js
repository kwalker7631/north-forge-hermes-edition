(function () {
  const SDK = window.__HERMES_PLUGIN_SDK__;
  const { React } = SDK;

  function NorthForgeAttribution() {
    return React.createElement(
      "span",
      {
        className: "text-xs whitespace-nowrap mr-2",
        style: { color: "#FFC64B", letterSpacing: "0.04em" },
        title: "North Forge is the field agent. Hermes Agent is the engine.",
      },
      "North Forge \u00b7 in cooperation with Hermes Agent",
    );
  }

  window.__HERMES_PLUGINS__.registerSlot(
    "north-forge-attribution",
    "header-left",
    NorthForgeAttribution,
  );
})();
