import 'package:flutter/material.dart';

class ZyraShellController extends ChangeNotifier {
  bool isExpanded = false;
  bool isFullScreen = false;
  bool isTyping = false;
  bool quickRepliesCollapsed = false;
  bool isKeyboardVisible = false;
  bool isTransitioning = false;
  bool isResizing = false;

  double chatHeight = 0.5;

  void setKeyboardVisibility(bool visible) {
    if (isKeyboardVisible == visible) return;

    isKeyboardVisible = visible;

    notifyListeners();
  }

  void toggleExpanded() {
    if (isTransitioning) return;

    isExpanded = !isExpanded;

    if (!isExpanded) {
      isFullScreen = false;
      chatHeight = 0.5;
    }

    notifyListeners();
  }

  void toggleFullScreen() {
    if (isTransitioning) return;

    isFullScreen = !isFullScreen;
    chatHeight = isFullScreen ? 0.9 : 0.6;

    notifyListeners();
  }

  void setTyping(bool value) {
    if (isTyping == value) return;

    isTyping = value;

    notifyListeners();
  }

  void setQuickRepliesCollapsed(bool value) {
    if (quickRepliesCollapsed == value) return;

    quickRepliesCollapsed = value;

    notifyListeners();
  }

  void setTransitioning(bool value) {
    if (isTransitioning == value) return;

    isTransitioning = value;

    notifyListeners();
  }

  void setResizing(bool value) {
    if (isResizing == value) return;

    isResizing = value;

    notifyListeners();
  }

  void adjustChatHeight(
    double delta,
    double screenHeight,
  ) {
    final updatedHeight =
        (chatHeight - delta / screenHeight).clamp(0.3, 0.9);

    if (updatedHeight == chatHeight) return;

    chatHeight = updatedHeight;

    notifyListeners();
  }

  void restoreDialogState() {
    quickRepliesCollapsed = false;
    isKeyboardVisible = false;

    notifyListeners();
  }
}
