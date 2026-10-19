enum PremiumTileState { free, premiumLocked, comingSoon, unavailable }

class PremiumTilePolicy {
  static const Map<String, PremiumTileState> states = {
    'AI Health Coach': PremiumTileState.comingSoon,
    'Partner Connect': PremiumTileState.free,
    'Healthcare Portal': PremiumTileState.free,
    'Advanced Analytics': PremiumTileState.premiumLocked,
  };

  static PremiumTileState stateFor(String title) {
    final state = states[title];
    if (state == null) {
      throw StateError('Unclassified premium-preview tile: $title');
    }
    return state;
  }

  static bool isPremiumLocked(String title) =>
      stateFor(title) == PremiumTileState.premiumLocked;

  static bool isComingSoon(String title) =>
      stateFor(title) == PremiumTileState.comingSoon;
}
