# Disabled Experimental Features

This folder contains features that are **under development** and not yet production-ready.

## Why Disabled?

These features had compilation errors and were preventing clean builds. They've been temporarily moved here to:

1. **Enable clean builds** of core functionality
2. **Focus on MVP features** (Premium, Cycle Tracking, AI)
3. **Develop incrementally** without breaking the main app

## Features in This Folder

### Community Module
- Community hub and social features
- Expert Q&A system
- Discussion boards
- Cycle buddy matching
- **Status**: Models incomplete, service methods need implementation

### Gamification Module
- Achievement system
- Leaderboard
- Challenges and streaks
- Educational content
- **Status**: Missing widget implementations

## Re-enabling Features

To re-enable a feature:

1. Fix all compilation errors in the feature
2. Run `flutter analyze` to verify
3. Move back to `lib/features/`
4. Add to app router if needed
5. Test thoroughly

## Current Focus

✅ **Production-Ready Features:**
- Premium subscription system
- Cycle tracking
- AI predictions
- Health insights
- Onboarding
- Settings

🚧 **To Be Completed:**
- Community features
- Gamification system
- Healthcare provider integration

---

**Note**: These features will be completed and re-enabled incrementally after core functionality is stable.
