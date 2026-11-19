import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Text-editing gestures that behave like iOS on every platform.
///
/// Flutter picks tap / long-press behaviour from the real device
/// ([defaultTargetPlatform]), which can't be changed in release builds. This
/// builder re-implements the iOS touch branches of
/// [TextSelectionGestureDetectorBuilder] so Android behaves like iOS:
///
/// * long-press in a focused field grabs the caret and drags it with the
///   floating cursor + loupe (Android would select a word instead);
/// * a tap moves the caret to the nearest word edge and toggles the toolbar
///   when tapping the caret again (Android places it at the exact spot).
///
/// On iOS (and desktop) every gesture is passed through to Flutter unchanged.
/// The logic mirrors Flutter 3.38 `widgets/text_selection.dart`.
class IosStyleTextSelectionGestureDetectorBuilder
    extends TextSelectionGestureDetectorBuilder {
  IosStyleTextSelectionGestureDetectorBuilder({required super.delegate});

  /// Whether iOS behaviour has to be emulated on the current platform.
  @visibleForTesting
  static bool get emulatesIos => switch (defaultTargetPlatform) {
        TargetPlatform.android || TargetPlatform.fuchsia => true,
        _ => false,
      };

  bool _floatingCursorOn = false;

  @override
  void onSingleTapUp(TapDragUpDetails details) {
    final bool touch = details.kind == PointerDeviceKind.touch ||
        details.kind == PointerDeviceKind.unknown;
    if (!emulatesIos ||
        !delegate.selectionEnabled ||
        !touch ||
        HardwareKeyboard.instance.isShiftPressed) {
      super.onSingleTapUp(details);
      return;
    }

    // iOS touch tap (Flutter's TargetPlatform.iOS / touch branch).
    final TextSelection previousSelection =
        renderEditable.selection ?? editableText.textEditingValue.selection;
    final TextPosition textPosition =
        renderEditable.getPositionForPoint(details.globalPosition);
    final bool isAffinityTheSame =
        textPosition.affinity == previousSelection.affinity;
    final bool wordAtCursorIndexIsMisspelled =
        editableText.findSuggestionSpanAtCursorIndex(textPosition.offset) !=
            null;

    if (wordAtCursorIndexIsMisspelled) {
      renderEditable.selectWord(cause: SelectionChangedCause.tap);
      if (previousSelection != editableText.textEditingValue.selection) {
        editableText.showSpellCheckSuggestionsToolbar();
      } else {
        editableText.toggleToolbar(false);
      }
    } else if (((_onSelectionExclusive(textPosition) &&
                !previousSelection.isCollapsed) ||
            (_onSelectionInclusive(textPosition) &&
                previousSelection.isCollapsed &&
                isAffinityTheSame &&
                !renderEditable.readOnly)) &&
        renderEditable.hasFocus) {
      // Tapped the caret / inside the selection again: toggle the menu.
      editableText.toggleToolbar(false);
    } else {
      renderEditable.selectWordEdge(cause: SelectionChangedCause.tap);
      if (previousSelection == editableText.textEditingValue.selection &&
          renderEditable.hasFocus &&
          !renderEditable.readOnly) {
        editableText.toggleToolbar(false);
      } else {
        editableText.hideToolbar(false);
      }
    }
    editableText.requestKeyboard();
  }

  @override
  void onSingleLongTapStart(LongPressStartDetails details) {
    // Unfocused or read-only: iOS selects the word, same as Android does.
    if (!emulatesIos ||
        !delegate.selectionEnabled ||
        !renderEditable.hasFocus ||
        renderEditable.readOnly) {
      super.onSingleLongTapStart(details);
      return;
    }

    // iOS: grab the caret and start the floating cursor.
    renderEditable.selectPositionAt(
      from: details.globalPosition,
      cause: SelectionChangedCause.longPress,
    );
    final TextSelection selection = editableText.textEditingValue.selection;
    editableText.updateFloatingCursor(
      RawFloatingCursorPoint(
        state: FloatingCursorDragState.Start,
        startLocation: (
          renderEditable.globalToLocal(details.globalPosition),
          TextPosition(
            offset: selection.baseOffset,
            affinity: selection.affinity,
          ),
        ),
        offset: Offset.zero,
      ),
    );
    _floatingCursorOn = true;
    editableText.showMagnifier(details.globalPosition);
  }

  @override
  void onSingleLongTapMoveUpdate(LongPressMoveUpdateDetails details) {
    if (!_floatingCursorOn) {
      super.onSingleLongTapMoveUpdate(details);
      return;
    }
    renderEditable.selectPositionAt(
      from: details.globalPosition,
      cause: SelectionChangedCause.longPress,
    );
    editableText.updateFloatingCursor(
      RawFloatingCursorPoint(
        state: FloatingCursorDragState.Update,
        offset: details.offsetFromOrigin,
      ),
    );
    editableText.showMagnifier(details.globalPosition);
  }

  @override
  void onSingleLongTapEnd(LongPressEndDetails details) {
    _endFloatingCursor();
    super.onSingleLongTapEnd(details);
  }

  @override
  void onSingleLongTapCancel() {
    _endFloatingCursor();
    super.onSingleLongTapCancel();
  }

  void _endFloatingCursor() {
    if (!_floatingCursorOn) return;
    _floatingCursorOn = false;
    if (editableText.mounted &&
        editableText.textEditingValue.selection.isCollapsed) {
      editableText.updateFloatingCursor(
        RawFloatingCursorPoint(state: FloatingCursorDragState.End),
      );
    }
  }

  bool _onSelectionExclusive(TextPosition position) {
    final TextSelection? selection = renderEditable.selection;
    return selection != null &&
        selection.start < position.offset &&
        selection.end > position.offset;
  }

  bool _onSelectionInclusive(TextPosition position) {
    final TextSelection? selection = renderEditable.selection;
    return selection != null &&
        selection.start <= position.offset &&
        selection.end >= position.offset;
  }
}
