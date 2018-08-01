class HerculesModule {
  static String checkForHerculesModules(List<String> ssids) {
    String device;
    ssids.forEach((String ssid) {
      if (ssid.startsWith("[Hercules]")) {
        device = ssid;
      }
    });
    return device;
  }

  static List<String> detectHerculesModules(List<String> networks) {
    return List.from(
      networks.where(
        (String network) => network.startsWith("[Hercules]"),
      ),
    );
  }
}
